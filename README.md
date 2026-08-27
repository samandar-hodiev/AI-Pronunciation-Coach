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
01. Splash                              ✅
02. Welcome / Value Proposition         ✅
03. Onboarding                          ✅
04. Goal Selection                      ✅
05. English Level Selection             ✅
06. Pronunciation Assessment Intro      ✅
07. Microphone Permission               ⏳ hozircha placeholder
08. First Pronunciation Test            ⏳
09. Pronunciation Analysis              ⏳
10. First Result                        ⏳
11. Create Account / Login              ⏳
12. Profile / Personalization           ⏳
13. Free / Premium Introduction         ⏳
14. Home Dashboard                      ⏳
```

`✅` faqat haqiqatda implement qilingan ekranlar uchun qo'yiladi.
`⏳` — hali yaratilmagan yoki vaqtinchalik placeholder.

Hozirda **haqiqatda ishlaydigan** oqim:

```
App launch → Splash → Welcome → Onboarding → Goal Selection → English Level
            → Assessment Introduction → Microphone Permission (placeholder)
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
│       │   │   └── microphone/              placeholder (TASK 08)
│       │   └── shared/widgets/              BrandMark, AppWordmark,
│       │                                    PrimaryButton, ValuePropositionItem
│       └── test/
├── backend/                                 Go + Gin API
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

Backend hali mobil ilovaga **ulanmagan**. Hozircha faqat `GET /health` mavjud.

```bash
cd backend
go mod download
PORT=8081 go run ./cmd/server     # 8080 GitPulse tomonidan band
curl http://localhost:8081/health # {"status":"ok"}
```

Tekshiruvlar:

```bash
cd backend
gofmt -l .
go vet ./...
go test ./...
go build ./cmd/server
```

## Muhit o'zgaruvchilari

```bash
cp .env.example .env
```

`.env` git tomonidan e'tiborsiz qoldiriladi. Haqiqiy kalitlarni hech qachon
commit qilmang. `.env.example` dagi o'zgaruvchilar hozircha **kod tomonidan
o'qilmaydi** — ular faqat kelajakdagi konfiguratsiyani hujjatlashtiradi.

## Testlash

```bash
# Mobil
cd apps/mobile && flutter analyze && flutter test

# Backend
cd backend && gofmt -l . && go vet ./... && go test ./...
```

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

Quyidagilar **implement qilinmagan** va hozircha rejalashtirilgan holatda:

- Microphone Permission ekrani va haqiqiy ruxsat so'rovi
- Autentifikatsiya, JWT, foydalanuvchi profili
- Audio yozib olish va yuklash
- Talaffuz tahlili va provider integratsiyasi (Azure Speech / SpeechAce)
- Scoring engine
- Mashq va progress kuzatuvi
- Obuna va RevenueCat
- Ma'lumotlar bazasi sxemasi va migratsiyalar
- Home Dashboard

To'liq arxitektura tahlili, xarajat modeli va risklar ro'yxati:
[docs/architecture.md](docs/architecture.md).
