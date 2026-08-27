package user

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Repozitoriy xatolari.
var (
	ErrNotFound   = errors.New("user not found")
	ErrEmailTaken = errors.New("email already registered")
)

// Repository foydalanuvchi yozuvlarini saqlaydi va o'qiydi.
type Repository interface {
	Create(ctx context.Context, u User) error
	FindByEmail(ctx context.Context, email string) (User, error)
	FindByID(ctx context.Context, id string) (User, error)
}

// PostgresRepository [Repository] ning PostgreSQL implementatsiyasi.
type PostgresRepository struct {
	pool *pgxpool.Pool
}

// NewPostgresRepository yangi repozitoriy yaratadi.
func NewPostgresRepository(pool *pgxpool.Pool) *PostgresRepository {
	return &PostgresRepository{pool: pool}
}

const uniqueViolationCode = "23505"

// Create yangi foydalanuvchi qo'shadi.
//
// Email noyobligi bazadagi UNIQUE cheklov orqali ta'minlanadi, oldindan
// SELECT qilish orqali emas — aks holda ikki bir vaqtdagi so'rov ikkalasi
// ham "bo'sh" deb topib, dublikat yaratishi mumkin edi.
func (r *PostgresRepository) Create(ctx context.Context, u User) error {
	_, err := r.pool.Exec(ctx, `
		INSERT INTO users (id, name, email, password_hash, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)`,
		u.ID, u.Name, u.Email, u.PasswordHash, u.CreatedAt, u.UpdatedAt,
	)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == uniqueViolationCode {
			return ErrEmailTaken
		}
		return fmt.Errorf("insert user: %w", err)
	}
	return nil
}

// FindByEmail emailga ko'ra foydalanuvchini topadi.
func (r *PostgresRepository) FindByEmail(ctx context.Context, email string) (User, error) {
	return r.queryOne(ctx, `
		SELECT id, name, email, password_hash, created_at, updated_at
		FROM users WHERE email = $1`, strings.TrimSpace(email))
}

// FindByID identifikatorga ko'ra foydalanuvchini topadi.
func (r *PostgresRepository) FindByID(ctx context.Context, id string) (User, error) {
	return r.queryOne(ctx, `
		SELECT id, name, email, password_hash, created_at, updated_at
		FROM users WHERE id = $1`, id)
}

func (r *PostgresRepository) queryOne(ctx context.Context, query string, arg any) (User, error) {
	var u User
	err := r.pool.QueryRow(ctx, query, arg).Scan(
		&u.ID, &u.Name, &u.Email, &u.PasswordHash, &u.CreatedAt, &u.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return User{}, ErrNotFound
	}
	if err != nil {
		return User{}, fmt.Errorf("query user: %w", err)
	}
	return u, nil
}
