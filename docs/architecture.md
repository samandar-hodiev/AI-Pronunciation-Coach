# AI Pronunciation Coach — Architecture Review (Task 1)

Status: proposal, awaiting sign-off. No application code written yet, per spec §86.

---

## 0. Preflight: this machine.

| Tool | State | Consequence |
|---|---|---|
| Go 1.25.4 (darwin/arm64) | present | backend work can start today |
| PostgreSQL 18.6 (Postgres.app) | present | run migrations natively; no Docker needed for dev DB |
| Flutter / Dart | **missing** | blocks the §44 POC client |
| Xcode | **missing** | no iOS simulator, no iOS build |
| Android SDK / Studio | **missing** | no Android emulator (only Android File Transfer installed) |
| Docker / Compose | **missing** | blocks §42 `docker compose up` |
| golang-migrate, golangci-lint | missing | install with the backend skeleton |

The spec's §43 order starts with project setup and §44 requires a Flutter POC. Half that toolchain isn't
installed. Recommendation: **start with the backend + a vendor spike driven by curl and WAV fixtures**,
and install Flutter/Xcode/Android in parallel. Nothing in Phase 0–2 needs a phone.

---

## 1. Final architecture

Modular monolith in Go, exactly as §80.3 asks. The pipeline is the spec's, with three deliberate
deviations, each justified below.

```
Flutter (record 16 kHz mono WAV, <=30 s)
   |  multipart POST /api/v1/pronunciation/analyze
   v
Go + Gin
   |-- validate: mime, size, duration, sample rate
   |-- usage check (Redis counter + DB-configured limit)
   |-- persist audio -> object storage (R2), key only in Postgres
   |-- PronunciationAnalyzer.Analyze(audio, expectedText)   <-- ONE vendor call
   |       returns: recognized text + word scores + phoneme scores + miscue types
   |-- persist provider_raw jsonb (verbatim)
   |-- scoring engine (deterministic, versioned) -> overall/word/phoneme + status
   |-- write attempt + phoneme_results, update user_phoneme_stats (EWMA)
   |-- feedback: template lookup by (phoneme, error_type, actual_phoneme)
   v
JSON response: score, per-phoneme breakdown, explanation, retry target
```

Asynchronous, off the request path: LLM session summaries, LLM exercise generation, audio lifecycle
cleanup, analytics rollups.

### Deviation 1 — drop Whisper from the scoring path

§12 proposes Whisper. Whisper is a poor fit for the core job: it is trained to produce *plausible English
text*, so it normalizes pronunciation errors away. A learner who says "tree" while the expected word is
"three" will frequently be transcribed as "three". It also returns no phoneme alignment and no per-phoneme
confidence. Using it would cost a second API call and second round of latency to obtain a transcript that
the pronunciation vendor already returns.

Keep the `SpeechRecognizer` interface (§66) — it is cheap and useful later for free-speech mode (Level 5) —
but do not put it in the MVP hot path.

### Deviation 2 — per-attempt feedback is templated, not LLM-generated

The MVP covers 13 phoneme groups (§63) with a small set of error types (substitution, omission, insertion).
"You replaced TH with T; put your tongue lightly between your teeth" is **static content**, not a
generation problem. Storing it in `phoneme_feedback_templates` gives instant feedback, zero marginal cost,
deterministic quality, and no chance of an LLM inventing articulation advice.

The LLM keeps §15's real jobs: session summaries, personalized coaching notes, and exercise generation —
all asynchronous or cached, none blocking the score.

### Deviation 3 — synchronous analysis, no job queue in MVP

Clips are <=30 s and typically 2–4 s. One vendor round trip is comfortably inside an HTTP request. A queue,
polling endpoint, and status table are real complexity for no MVP benefit (§80.1). Revisit only if p95
exceeds ~4 s.

---

## 2. Recommended dependencies

**Go**

```
github.com/gin-gonic/gin              HTTP
github.com/jackc/pgx/v5               Postgres driver + pool
sqlc (codegen, not a runtime dep)     typed queries, no ORM magic
github.com/golang-migrate/migrate/v4  migrations
github.com/redis/go-redis/v9          counters, rate limit
github.com/golang-jwt/jwt/v5          access tokens
golang.org/x/crypto/argon2            password hashing (argon2id)
github.com/aws/aws-sdk-go-v2/service/s3   S3 API; works against Cloudflare R2
github.com/go-playground/validator/v10    request validation
log/slog (stdlib)                     structured logging
github.com/stretchr/testify           assertions
github.com/testcontainers/testcontainers-go   integration tests
github.com/google/uuid
```

