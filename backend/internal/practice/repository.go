package practice

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Repository sessiya yozuvlarini saqlaydi va o'qiydi.
//
// Barcha metodlar `userID` oladi: egalik tekshiruvi SQL darajasida
// bajariladi, shuning uchun boshqa foydalanuvchining sessiyasini o'qish yoki
// o'zgartirish imkoni yo'q.
type Repository interface {
	Create(ctx context.Context, s Session) error
	Find(ctx context.Context, userID, sessionID string) (Session, error)
	Update(ctx context.Context, userID string, s Session) error
}

// PostgresRepository [Repository] ning PostgreSQL implementatsiyasi.
type PostgresRepository struct {
	pool *pgxpool.Pool
}

// NewPostgresRepository yangi repozitoriy yaratadi.
func NewPostgresRepository(pool *pgxpool.Pool) *PostgresRepository {
	return &PostgresRepository{pool: pool}
}

const selectSession = `
	SELECT id, user_id, status, started_at, recording_started_at,
	       completed_at, duration_seconds, audio_reference,
	       created_at, updated_at
	FROM practice_sessions
	WHERE id = $1 AND user_id = $2`

// Create yangi sessiya qo'shadi.
func (r *PostgresRepository) Create(ctx context.Context, s Session) error {
	_, err := r.pool.Exec(ctx, `
		INSERT INTO practice_sessions (
			id, user_id, status, started_at, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $5)`,
		s.ID, s.UserID, string(s.Status), s.StartedAt, s.CreatedAt,
	)
	if err != nil {
		return fmt.Errorf("insert practice session: %w", err)
	}
	return nil
}

// Find sessiyani topadi.
//
// Sessiya boshqa foydalanuvchiga tegishli bo'lsa ham [ErrNotFound]
// qaytariladi — mavjudligi oshkor qilinmaydi.
func (r *PostgresRepository) Find(ctx context.Context, userID, sessionID string) (Session, error) {
	var s Session
	var status string

	err := r.pool.QueryRow(ctx, selectSession, sessionID, userID).Scan(
		&s.ID, &s.UserID, &status, &s.StartedAt, &s.RecordingStartedAt,
		&s.CompletedAt, &s.DurationSeconds, &s.AudioReference,
		&s.CreatedAt, &s.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return Session{}, ErrNotFound
	}
	if err != nil {
		return Session{}, fmt.Errorf("query practice session: %w", err)
	}

	s.Status = Status(status)
	return s, nil
}

// Update sessiyani yangilaydi.
//
// `WHERE user_id` sharti egalik tekshiruvini takrorlaydi: xizmat qatlamida
// xato bo'lsa ham begona yozuv o'zgarmaydi.
func (r *PostgresRepository) Update(ctx context.Context, userID string, s Session) error {
	tag, err := r.pool.Exec(ctx, `
		UPDATE practice_sessions SET
			status               = $3,
			recording_started_at = $4,
			completed_at         = $5,
			duration_seconds     = $6,
			audio_reference      = $7,
			updated_at           = $8
		WHERE id = $1 AND user_id = $2`,
		s.ID, userID, string(s.Status), s.RecordingStartedAt,
		s.CompletedAt, s.DurationSeconds, s.AudioReference, time.Now().UTC(),
	)
	if err != nil {
		return fmt.Errorf("update practice session: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}
