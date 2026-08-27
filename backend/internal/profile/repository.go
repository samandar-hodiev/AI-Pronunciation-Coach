package profile

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// ErrUserNotFound profil so'ralgan foydalanuvchi mavjud bo'lmaganda
// qaytariladi (masalan, token yaroqli, lekin hisob o'chirilgan).
var ErrUserNotFound = errors.New("user not found")

// Repository profil yozuvlarini saqlaydi va o'qiydi.
type Repository interface {
	// GetOrCreate profilni qaytaradi; mavjud bo'lmasa bo'sh profil yaratadi.
	GetOrCreate(ctx context.Context, userID string) (Profile, string, error)

	// Save profil maydonlarini va foydalanuvchi ismini yangilaydi.
	Save(ctx context.Context, userID string, in SaveInput) (Profile, string, error)
}

// SaveInput saqlanadigan qiymatlar. Barchasi allaqachon tekshirilgan.
type SaveInput struct {
	Name               string
	LearningLanguage   string
	PronunciationGoal  string
	PronunciationLevel string
	DailyGoalMinutes   int
}

// PostgresRepository [Repository] ning PostgreSQL implementatsiyasi.
type PostgresRepository struct {
	pool *pgxpool.Pool
}

// NewPostgresRepository yangi repozitoriy yaratadi.
func NewPostgresRepository(pool *pgxpool.Pool) *PostgresRepository {
	return &PostgresRepository{pool: pool}
}

const selectProfile = `
	SELECT p.user_id, p.learning_language, p.pronunciation_goal,
	       p.pronunciation_level, p.daily_goal_minutes, p.setup_completed,
	       p.created_at, p.updated_at, u.name
	FROM user_profiles p
	JOIN users u ON u.id = p.user_id
	WHERE p.user_id = $1`

// GetOrCreate profilni qaytaradi, kerak bo'lsa avval yaratadi.
//
// Profil ro'yxatdan o'tishda emas, birinchi so'rovda yaratiladi. Shu sababli
// TASK 08 dan oldin yaratilgan foydalanuvchilar ham qo'shimcha migratsiyasiz
// ishlaydi.
func (r *PostgresRepository) GetOrCreate(ctx context.Context, userID string) (Profile, string, error) {
	tag, err := r.pool.Exec(ctx, `
		INSERT INTO user_profiles (user_id)
		VALUES ($1)
		ON CONFLICT (user_id) DO NOTHING`, userID)
	if err != nil {
		// Foydalanuvchi mavjud emas — tashqi kalit cheklovi ishlaydi.
		return Profile{}, "", fmt.Errorf("ensure profile: %w", err)
	}
	_ = tag

	return r.read(ctx, userID)
}

// Save profil va ism yangilanishini bitta tranzaksiyada bajaradi.
//
// Ikkalasi birga o'zgaradi: agar ism saqlanib, profil saqlanmasa,
// foydalanuvchi yarim sozlangan holatda qolardi.
func (r *PostgresRepository) Save(ctx context.Context, userID string, in SaveInput) (Profile, string, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return Profile{}, "", fmt.Errorf("begin: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	tag, err := tx.Exec(ctx, `
		UPDATE users SET name = $2, updated_at = now() WHERE id = $1`,
		userID, in.Name)
	if err != nil {
		return Profile{}, "", fmt.Errorf("update user name: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return Profile{}, "", ErrUserNotFound
	}

	if _, err := tx.Exec(ctx, `
		INSERT INTO user_profiles (
			user_id, learning_language, pronunciation_goal,
			pronunciation_level, daily_goal_minutes, setup_completed, updated_at
		) VALUES ($1, $2, $3, $4, $5, TRUE, now())
		ON CONFLICT (user_id) DO UPDATE SET
			learning_language   = EXCLUDED.learning_language,
			pronunciation_goal  = EXCLUDED.pronunciation_goal,
			pronunciation_level = EXCLUDED.pronunciation_level,
			daily_goal_minutes  = EXCLUDED.daily_goal_minutes,
			setup_completed     = TRUE,
			updated_at          = now()`,
		userID, in.LearningLanguage, in.PronunciationGoal,
		in.PronunciationLevel, in.DailyGoalMinutes,
	); err != nil {
		return Profile{}, "", fmt.Errorf("upsert profile: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return Profile{}, "", fmt.Errorf("commit: %w", err)
	}

	return r.read(ctx, userID)
}

func (r *PostgresRepository) read(ctx context.Context, userID string) (Profile, string, error) {
	var p Profile
	var name string

	err := r.pool.QueryRow(ctx, selectProfile, userID).Scan(
		&p.UserID, &p.LearningLanguage, &p.PronunciationGoal,
		&p.PronunciationLevel, &p.DailyGoalMinutes, &p.SetupCompleted,
		&p.CreatedAt, &p.UpdatedAt, &name,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return Profile{}, "", ErrUserNotFound
	}
	if err != nil {
		return Profile{}, "", fmt.Errorf("read profile: %w", err)
	}

	return p, name, nil
}
