package tests

import (
	"context"
	"net/http"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/auth"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/database"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/practice"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/server"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/user"
)

// newPracticeAPI auth va mashq yo'llari ulangan API qaytaradi.
func newPracticeAPI(t *testing.T) (*gin.Engine, *pgxpool.Pool) {
	t.Helper()

	url := testDatabaseURL()
	if url == "" {
		t.Skip("TEST_DATABASE_URL is not set; skipping database integration test")
	}

	gin.SetMode(gin.TestMode)
	ctx := context.Background()

	pool, err := database.Connect(ctx, url)
	if err != nil {
		t.Fatalf("connect test database: %v", err)
	}
	t.Cleanup(pool.Close)

	if err := database.Migrate(ctx, pool); err != nil {
		t.Fatalf("migrate: %v", err)
	}
	if _, err := pool.Exec(ctx, "TRUNCATE users CASCADE"); err != nil {
		t.Fatalf("truncate: %v", err)
	}

	tokens := auth.NewTokenIssuer(testSecret, time.Hour)

	router := server.NewRouter(server.Deps{
		Users: user.NewHandler(
			user.NewService(user.NewPostgresRepository(pool), tokens),
		),
		Practice: practice.NewHandler(
			practice.NewService(practice.NewPostgresRepository(pool)),
		),
		Tokens: tokens,
	})

	return router, pool
}

const practicePath = "/api/v1/practice/sessions"

// createSession yangi sessiya yaratadi va uni qaytaradi.
func createSession(t *testing.T, router *gin.Engine, token string) map[string]any {
	t.Helper()

	rec := doJSON(t, router, http.MethodPost, practicePath, nil, token)
	if rec.Code != http.StatusCreated {
		t.Fatalf("create status = %d (body: %s)", rec.Code, rec.Body)
	}
	return decode(t, rec)["data"].(map[string]any)["session"].(map[string]any)
}

func post(t *testing.T, router *gin.Engine, path, token string) (int, map[string]any) {
	t.Helper()

	rec := doJSON(t, router, http.MethodPost, path, nil, token)
	return rec.Code, decode(t, rec)
}

func sessionFrom(body map[string]any) map[string]any {
	data, ok := body["data"].(map[string]any)
	if !ok {
		return nil
	}
	session, _ := data["session"].(map[string]any)
	return session
}

func TestPracticeRequiresAuthentication(t *testing.T) {
	router, _ := newPracticeAPI(t)

	requests := []struct {
		method string
		path   string
	}{
		{http.MethodPost, practicePath},
		{http.MethodGet, practicePath + "/some-id"},
		{http.MethodPost, practicePath + "/some-id/start"},
		{http.MethodPost, practicePath + "/some-id/complete"},
		{http.MethodPost, practicePath + "/some-id/cancel"},
	}

	for _, token := range []string{"", "not-a-real-token"} {
		for _, req := range requests {
			rec := doJSON(t, router, req.method, req.path, nil, token)
			if rec.Code != http.StatusUnauthorized {
				t.Errorf("%s %s with token %q: status = %d, want 401",
					req.method, req.path, token, rec.Code)
			}
		}
	}
}

func TestPracticeCreateStoresSessionForUser(t *testing.T) {
	router, pool := newPracticeAPI(t)
	token := registerUser(t, router, "practice@example.com")

	session := createSession(t, router, token)

	if session["status"] != "created" {
		t.Errorf("status = %v, want created", session["status"])
	}
	if session["id"] == "" {
		t.Error("id must not be empty")
	}
	if session["duration_seconds"] != nil {
		t.Errorf("duration = %v, want nil for a new session",
			session["duration_seconds"])
	}
	// Mijozga user_id oshkor qilinmasligi kerak.
	if _, leaked := session["user_id"]; leaked {
		t.Error("response leaked user_id")
	}

	// Sessiya haqiqatan bazada va to'g'ri foydalanuvchiga bog'langan.
	var count int
	if err := pool.QueryRow(context.Background(), `
		SELECT count(*) FROM practice_sessions p
		JOIN users u ON u.id = p.user_id
		WHERE p.id = $1 AND u.email = $2`,
		session["id"], "practice@example.com",
	).Scan(&count); err != nil {
		t.Fatalf("count sessions: %v", err)
	}
	if count != 1 {
		t.Errorf("sessions in database = %d, want 1", count)
	}
}

func TestPracticeFullLifecycle(t *testing.T) {
	router, pool := newPracticeAPI(t)
	token := registerUser(t, router, "lifecycle@example.com")

	session := createSession(t, router, token)
	id := session["id"].(string)

	// created -> recording
	status, body := post(t, router, practicePath+"/"+id+"/start", token)
	if status != http.StatusOK {
		t.Fatalf("start status = %d", status)
	}
	if sessionFrom(body)["status"] != "recording" {
		t.Errorf("status = %v, want recording", sessionFrom(body)["status"])
	}

	// Yozuv davomiyligi seziladigan bo'lishi uchun biroz kutamiz.
	time.Sleep(1100 * time.Millisecond)

	// recording -> completed
	status, body = post(t, router, practicePath+"/"+id+"/complete", token)
	if status != http.StatusOK {
		t.Fatalf("complete status = %d", status)
	}

	completed := sessionFrom(body)
	if completed["status"] != "completed" {
		t.Errorf("status = %v, want completed", completed["status"])
	}
	if completed["completed_at"] == nil {
		t.Error("completed_at must be set")
	}

	// Davomiylik server vaqtlaridan hisoblanadi.
	duration, ok := completed["duration_seconds"].(float64)
	if !ok {
		t.Fatalf("duration_seconds = %v, want a number", completed["duration_seconds"])
	}
	if duration < 1 || duration > 5 {
		t.Errorf("duration = %v, want roughly 1 second", duration)
	}

	// Bazada ham saqlangan bo'lishi kerak.
	var dbStatus string
	var dbDuration int
	if err := pool.QueryRow(context.Background(),
		"SELECT status, duration_seconds FROM practice_sessions WHERE id = $1", id,
	).Scan(&dbStatus, &dbDuration); err != nil {
		t.Fatalf("read session: %v", err)
	}
	if dbStatus != "completed" || dbDuration < 1 {
		t.Errorf("database has status=%q duration=%d", dbStatus, dbDuration)
	}
}