Deliberately not included: an ORM (sqlc is a better fit for a schema this shaped), a DI framework, a
message queue, an Azure SDK (see §6 — REST over cgo).

**Flutter**

```
flutter_riverpod + riverpod_annotation   state
go_router                                navigation
dio + pretty_dio_logger                  HTTP, interceptor-based auth refresh
freezed + json_serializable              models
flutter_secure_storage                   tokens (§35)
record                                   PCM16 WAV capture
just_audio                               reference-audio playback
permission_handler                       mic permission
purchases_flutter                        RevenueCat
fl_chart                                 progress charts
```

---

## 3. Folder structure

Accept §37 as written. Additions:

```
backend/
  internal/
    scoring/          + testdata/   golden fixtures for score regression
    ai/
      pronunciation/azure/          REST client
      pronunciation/fake/           deterministic provider for tests + Flutter dev
      speech/openai/                stub until Level 5
      feedback/template/            DB-backed
      feedback/openai/              async coaching
  db/queries/                       sqlc .sql sources
  migrations/
  seeds/                            phonemes, words, minimal pairs, templates
  testdata/audio/                   WAV fixtures for the vendor spike
tools/spike/                        Phase 0 CLI, throwaway
```

`internal/ai/pronunciation/fake` matters more than it looks: it lets Flutter and the whole test suite run
without spending vendor credits or needing network.

---

## 4. PostgreSQL schema plan

The spec lists 20 tables. Four changes:

**Consolidate** `user_pronunciation_profiles` + `user_mistakes` into one `user_phoneme_stats`
(PK `user_id, phoneme_id`). Two aggregates derived from the same source will drift apart.

**Derive** `streaks` from `daily_progress`; cache `streak_current` / `streak_longest` on `user_profiles`.

**Replace** `pronunciation_feedback` with `phoneme_feedback_templates` (static, seeded) plus a nullable
`coach_note` column on the attempt for async LLM output.

**Add** `minimal_pairs` (powers three/tree, ship/sheep, rice/lice — the heart of the drill content),
`content_sets` + `content_set_items` (makes the §19 onboarding word list remotely updatable, as required),
and `phonemes` as a real table with IPA, ARPABET, and articulation tips.

Core tables:

```
users(id uuid pk, email citext unique, password_hash, email_verified_at,
      created_at, updated_at, deleted_at)

refresh_tokens(id, user_id, token_hash, family_id, expires_at, revoked_at,
      replaced_by, created_at)                 -- rotation with reuse detection

user_profiles(user_id pk, display_name, native_language, target_accent,
      daily_goal_minutes, timezone, onboarding_completed_at,
      streak_current, streak_longest, streak_last_day)

phonemes(id smallint pk, code 'TH', ipa 'θ', arpabet, display_name, phoneme_group,
      example_word, articulation_tip, sort_order, active)

words(id, text, ipa, arpabet_seq text[], difficulty, target_phoneme_id,
      category, active)
sentences(id, text, ipa, difficulty, target_phoneme_id, active)
minimal_pairs(id, word_a_id, word_b_id, phoneme_a_id, phoneme_b_id)
content_sets(id, key 'onboarding_test_v1', name, active)
content_set_items(set_id, word_id, position)

pronunciation_attempts(id uuid, user_id, source enum(test|practice|free),
      practice_item_id, word_id, sentence_id, expected_text, recognized_text,
      storage_key, audio_duration_ms, mime_type, file_size,
      overall_score, accuracy_score, fluency_score, completeness_score,
      provider, provider_raw jsonb, scoring_version,
      status enum(pending|scored|failed), error_code, created_at)
      index (user_id, created_at desc)

phoneme_results(id bigserial, attempt_id, phoneme_id, position,
      expected_phoneme, actual_phoneme, score numeric(5,2),
      status enum(correct|warning|incorrect),
      error_type enum(none|substitution|omission|insertion))
      index (attempt_id), index (phoneme_id)

user_phoneme_stats(user_id, phoneme_id, pk(user_id, phoneme_id),
      ewma_score, sample_count, correct_count, baseline_score, baseline_at,
      best_score, first_seen_at, last_seen_at, is_weakness)

practice_sessions(id, user_id, target_phoneme_id, level, generated_by,
      started_at, completed_at, item_count, avg_score)
practice_items(id, session_id, position, word_id, sentence_id, attempt_id, status)

daily_progress(user_id, day date, pk(user_id, day), attempts_count,
      practice_minutes, avg_score, goal_met)

subscriptions(id, user_id unique, provider, product_id, entitlement, status,
      store, original_transaction_id, environment enum(sandbox|production),
      purchase_at, expiration_at, cancelled_at, created_at, updated_at)
subscription_events(id, event_id text unique, user_id, type, payload jsonb,
      received_at, processed_at)               -- unique event_id = idempotency

plan_limits(id, plan enum(free|pro), key, int_value, active)   -- §28/§64 config in DB
phoneme_feedback_templates(id, phoneme_id, error_type, actual_phoneme,
      severity, headline, explanation, tip, drill_word_ids)
analytics_events(id, user_id, name, props jsonb, created_at)   -- partition by month
```

