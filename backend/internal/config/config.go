// Package config ilova sozlamalarini muhit o'zgaruvchilaridan o'qiydi.
package config

import (
	"errors"
	"fmt"
	"os"
	"time"
)

// Config ilovaning ishlashi uchun zarur sozlamalar.
type Config struct {
	Port        string
	DatabaseURL string

	// JWTSecret tokenlarni imzolash uchun. Hech qachon kodga yozilmaydi.
	JWTSecret []byte

	// TokenTTL access token qancha vaqt amal qilishi.
	TokenTTL time.Duration
}

// ErrMissingJWTSecret JWT_SECRET berilmaganda qaytariladi.
var ErrMissingJWTSecret = errors.New("JWT_SECRET is required")

// ErrMissingDatabaseURL DATABASE_URL berilmaganda qaytariladi.
var ErrMissingDatabaseURL = errors.New("DATABASE_URL is required")

// Load muhit o'zgaruvchilarini o'qiydi va tekshiradi.
//
// Sir qiymatlar (JWT_SECRET, DATABASE_URL) uchun standart qiymat berilmaydi —
// ular bo'lmasa ilova ishga tushmaydi. Bu tasodifan zaif standart sir bilan
// ishlab ketishning oldini oladi.
func Load() (*Config, error) {
	cfg := &Config{
		Port:        envOr("PORT", "8080"),
		DatabaseURL: os.Getenv("DATABASE_URL"),
		JWTSecret:   []byte(os.Getenv("JWT_SECRET")),
		TokenTTL:    24 * time.Hour,
	}

	if cfg.DatabaseURL == "" {
		return nil, ErrMissingDatabaseURL
	}
	if len(cfg.JWTSecret) == 0 {
		return nil, ErrMissingJWTSecret
	}
	if len(cfg.JWTSecret) < 32 {
		return nil, fmt.Errorf("JWT_SECRET must be at least 32 bytes, got %d", len(cfg.JWTSecret))
	}

	return cfg, nil
}

func envOr(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
