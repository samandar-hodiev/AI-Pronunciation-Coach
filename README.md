# AI Pronunciation Coach

Ingliz tili talaffuzini yaxshilash uchun mo'ljallangan AI asosidagi mobil ilova.

## Loyiha nima?

Ilova non-native foydalanuvchi uchun bitta savolga javob beradi:

> Men ingliz tilidagi qaysi tovushlarni noto'g'ri talaffuz qilaman va ularni
> qanday tuzataman?

Foydalanuvchi gapiradi, tizim yozuvni **fonema darajasida** tahlil qiladi, qaysi
tovush noto'g'ri aytilganini aniqlaydi, xatoni tushuntiradi va aynan o'sha
foydalanuvchining eng zaif tovushlariga qaratilgan shaxsiy mashqlar yaratadi.

Bu ataylab **umumiy ingliz tili o'rgatuvchi ilova emas**. Har bir funksiya
talaffuzni yaxshilashga xizmat qilishi shart.

## Texnologiyalar

| Qatlam | Texnologiya |
|---|---|
| Mobil | Flutter 3.47.1, Dart 3.13.1 |
| Navigatsiya | go_router |
| Backend | Go 1.25, Gin |
| Ma'lumotlar bazasi | PostgreSQL 18 |
| Kesh | Redis 8 |
| Talaffuz tahlili | Provider abstraksiyasi — yakuniy provider Phase 0 baholashdan keyin tanlanadi |
| To'lovlar | RevenueCat (App Store / Google Play) |
| Infratuzilma | Docker, Docker Compose |
| Versiya nazorati | Git, GitHub |
| Bildirishnomalar | GitHub webhook → GitPulse → Telegram |

## Mahsulotning to'liq oqimi (reja)

Ilova birinchi marta ochilganda foydalanuvchi darhol Dashboard'ni ko'rmaydi.
Rejalashtirilgan ketma-ketlik:

```
App Launch                              ✅
01. Splash (sessiya tekshiruvi bilan)   ✅
02. Welcome / Value Proposition         ✅
03. Onboarding                          ✅
04. Authentication (Register / Login)   ✅  ← real backend
05. Account (sessiya)                   ✅  ← real backend
06. Goal Selection                      ✅
07. English Level Selection             ✅
08. Pronunciation Assessment Intro      ✅
09. Microphone Permission               ⏳ hozircha placeholder
10. First Pronunciation Test            ⏳
11. Pronunciation Analysis              ⏳
12. First Result                        ⏳
13. Profile / Personalization           ⏳
14. Free / Premium Introduction         ⏳
15. Home Dashboard                      ⏳
```

`✅` faqat haqiqatda implement qilingan ekranlar uchun qo'yiladi.
`⏳` — hali yaratilmagan yoki vaqtinchalik placeholder.

Hozirda **haqiqatda ishlaydigan** oqim:

```
App launch → Splash → (sessiya bormi?)
   ├── ha  → Account
   └── yo'q → Welcome → Onboarding → Create Account / Sign In
                                   → Account → Goal → English Level
                                   → Assessment Intro → Microphone (placeholder)
```

## Bajarilgan tasklar

### TASK 01 — Project Foundation

- Monorepo strukturasi (`apps/`, `backend/`, `docs/`, `infrastructure/`)
- Go + Gin backend, `GET /health` endpoint, strukturali log, graceful shutdown
- Backend testlari
- Flutter ilovasi skeleti (iOS + Android)
- `.env.example` — faqat placeholder qiymatlar
- `docker-compose.yml` va backend Dockerfile (faqat struktura)
- iPhone 17 Simulator uchun jonli preview workflow (hot reload ishlaydi)

### TASK 02 — Splash Screen + App Launch Foundation

- **Splash Screen** — ilova ochilganda birinchi ko'rinadigan ekran
- **Navigatsiya asosi** — `go_router` bilan `/splash` va `/welcome`
- **Welcome placeholder** — keyingi taskda to'liq UI yaratiladi
- **Markazlashtirilgan mavzu** — cheklangan rang palitrasi, light + dark rejim
- **Qayta ishlatiladigan brend komponentlari** — `BrandMark`, `AppWordmark`
- 13 ta Flutter testi

### TASK 03 — Welcome / Value Proposition Screen

