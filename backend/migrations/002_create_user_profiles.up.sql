CREATE TABLE IF NOT EXISTS user_profiles (
    -- Bitta foydalanuvchi — bitta profil. user_id ayni paytda birlamchi
    -- kalit: alohida id ustuni qo'shish ortiqcha bo'lardi.
    user_id             UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,

    -- Hozircha faqat 'en'. Ustun kelajakda kengaytirish uchun turibdi,
    -- lekin UI'da tanlov yo'q — mahsulot faqat ingliz talaffuzi uchun.
    learning_language   TEXT        NOT NULL DEFAULT 'en',

    -- Talaffuz maqsadi va darajasi ilovadagi mavjud ro'yxatlardan keladi
    -- (GoalOptions va EnglishLevels). Sozlash tugagunicha NULL bo'lishi
    -- mumkin.
    pronunciation_goal  TEXT,
    pronunciation_level TEXT,

    -- Kunlik mashq maqsadi, daqiqada.
    daily_goal_minutes  INTEGER,

    setup_completed     BOOLEAN     NOT NULL DEFAULT FALSE,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