func TestPracticeRejectsInvalidTransitions(t *testing.T) {
	router, _ := newPracticeAPI(t)
	token := registerUser(t, router, "transitions@example.com")

	t.Run("complete before start", func(t *testing.T) {
		id := createSession(t, router, token)["id"].(string)

		status, _ := post(t, router, practicePath+"/"+id+"/complete", token)
		if status != http.StatusConflict {
			t.Errorf("status = %d, want 409", status)
		}
	})

	t.Run("start after complete", func(t *testing.T) {
		id := createSession(t, router, token)["id"].(string)
		post(t, router, practicePath+"/"+id+"/start", token)
		post(t, router, practicePath+"/"+id+"/complete", token)

		status, _ := post(t, router, practicePath+"/"+id+"/start", token)
		if status != http.StatusConflict {
			t.Errorf("status = %d, want 409", status)
		}
	})

	t.Run("cancel after complete", func(t *testing.T) {
		id := createSession(t, router, token)["id"].(string)
		post(t, router, practicePath+"/"+id+"/start", token)
		post(t, router, practicePath+"/"+id+"/complete", token)

		status, _ := post(t, router, practicePath+"/"+id+"/cancel", token)
		if status != http.StatusConflict {
			t.Errorf("status = %d, want 409", status)
		}
	})
}

func TestPracticeDuplicateCompletionIsSafe(t *testing.T) {
	router, _ := newPracticeAPI(t)
	token := registerUser(t, router, "duplicate@example.com")

	id := createSession(t, router, token)["id"].(string)
	post(t, router, practicePath+"/"+id+"/start", token)

	_, first := post(t, router, practicePath+"/"+id+"/complete", token)
	status, second := post(t, router, practicePath+"/"+id+"/complete", token)

	// Takroriy so'rov xato bermaydi va natijani o'zgartirmaydi — tarmoq
	// qayta urinishi sessiyani buzmasligi kerak.
	if status != http.StatusOK {
		t.Errorf("second complete status = %d, want 200", status)
	}
	if sessionFrom(first)["completed_at"] != sessionFrom(second)["completed_at"] {
		t.Error("repeated completion changed completed_at")
	}
	if sessionFrom(first)["duration_seconds"] != sessionFrom(second)["duration_seconds"] {
		t.Error("repeated completion changed the duration")
	}
}

func TestPracticeCancel(t *testing.T) {
	router, _ := newPracticeAPI(t)
	token := registerUser(t, router, "cancel@example.com")

	id := createSession(t, router, token)["id"].(string)
	post(t, router, practicePath+"/"+id+"/start", token)

	status, body := post(t, router, practicePath+"/"+id+"/cancel", token)
	if status != http.StatusOK {
		t.Fatalf("cancel status = %d", status)
	}
	if sessionFrom(body)["status"] != "cancelled" {
		t.Errorf("status = %v, want cancelled", sessionFrom(body)["status"])
	}
}

func TestPracticeSessionIsolatedBetweenUsers(t *testing.T) {
	router, _ := newPracticeAPI(t)

	tokenA := registerUser(t, router, "owner-a@example.com")
	tokenB := registerUser(t, router, "other-b@example.com")

	id := createSession(t, router, tokenA)["id"].(string)

	// B A ning sessiyasini o'qiy olmasligi kerak.
	rec := doJSON(t, router, http.MethodGet, practicePath+"/"+id, nil, tokenB)
	if rec.Code != http.StatusNotFound {
		t.Errorf("get status = %d, want 404 (existence must not leak)", rec.Code)
	}

	// B uni o'zgartira ham olmasligi kerak.
	for _, action := range []string{"start", "complete", "cancel"} {
		status, _ := post(t, router, practicePath+"/"+id+"/"+action, tokenB)
		if status != http.StatusNotFound {
			t.Errorf("%s status = %d, want 404", action, status)
		}
	}

	// A ning sessiyasi tegilmagan bo'lishi kerak.
	rec = doJSON(t, router, http.MethodGet, practicePath+"/"+id, nil, tokenA)
	if rec.Code != http.StatusOK {
		t.Fatalf("owner get status = %d", rec.Code)
	}
	if sessionFrom(decode(t, rec))["status"] != "created" {
		t.Error("another user changed the session")
	}
}

func TestPracticeUnknownSessionReturnsNotFound(t *testing.T) {
	router, _ := newPracticeAPI(t)
	token := registerUser(t, router, "unknown@example.com")

	rec := doJSON(t, router, http.MethodGet,
		practicePath+"/11111111-1111-1111-1111-111111111111", nil, token)
	if rec.Code != http.StatusNotFound {
		t.Errorf("status = %d, want 404", rec.Code)
	}
}