**The single most valuable schema decision:** `provider_raw jsonb` + `scoring_version` on every attempt.
It lets you re-score the entire history when the scoring algorithm changes, and evaluate a replacement
vendor against real user audio, without paying the vendor a second time.

Migrations via golang-migrate, `NNN_name.up.sql` / `.down.sql`, per §57.

---

## 5. API endpoint plan

§34's surface, plus the gaps:

```
POST   /api/v1/auth/register | login | refresh | logout
GET    /api/v1/auth/me
GET    /api/v1/profile              PATCH /api/v1/profile
DELETE /api/v1/account                      -- §72, also an App Store requirement

GET    /api/v1/content/test                 -- onboarding word set, DB-driven (§19)
GET    /api/v1/content/phonemes

POST   /api/v1/pronunciation/analyze        -- multipart: audio + expected_text + context
GET    /api/v1/pronunciation/history        -- cursor paginated
GET    /api/v1/pronunciation/:id

GET    /api/v1/practice/today
POST   /api/v1/practice/session             -- body: target_phoneme, level
POST   /api/v1/practice/:id/complete

GET    /api/v1/progress | /weekly | /phonemes
GET    /api/v1/usage
GET    /api/v1/subscription
POST   /api/v1/subscription/sync            -- client-triggered reconciliation
POST   /api/v1/subscription/webhook/revenuecat   -- unauthenticated route, header-verified
GET    /healthz | /readyz
```

Envelope per §39: `{ "success": bool, "data": {...} }` or `{ "success": false, "error": { "code", "message" } }`.
Every response carries `X-Request-Id`.

---

## 6. AI provider integration plan

```go
type PronunciationAnalyzer interface {
    Analyze(ctx context.Context, in AnalyzeInput) (*PronunciationResult, error)
    Name() string
}
```

`PronunciationResult` is our own vocabulary — recognized text, word scores, phoneme scores in ARPABET,
miscue type, plus the raw payload. No vendor type escapes the package.

**Recommended provider #1: Azure AI Speech — Pronunciation Assessment.** It is the only mainstream option
that returns the exact structure this product's data model requires from one call: overall accuracy,
fluency, completeness, prosody, word-level scores, **phoneme-level accuracy scores**, and miscue detection
(omission / insertion / mispronunciation).

Use the **REST short-audio endpoint**, not the SDK. Pronunciation assessment is available over REST for
audio up to 30 s by passing a base64-encoded JSON config in a `Pronunciation-Assessment` header. Microsoft's
Go Speech SDK is a cgo wrapper around a native library, which would complicate the Docker build for no gain.
Plain `net/http` keeps the image small and the build static. The 30 s REST ceiling happens to match the
§64 duration cap — set our limit below it.

Alternates behind the same interface: SpeechAce and ELSA (purpose-built for pronunciation assessment,
richer L2 diagnostics, higher price). Long term, the cost-control answer is self-hosting: a wav2vec2
phoneme-CTC model (`facebook/wav2vec2-xlsr-53-espeak-cv-ft` and similar) with forced alignment and
Goodness-of-Pronunciation scoring. That is an ML project, not an MVP task — but `provider_raw` and the
interface are what make it possible later.

**Vendor scores are heuristic, not truth.** Microsoft's own guidance and community reports describe
phoneme-level scores as indicators that can be inconsistent for some phoneme combinations. This is the
reason for Phase 0 below.

