# AI Pronunciation Coach

An AI-powered mobile application for improving English pronunciation.

## Product purpose

The application answers one question for a non-native English speaker:

> Which English sounds do I pronounce incorrectly, and how do I fix them?

The user speaks, the system analyses the recording at the phoneme level, identifies
which sounds were mispronounced, explains the mistake, and generates personalised
exercises that target that user's weakest sounds over time.

This is deliberately **not** a general English-learning application. Every feature
must serve pronunciation improvement.

## Technology stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.47.1, Dart 3.13.1 |
| Backend | Go 1.25, Gin |
| Database | PostgreSQL 18 |
| Cache | Redis 8 |
| Pronunciation analysis | Provider abstraction — final provider selected via the Phase 0 evaluation |
| Payments | RevenueCat (App Store / Google Play) |
| Infrastructure | Docker, Docker Compose |
| Version control | Git, GitHub |
| Notifications | GitHub webhook → GitPulse → Telegram |

## Repository structure

```
ai-pronunciation-coach/
├── apps/
│   └── mobile/              Flutter application
├── backend/
│   ├── cmd/server/          API entrypoint
│   ├── internal/server/     HTTP layer (routes, handlers)
│   ├── migrations/          SQL migrations
│   ├── tests/               Backend tests
│   ├── go.mod
│   └── go.sum
├── docs/
│   └── architecture.md      Architecture review and implementation plan
├── infrastructure/
│   └── docker/              Dockerfiles
├── .env.example
├── .gitignore
├── docker-compose.yml
└── README.md
```

## Local development prerequisites

| Requirement | Version used |
|---|---|
| Go | 1.25.4 |
| Flutter | 3.47.1 (stable) |
| Dart | 3.13.1 |
| PostgreSQL | 18.6 |
| Xcode | 26.6 (iOS builds) |
| Android SDK | platform 37, build-tools 37.0.0 |
| Docker | optional — not required at this stage |

### Backend

```bash
cd backend
go mod download
go run ./cmd/server
```

The API listens on `:8080` by default. Override with `PORT`:

```bash
PORT=8081 go run ./cmd/server
```

> On this development machine port 8080 is already used by GitPulse, so set
> `PORT` to something else when running locally.

Verify:

```bash
curl http://localhost:8080/health
# {"status":"ok"}
```

Backend checks:

```bash
cd backend
gofmt -l .        # no output means formatted
go vet ./...
go test ./...
go build ./cmd/server
```

### Mobile

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

Build:

```bash
flutter build apk --debug                        # Android
flutter build ios --simulator --no-codesign      # iOS simulator
```

### Environment

```bash
cp .env.example .env
```

`.env` is git-ignored. Never commit real credentials. None of the variables in
`.env.example` are read by the code yet — they document the intended
configuration surface.

### Docker

Docker is **not required** to run the project at this stage. The compose file
prepares the structure for later tasks:

```bash
docker compose up -d postgres redis    # datastores only
docker compose up --build backend      # API in a container
```

## Current implementation status

**TASK 01 — PROJECT FOUNDATION**

Complete:

- Monorepo directory structure
- Go backend with Gin, `GET /health`, structured logging and graceful shutdown
- Backend test suite covering the health contract
- Flutter application scaffold that builds, analyses and tests clean
- `.env.example` with placeholder variables only
- `.gitignore` covering secrets and Go/Flutter/Android/iOS build artefacts
- `docker-compose.yml` and backend Dockerfile (structure only)

Not yet implemented — deliberately out of scope at this stage:

- Authentication and user management
- Audio recording and upload
- Pronunciation analysis and the provider integration
- Scoring engine
- Practice and progress tracking
- Subscriptions and RevenueCat
- Product UI screens
- Database schema and migrations

See [docs/architecture.md](docs/architecture.md) for the full architecture review,
cost model, risk register and implementation order.
