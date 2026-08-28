CREATE TABLE IF NOT EXISTS practice_sessions (
    id                   UUID PRIMARY KEY,
    user_id              UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- created -> recording -> completed | cancelled
    -- failed  -- kutilmagan xatolik uchun
    status               TEXT        NOT NULL,

    started_at           TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Yozib olish haqiqatan boshlangan payt. Davomiylik shu vaqtdan
    -- hisoblanadi, sessiya yaratilgan vaqtdan emas — foydalanuvchi ekranni
    -- ochib, bir muddat kutib turishi mumkin.
    recording_started_at TIMESTAMPTZ,

    completed_at         TIMESTAMPTZ,

    -- Server tomonidan hisoblangan davomiylik. Mijoz yuborgan qiymatga
    -- tayanilmaydi.
    duration_seconds     INTEGER,

    -- Audio faylga havola. Hozircha fayl faqat qurilmada saqlanadi va
    -- serverga yuklanmaydi, shuning uchun bu maydon bo'sh qoladi.
    audio_reference      TEXT,

    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Foydalanuvchining sessiyalarini vaqt bo'yicha o'qish uchun.
CREATE INDEX IF NOT EXISTS practice_sessions_user_started_idx
    ON practice_sessions (user_id, started_at DESC);