Scoring engine (§14) owns: normalization to 0–100, thresholds to correct/warning/incorrect, aggregation,
and EWMA profile updates. Pure functions, golden-file tests, `scoring_version` stamped on every row. The
LLM never produces a number.

---

## 7. RevenueCat integration plan

Entitlement `pro`; products `pronunciation_pro_monthly`, `pronunciation_pro_yearly`; offering `default`
with `monthly` + `annual` packages, exactly per §74.

**The one mistake that breaks everything:** call `Purchases.logIn(<backend user uuid>)` on every login and
registration, so RevenueCat's `app_user_id` equals our `users.id`. Without it, webhooks arrive keyed to
anonymous IDs that cannot be mapped to a user, and entitlement silently never syncs.

Webhook hardening:

- Verify the configurable `Authorization` header with `crypto/subtle.ConstantTimeCompare`. Enable HMAC
  signing as well — RevenueCat sends `X-RevenueCat-Webhook-Signature: t=<unix_ts>,v1=<hmac_sha256_hex>`;
  verify the HMAC and reject stale timestamps.
- Delivery is **at least once**. Insert `subscription_events.event_id` with a unique constraint and treat a
  conflict as success — that alone makes processing idempotent.
- Events can arrive **out of order**. Never derive state from event type alone; treat `expiration_at` as the
  authority and ignore any event older than the stored one.
- Map: `INITIAL_PURCHASE`/`RENEWAL`/`UNCANCELLATION`/`PRODUCT_CHANGE` -> active; trial -> trialing;
  `CANCELLATION` -> cancelled but **entitled until `expiration_at`**; `EXPIRATION` -> expired;
  `BILLING_ISSUE` -> billing_issue, keep access through the grace period; `TRANSFER` -> move the
  subscription row between users.
- Return 200 quickly; do the work in-transaction but keep it small. RevenueCat retries non-2xx.
- Sandbox events carry an environment flag — store it and never let sandbox purchases grant production `pro`.

Backend is the authority for entitlement (§80.11), with a reconciliation call to RevenueCat's REST API on
app foreground and before any high-value action. Prices come from the store via RevenueCat, never hardcoded
in Flutter (§74).

---

## 8. Cost model

Azure real-time speech-to-text is ~$1.00 per audio hour, with pronunciation assessment as a ~$0.30/hour
add-on for real-time use — about **$1.30 per audio hour**. Verify against current pricing for your region
before launch.

| Scenario | Attempts/mo | Audio | Vendor cost | Verdict |
|---|---|---|---|---|
| Free user at the 5/day cap | 150 | 7.5 min | **$0.16** | fine |
| Pro, realistic (40/day) | 1,200 | 60 min | **$1.30** | 26% of $4.99 — fine |
| Pro, heavy (200/day) | 6,000 | 5 hrs | **$6.50** | **loses money** |
| Yearly Pro ($3.33/mo equiv.) | breakeven ≈ 2,560 | ~2.1 hrs | $3.33 | tighter |

Assumes 3-second attempts. **"Unlimited" (§28) needs a documented fair-use ceiling** — suggest ~150
attempts/day for Pro, far above genuine practice behaviour but below the abuse threshold. Put it in
`plan_limits` and state it in the Subscription Terms.

Audio storage is not the problem: 3 s of 16 kHz mono PCM is ~96 KB, and Cloudflare R2 charges $0.015/GB-month
with zero egress fees — under a cent per user per month. Retention limits (30 days free / 180 days Pro)
are worth having for privacy (§71), not cost. **R2 over S3 specifically because playback of a user's own
history is pure egress.**

Templated feedback keeps per-attempt LLM cost at exactly zero. Worth a spike: Azure "fast transcription" is
billed ~$0.36/hour — confirm whether pronunciation assessment is supported on that path, since it could cut
unit cost roughly threefold.

---

## 9. Technical risks

