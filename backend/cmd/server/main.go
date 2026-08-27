// Command server AI Pronunciation Coach HTTP API'sini ishga tushiradi.
package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/joho/godotenv"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/auth"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/config"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/database"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/server"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/user"
)

// shutdownTimeout ishlayotgan so'rovlarga tugash uchun beriladigan vaqt.
const shutdownTimeout = 10 * time.Second

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)

	// Lokal ishlab chiqishda `.env` o'qiladi. Fayl bo'lmasa xato emas —
	// productionda o'zgaruvchilar muhitdan keladi.
	_ = godotenv.Load(".env", "../.env")

	if err := run(); err != nil {
		logger.Error("server exited with error", "error", err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}

	ctx := context.Background()

	pool, err := database.Connect(ctx, cfg.DatabaseURL)
	if err != nil {
		return err
	}
	defer pool.Close()

	if err := database.Migrate(ctx, pool); err != nil {
		return err
	}

	tokens := auth.NewTokenIssuer(cfg.JWTSecret, cfg.TokenTTL)
	repo := user.NewPostgresRepository(pool)
	service := user.NewService(repo, tokens)
	handler := user.NewHandler(service)

	addr := ":" + cfg.Port
	srv := &http.Server{
		Addr:              addr,
		Handler:           server.NewRouter(server.Deps{Users: handler, Tokens: tokens}),
		ReadHeaderTimeout: 10 * time.Second,
	}

	errCh := make(chan error, 1)
	go func() {
		slog.Info("http server listening", "addr", addr)
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errCh <- err
		}
	}()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)

	select {
	case err := <-errCh:
		return err
	case sig := <-stop:
		slog.Info("shutdown signal received", "signal", sig.String())
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()

	if err := srv.Shutdown(shutdownCtx); err != nil {
		return err
	}

	slog.Info("server stopped cleanly")
	return nil
}