- **Welcome Screen** — mahsulot qiymatini tushuntiruvchi birinchi mazmunli ekran
- **Uchta value proposition** — Speak / Analyze / Improve
- **Asosiy CTA** — "Start practicing", `/onboarding` ga o'tkazadi
- **Onboarding placeholder** — keyingi taskda to'liq UI yaratiladi
- Qayta ishlatiladigan komponentlar: `PrimaryButton`, `ValuePropositionItem`
- Typography va tugma uslubi `AppTheme` ga markazlashtirildi
- 16 ta yangi test (jami 29 ta)

### TASK 04 — Onboarding Experience

- **Onboarding ekrani** — uchta sahifa: Speak / Understand / Improve
- **`PageView`** — surish (swipe) va tugma orqali harakat
- **Sahifa indikatori** — joriy sahifani ko'rsatadi, faol nuqta kengroq
- **Next / Get started** — oxirgi sahifada CTA matni o'zgaradi
- **Skip** — istalgan sahifadan onboarding'ni tugatadi
- **Orqaga qaytish** — 2 va 3-sahifalarda
- **Goal Selection placeholder** — keyingi taskda to'liq UI
- Kontent `OnboardingItem` modeli orqali beriladi, widget ichida emas
- 22 ta yangi test (jami 51 ta)

### TASK 05 — Goal Selection

Foydalanuvchidan asosiy talaffuz maqsadini so'raydi — onboarding'dan keyingi
birinchi personalizatsiya bosqichi.

Beshta variant (bittasi tanlanadi):

| ID | Sarlavha |
|---|---|
| `speak_clearly` | Speak more clearly |
| `difficult_sounds` | Improve difficult sounds |
| `reduce_accent` | Reduce my accent |
| `speak_confidently` | Speak more confidently |
| `exam_preparation` | Prepare for an exam |