| # | Risk | Mitigation |
|---|---|---|
| R1 | **Phoneme scores may not reliably separate correct from incorrect speech.** If they don't, there is no product. | Phase 0 spike before any app code. Benchmark against speechocean762 (5,000 utterances with expert phoneme-level labels) plus your own clips. |
| R2 | **Score volatility destroys trust.** Same word twice → 62 then 81. | EWMA smoothing; never show a profile percentage below ~5 samples; show bands early, exact numbers later. |
| R3 | Whisper normalizes errors away (spec §12). | Not in the scoring path — Deviation 1. |
| R4 | "Unlimited" Pro is unbounded COGS. | Fair-use cap in `plan_limits`, stated in Terms. |
| R5 | No Flutter / Xcode / Android SDK / Docker on this machine. | Backend-first ordering; install in parallel during Phase 0–2. |
| R6 | RevenueCat identity mismatch → unmappable webhooks. | `logIn(backend_user_id)` at every auth event. |
| R7 | Webhooks are at-least-once and can arrive out of order. | Unique `event_id`; `expiration_at` as authority. |
| R8 | App Store / Play review rejection. | Restore purchases, account deletion, Terms + Privacy links, demo account, accurate privacy labels for audio. |
| R9 | Vendor lock-in on the one component you cannot replace cheaply. | Provider interface + `provider_raw` + a labeled internal eval set to measure any replacement. |
| R10 | Accuracy may differ for Uzbek / Russian / Turkish / Arabic L1 speakers vs. the vendor's training distribution. | Collect consented eval clips from target L1s early; measure per-L1 before promising accuracy. |
| R11 | Latency over mobile networks. | 16 kHz mono, duration cap, staged progress UI (§69), upload starts as recording ends. |
| R12 | Voice data is sensitive and regionally regulated. | Explicit consent, retention policy, deletion endpoint, DPA with vendor, opt out of vendor training. |

R1 is the only one that can kill the product outright. Everything else is engineering.

---

## 10. Implementation order

**Phase 0 — Vendor validation spike (2–4 days, no app code).** Record ~60 clips: 10 minimal-pair words
(three/tree, ship/sheep, rice/lice, very/wery, light/right), each spoken correctly, deliberately wrong, and
borderline, by 2–3 speakers including a target-L1 speaker. Run them through Azure (and one alternate) via a
throwaway Go CLI in `tools/spike/`. **Gate: do the phoneme scores separate correct from deliberately-wrong
with a usable margin, consistently across repeats?** If yes, build. If no, change vendor or change the
product promise — before writing 10,000 lines against an assumption.

Then:

1. Backend skeleton — Gin, config, slog, `/healthz`, graceful shutdown
2. Postgres + golang-migrate + sqlc wiring
3. Migrations 001–003: users, profiles, content
4. Seed data: phonemes, words, minimal pairs, feedback templates
5. Auth: argon2id, JWT access, refresh rotation with reuse detection
6. Profile endpoints; `DELETE /account`
7. Storage abstraction + R2 implementation
8. `PronunciationAnalyzer` interface + Azure REST provider + fake provider
9. Scoring engine with golden-file tests **(write these first — it's the deterministic core)**
10. `POST /pronunciation/analyze` end-to-end, exercised by curl against WAV fixtures
11. `user_phoneme_stats` EWMA updates + history endpoints
12. **Backend POC gate: curl a WAV of "three", get `72/100` with `TH ✗ / R ✓ / EE ✓`**
13. Flutter project + theme, router, Dio client, secure storage
14. Auth screens, onboarding, splash
15. Recording (16 kHz mono WAV) + permission handling
16. Practice + Result screens against the real endpoint
17. **§44 POC gate: full round trip on a device**
18. Onboarding pronunciation test + profile result screen
19. Home, Progress, Profile screens
20. `plan_limits` + Redis usage counters + `UsageService`, enforced server-side
21. RevenueCat dashboard setup, products, offering
22. Flutter purchase flow + paywall + restore
23. Webhook endpoint, verification, idempotency, reconciliation
24. `EntitlementService` gating premium features
25. Practice session generation from weaknesses (rule-based first, LLM second)
26. Async LLM coaching notes and session summaries
27. Analytics events, structured logging, error tracking
28. Docker Compose, CI, integration tests, then deploy

Steps 1–12 need only what's already installed on this machine.

---

## Open questions

1. **Azure account** — is there an Azure subscription available, or should Phase 0 also evaluate SpeechAce
   as primary? This is the only true blocker for Phase 0.
2. **Target accent** — US only for MVP, or US + UK? It affects the phoneme inventory, seed content, and the
   vendor's locale parameter.
3. **Audio retention** — is keeping user audio (for progress playback and a future eval set) acceptable to
   you, or should clips be deleted immediately after scoring? This changes the privacy policy and the
   long-term self-hosting path.