- **Single-choice** — yangi tanlov oldingisini almashtiradi
- **Validation** — maqsad tanlanmaguncha Continue o'chirilgan
- **Navigatsiya** — Continue → `/level`, Back → `/onboarding`
- **Skip yo'q** — maqsad personalizatsiya uchun majburiy
- `GoalOption` modeli barqaror ID bilan (kelajakda backend'ga yuboriladi)
- 24 ta yangi test (jami 75 ta)

### TASK 06 — English Level Selection

Personalizatsiyaning ikkinchi va oxirgi bosqichi.

Beshta daraja (bittasi tanlanadi):

| ID | Sarlavha | Daraja |
|---|---|---|
| `beginner` | Beginner | 1 |
| `elementary` | Elementary | 2 |
| `intermediate` | Intermediate | 3 |
| `upper_intermediate` | Upper-Intermediate | 4 |
| `advanced` | Advanced | 5 |

- **Single-choice**, Continue tanlovsiz o'chirilgan
- **Navigatsiya** — Continue → `/assessment-intro`, Back → `/goal`
- **Daraja ko'rsatkichi** — ikonka o'rniga ustunlar, chunki darajalar
  tartiblangan; to'ldirilgan ustunlar soni darajani bildiradi
- `EnglishLevel` modeli barqaror ID va `rank` maydoni bilan
- **Refactoring:** Goal va Level bir xil tanlov naqshidan foydalangani uchun
  karta va sarlavha qatori `shared/widgets/` ga ko'chirildi
  (`SelectableOptionCard`, `PersonalizationHeader`)
- 26 ta yangi test (jami 101 ta)

### TASK 07 — Pronunciation Assessment Introduction

Foydalanuvchini birinchi talaffuz baholashiga tayyorlaydi. Ekran faqat
**tushuntiradi** — mikrofon ruxsati bu yerda so'ralmaydi va audio yozilmaydi.

Uchta bosqich:

| # | Sarlavha | Izoh |
|---|---|---|
| 1 | Listen | Listen to a short phrase. |
| 2 | Speak | Repeat the phrase naturally. |
| 3 | Improve | Get feedback on the sounds you can improve. |

- **Davomiylik** — "About 2 minutes" (matn, taymer emas)
- **Mikrofon izohi** — "Microphone access is needed so we can hear your
  pronunciation." Ataylab faqat faktik: audio qanday saqlanishi haqida va'da
  berilmaydi, chunki bunday siyosat hali belgilanmagan
- **Navigatsiya** — Start assessment → `/microphone`, Back → `/level`
- **Skip yo'q** — baholashdan oldingi kontekst muhim
- Bosqichlarda ikonka emas, **tartib raqami** ishlatilgan: ketma-ketlik
  foydalanuvchi uchun ma'lumot
- 25 ta yangi test (jami 126 ta)

**Muhim:** ilovada hali hech qanday audio yoki ruxsat paketi yo'q —
`pubspec.yaml` da faqat `go_router` va `cupertino_icons`.

### TASK 08 — Full-Stack Authentication Foundation

Loyiha shu taskdan boshlab **real full-stack** ilova: Flutter UI, Go API,
PostgreSQL va JWT bir-biri bilan ishlaydi. Mock autentifikatsiya yo'q.

**Backend (Go + Gin + PostgreSQL):**

| Endpoint | Metod | Himoya | Vazifasi |
|---|---|---|---|
| `/health` | GET | ochiq | Servis holati |
| `/api/v1/auth/register` | POST | ochiq | Hisob yaratish |
| `/api/v1/auth/login` | POST | ochiq | Tizimga kirish |
| `/api/v1/auth/me` | GET | JWT | Joriy foydalanuvchi |

Qatlamlar: `handler → service → repository → PostgreSQL`. Biznes mantiq
handler ichida emas — shuning uchun uni HTTP'siz test qilish mumkin.

**Xavfsizlik:**

- Parol `bcrypt` bilan xeshlanadi, hech qachon plain text saqlanmaydi
- Parol xeshi hech qachon API javobiga tushmaydi (`json:"-"` va alohida
  `Public` turi)
- JWT `HS256` bilan imzolanadi, muddati bor, `JWT_SECRET` muhitdan olinadi
- Imzolash usuli aniq cheklangan — `alg: none` hujumi ishlamaydi
- Noto'g'ri parol va mavjud bo'lmagan email **bir xil** javob beradi, aks
  holda qaysi emaillar ro'yxatdan o'tganini aniqlash mumkin bo'lardi
- Email noyobligi bazadagi `UNIQUE` cheklov orqali — bir vaqtdagi ikki
  so'rov dublikat yarata olmaydi

**Flutter:**

- `core/network/ApiClient` — barcha HTTP so'rovlar shu yerdan o'tadi
- `core/storage/TokenStorage` — interfeys; `SecureTokenStorage` iOS
  Keychain'ga yozadi
- `features/auth/` — `domain / data / presentation` qatlamlari
- `AuthController` (Riverpod) — `AuthLoading / Authenticated / Unauthenticated`
- Splash sessiyani tiklaydi va natijaga qarab yo'naltiradi
- Loading holati: tugma o'chiriladi, spinner ko'rinadi, takroriy yuborish
  bloklanadi
- Xato holati: foydalanuvchi uchun yozilgan matn; stack trace hech qachon
  ekranga chiqmaydi

**Testlar:** 19 ta Go testi (haqiqiy PostgreSQL bilan), 156 ta Flutter
testi, 6 ta Flutter↔backend integratsiya testi, 3 ta **haqiqiy qurilmadagi**
integration test.

## Loyiha strukturasi

```
ai-pronunciation-coach/
├── apps/
│   └── mobile/
│       ├── lib/
│       │   ├── main.dart                    kirish nuqtasi (yupqa)
│       │   ├── app.dart                     ildiz widget: mavzu + router
│       │   ├── core/
│       │   │   ├── theme/                   ranglar, bo'shliqlar, ThemeData
│       │   │   └── router/                  route yo'llari va konfiguratsiya
│       │   ├── features/
│       │   │   ├── splash/                  Splash ekrani
│       │   │   ├── welcome/                 Welcome / Value Proposition
│       │   │   ├── onboarding/              Onboarding (3 sahifa)
│       │   │   ├── goal/                    Goal Selection
│       │   │   ├── level/                   English Level Selection
│       │   │   ├── assessment/              Assessment Introduction
│       │   │   ├── auth/                    Register / Login
│       │   │   ├── account/                 sessiya ekrani
│       │   │   └── microphone/              placeholder (keyingi task)
│       │   └── shared/widgets/              BrandMark, AppWordmark,
│       │                                    PrimaryButton, ValuePropositionItem
│       └── test/
├── backend/                                 Go + Gin API
│   ├── cmd/server/                          kirish nuqtasi
│   ├── internal/
│   │   ├── auth/                            bcrypt, JWT, middleware
│   │   ├── config/                          muhit o'zgaruvchilari
│   │   ├── database/                        pgx pool + migratsiyalar
│   │   ├── httperr/                         yagona xato formati
│   │   ├── server/                          route'lar
│   │   └── user/                            model, repository, service, handler
│   ├── migrations/                          SQL migratsiyalar (binarga kiritilgan)
│   └── tests/
├── docs/architecture.md                     arxitektura hujjati
├── infrastructure/docker/
├── scripts/dev-ios.sh                       jonli iOS preview skripti
├── .env.example
└── docker-compose.yml
```

## Talab qilinadigan dasturlar

| Dastur | Versiya |
|---|---|
| Go | 1.25.4 |
| Flutter | 3.47.1 (stable) |
| Dart | 3.13.1 |
| PostgreSQL | 18.6 |
| Xcode | 26.6 (iOS uchun) |
| Android SDK | platform 37, build-tools 37.0.0 |
| Docker | ixtiyoriy — hozircha talab qilinmaydi |

## Mobil ilovani ishga tushirish

**Muhim:** Flutter buyruqlari `apps/mobile/` ichidan bajariladi, chunki
`pubspec.yaml` o'sha yerda. Repozitoriy ildizidan ishlatmang.

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
```

### Jonli iPhone Simulator workflow

Ishlab chiqish iPhone 17 simulyatorida olib boriladi
(iOS 26.5, `29547D37-B063-4C8C-A105-175E97A702F7`).

```bash
scripts/dev-ios.sh start      # simulyatorni yoqadi va ilovani ishga tushiradi
scripts/dev-ios.sh reload     # hot reload
scripts/dev-ios.sh restart    # hot restart
scripts/dev-ios.sh shot       # ekran surati
scripts/dev-ios.sh status
scripts/dev-ios.sh stop
```

Sessiya signal orqali boshqariladi (`SIGUSR1` — hot reload, `SIGUSR2` — hot
restart), `flutter run --pid-file` yordamida. Shu sababli qayta yuklash uchun
interaktiv terminal shart emas.

**Eslatma:** yangi paket (dependency) qo'shilganda hot reload yetarli emas —
to'liq `stop` + `start` kerak bo'ladi.

### Build papkasi nega repozitoriydan tashqarida?

Bu repozitoriy `~/Desktop` ichida joylashgan va u iCloud bilan sinxronlanadi.
iCloud File Provider papkalarga `com.apple.FinderInfo` atributini qo'yadi, va
`codesign` shunday atributga ega framework'ni imzolashdan bosh tortadi:

```
Failed to codesign .../Flutter.framework/Flutter with identity -.
... resource fork, Finder information, or similar detritus not allowed
```

Natijada har bir iOS build muvaffaqiyatsiz tugaydi. Yechim — Flutter'ning
`build/` papkasini iCloud'dan tashqarida saqlash: `apps/mobile/build` bu
`~/.flutter-builds/ai-pronunciation-coach-mobile` ga symlink, uni
`scripts/dev-ios.sh` avtomatik yaratadi. Joyni `FLUTTER_BUILD_DIR` orqali
o'zgartirish mumkin. Android build va `flutter test` bunga bog'liq emas.

## Backend

Backend **ishlaydi va mobil ilovaga ulangan**.

```bash
# 1. PostgreSQL ishlab turishi kerak (Postgres.app yoki boshqa)
createdb ai_pronunciation_coach

# 2. Muhit faylini tayyorlang
cp .env.example .env
# .env ichida DATABASE_URL va JWT_SECRET ni to'ldiring

# 3. Ishga tushiring — migratsiyalar avtomatik qo'llanadi
cd backend
go run ./cmd/server
```

**Eslatma:** bu mashinada 8080-port GitPulse tomonidan band, shuning uchun
`.env` da `PORT=8081` ishlatiladi.

Tekshirish:

```bash
curl http://localhost:8081/health
# {"status":"ok"}

curl -X POST http://localhost:8081/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"name":"Samandar","email":"me@example.com","password":"password123"}'
```

### Migratsiyalar

SQL fayllar `backend/migrations/` da va **binarga joylashtirilgan**
(`go:embed`). Ilova ishga tushganda qo'llanmagan migratsiyalar tartib bilan
bajariladi va `schema_migrations` jadvalida belgilanadi. Tashqi migratsiya
vositasi kerak emas.

Har bir migratsiya tranzaksiya ichida bajariladi — yarim qo'llangan holat
qolmaydi.

### Backend testlari

```bash
cd backend
gofmt -l .
go vet ./...

# Ma'lumotlar bazasiz testlar (JWT, bcrypt, health)
go test ./...

# Haqiqiy PostgreSQL bilan integratsiya testlari
createdb ai_pronunciation_coach_test
TEST_DATABASE_URL="postgres://$USER@localhost:5432/ai_pronunciation_coach_test?sslmode=disable" \
  go test ./...
```

## Muhit o'zgaruvchilari

```bash
cp .env.example .env
```

`.env` git tomonidan e'tiborsiz qoldiriladi. Haqiqiy kalitlarni hech qachon
commit qilmang.

**Backend uchun majburiy:**

| O'zgaruvchi | Izoh |
|---|---|
| `DATABASE_URL` | PostgreSQL ulanish manzili |
| `JWT_SECRET` | Kamida 32 bayt. Standart qiymat **yo'q** — usiz ilova ishga tushmaydi |
| `PORT` | Standart `8080`; bu mashinada `8081` |

`JWT_SECRET` va `DATABASE_URL` uchun ataylab standart qiymat berilmagan:
tasodifan zaif sir bilan productionga chiqib ketishning oldini oladi.

**Flutter uchun:**

API manzili `--dart-define` orqali beriladi:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8081
```

Standart qiymat `http://localhost:8081` — iOS simulyatori host mashinaning
`localhost` iga to'g'ridan-to'g'ri kira oladi. Haqiqiy qurilmada mashinaning
tarmoqdagi IP manzilini berish kerak.

**iOS eslatmasi:** `Info.plist` da `NSAllowsLocalNetworking` yoqilgan, aks
holda iOS `http://localhost` so'rovlarini bloklaydi. Bu faqat lokal tarmoqqa
tegishli — internetdagi `http://` manzillar baribir bloklanadi.

## Testlash

```bash
# Mobil — backend talab qilmaydi
cd apps/mobile
flutter analyze
flutter test

# Mobil — ishlab turgan backend bilan (Flutter tarmoq qatlami -> Go -> Postgres)
flutter test --tags backend --run-skipped

# Mobil — HAQIQIY iPhone simulyatorida, haqiqiy backend bilan
flutter test integration_test/auth_flow_test.dart \
  -d 29547D37-B063-4C8C-A105-175E97A702F7

# Backend
cd backend && gofmt -l . && go vet ./... && go test ./...
```

Test darajalari:

| Daraja | Nima tekshiradi | Backend kerakmi |
|---|---|---|
| Unit / widget | Validatsiya, UI, holat, navigatsiya | yo'q |
| `--tags backend` | `ApiClient → Go → PostgreSQL` | ha |
| `integration_test` | Qurilmada Keychain, ATS, to'liq oqim | ha |

UI taski faqat quyidagilar bajarilgandagina tugagan hisoblanadi:
kod kompilyatsiya bo'ladi → `flutter analyze` toza → testlar o'tadi →
ekran haqiqiy simulyatorda ochiladi va vizual tekshiriladi.

## Git workflow

- Har bir tugagan task uchun bitta mazmunli commit
- Conventional commits: `feat(mobile): ...`, `chore: ...`, `fix: ...`
- Commit body o'zbek tilida va batafsil
- `main` branch'ga push
- **Force push qilinmaydi**, git tarixi qayta yozilmaydi
- Push GitPulse webhook orqali Telegram'ga bildirishnoma yuboradi

## Hali qilinmagan ishlar

Quyidagilar **implement qilinmagan**:

- Microphone Permission (haqiqiy ruxsat so'rovi)
- Audio yozib olish va yuklash
- Talaffuz tahlili va provider integratsiyasi (Azure Speech / SpeechAce)
- Scoring engine
- Natija ekrani
- Profil saqlash (goal va level hozircha faqat ekran holatida)
- Obuna va RevenueCat
- Home Dashboard, Practice, Progress
- Refresh token va token yangilash
- Analytics

To'liq arxitektura tahlili, xarajat modeli va risklar ro'yxati:
[docs/architecture.md](docs/architecture.md).
