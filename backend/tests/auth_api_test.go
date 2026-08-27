package tests

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/auth"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/database"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/server"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/user"
)

// testDatabaseURL haqiqiy PostgreSQL bazasiga ulanish manzili.
//
// TEST_DATABASE_URL berilmagan bo'lsa testlar o'tkazib yuboriladi — CI'da
// baza bo'lmasa ham qolgan testlar ishlashi kerak.
func testDatabaseURL() string {
	if url := os.Getenv("TEST_DATABASE_URL"); url != "" {
		return url
	}
	return ""
}

// newTestAPI haqiqiy bazaga ulangan API va uning bazasini qaytaradi.
//
// Har bir test o'z toza jadvalidan boshlaydi.
func newTestAPI(t *testing.T) (*gin.Engine, *pgxpool.Pool) {
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
		t.Fatalf("migrate test database: %v", err)
	}
	// CASCADE kerak: user_profiles jadvali users'ga tashqi kalit bilan
	// bog'langan.
	if _, err := pool.Exec(ctx, "TRUNCATE users CASCADE"); err != nil {
		t.Fatalf("truncate users: %v", err)
	}

	tokens := auth.NewTokenIssuer(testSecret, time.Hour)
	service := user.NewService(user.NewPostgresRepository(pool), tokens)
	router := server.NewRouter(server.Deps{
		Users:  user.NewHandler(service),
		Tokens: tokens,
	})

	return router, pool
}

func doJSON(t *testing.T, router *gin.Engine, method, path string, body any, token string) *httptest.ResponseRecorder {
	t.Helper()

	var payload []byte
	if body != nil {
		var err error
		payload, err = json.Marshal(body)
		if err != nil {
			t.Fatalf("marshal body: %v", err)
		}
	}

	req := httptest.NewRequest(method, path, bytes.NewReader(payload))
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, req)
	return rec
}

func decode(t *testing.T, rec *httptest.ResponseRecorder) map[string]any {
	t.Helper()
	var out map[string]any
	if err := json.Unmarshal(rec.Body.Bytes(), &out); err != nil {
		t.Fatalf("decode response: %v (raw: %s)", err, rec.Body.String())
	}
	return out
}

func registerBody(email string) map[string]string {
	return map[string]string{
		"name":     "Samandar",
		"email":    email,
		"password": "password123",
	}
}

func TestRegisterCreatesUserInDatabase(t *testing.T) {
	router, pool := newTestAPI(t)

	rec := doJSON(t, router, http.MethodPost, "/api/v1/auth/register",
		registerBody("new@example.com"), "")

	if rec.Code != http.StatusCreated {
		t.Fatalf("status = %d, want %d (body: %s)", rec.Code, http.StatusCreated, rec.Body)
	}

	body := decode(t, rec)
	data := body["data"].(map[string]any)
	userData := data["user"].(map[string]any)

	if userData["email"] != "new@example.com" {
		t.Errorf("email = %v", userData["email"])
	}
	if data["access_token"] == "" {
		t.Error("access_token must not be empty")
	}

	// Foydalanuvchi haqiqatan bazada bo'lishi kerak.
	var count int
	if err := pool.QueryRow(context.Background(),
		"SELECT count(*) FROM users WHERE email = $1", "new@example.com",
	).Scan(&count); err != nil {
		t.Fatalf("count users: %v", err)
	}
	if count != 1 {
		t.Errorf("users in database = %d, want 1", count)
	}
}

func TestRegisterNeverReturnsOrStoresPlainPassword(t *testing.T) {
	router, pool := newTestAPI(t)

	rec := doJSON(t, router, http.MethodPost, "/api/v1/auth/register",
		registerBody("secure@example.com"), "")
	if rec.Code != http.StatusCreated {
		t.Fatalf("status = %d", rec.Code)
	}

	if bytes.Contains(rec.Body.Bytes(), []byte("password123")) {
		t.Error("response body leaked the plain password")
	}
	if bytes.Contains(rec.Body.Bytes(), []byte("password_hash")) {
		t.Error("response body leaked the password hash field")
	}

	var stored string
	if err := pool.QueryRow(context.Background(),
		"SELECT password_hash FROM users WHERE email = $1", "secure@example.com",
	).Scan(&stored); err != nil {
		t.Fatalf("read hash: %v", err)
	}
	if stored == "password123" {
		t.Fatal("password was stored in plain text")
	}
	if !auth.VerifyPassword(stored, "password123") {
		t.Error("stored hash does not verify against the original password")
	}
}

func TestRegisterRejectsDuplicateEmail(t *testing.T) {
	router, _ := newTestAPI(t)

	first := doJSON(t, router, http.MethodPost, "/api/v1/auth/register",
		registerBody("dupe@example.com"), "")
	if first.Code != http.StatusCreated {
		t.Fatalf("first register status = %d", first.Code)
	}

	second := doJSON(t, router, http.MethodPost, "/api/v1/auth/register",
		registerBody("dupe@example.com"), "")

	if second.Code != http.StatusConflict {
		t.Fatalf("status = %d, want %d", second.Code, http.StatusConflict)
	}
	errObj := decode(t, second)["error"].(map[string]any)
	if errObj["code"] != "EMAIL_ALREADY_REGISTERED" {
		t.Errorf("error code = %v", errObj["code"])
	}
}

func TestRegisterIsCaseInsensitiveOnEmail(t *testing.T) {
	router, _ := newTestAPI(t)

	doJSON(t, router, http.MethodPost, "/api/v1/auth/register",
		registerBody("Mixed@Example.com"), "")

	second := doJSON(t, router, http.MethodPost, "/api/v1/auth/register",
		registerBody("mixed@example.com"), "")

	if second.Code != http.StatusConflict {
		t.Errorf("status = %d, want %d — email uniqueness must ignore case",
			second.Code, http.StatusConflict)
	}
}

func TestRegisterValidatesInput(t *testing.T) {
	router, _ := newTestAPI(t)

	cases := map[string]map[string]string{
		"empty name":     {"name": "", "email": "a@example.com", "password": "password123"},
		"invalid email":  {"name": "A", "email": "not-an-email", "password": "password123"},
		"short password": {"name": "A", "email": "b@example.com", "password": "short"},
	}

	for name, body := range cases {
		t.Run(name, func(t *testing.T) {
			rec := doJSON(t, router, http.MethodPost, "/api/v1/auth/register", body, "")
			if rec.Code != http.StatusUnprocessableEntity {
				t.Errorf("status = %d, want %d", rec.Code, http.StatusUnprocessableEntity)
			}
		})
	}
}

func TestLoginSucceedsWithCorrectPassword(t *testing.T) {
	router, _ := newTestAPI(t)

	doJSON(t, router, http.MethodPost, "/api/v1/auth/register",
		registerBody("login@example.com"), "")

	rec := doJSON(t, router, http.MethodPost, "/api/v1/auth/login", map[string]string{
		"email":    "login@example.com",
		"password": "password123",
	}, "")

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d (body: %s)", rec.Code, http.StatusOK, rec.Body)
	}
	data := decode(t, rec)["data"].(map[string]any)
	if data["access_token"] == "" {
		t.Error("access_token must not be empty")
	}
}

func TestLoginRejectsWrongPassword(t *testing.T) {
	router, _ := newTestAPI(t)

	doJSON(t, router, http.MethodPost, "/api/v1/auth/register",
		registerBody("wrong@example.com"), "")

	rec := doJSON(t, router, http.MethodPost, "/api/v1/auth/login", map[string]string{
		"email":    "wrong@example.com",
		"password": "not-the-password",
	}, "")

	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusUnauthorized)
	}
}

func TestLoginGivesSameErrorForUnknownEmailAndWrongPassword(t *testing.T) {
	router, _ := newTestAPI(t)

	doJSON(t, router, http.MethodPost, "/api/v1/auth/register",
		registerBody("known@example.com"), "")

	wrongPassword := doJSON(t, router, http.MethodPost, "/api/v1/auth/login", map[string]string{
		"email": "known@example.com", "password": "bad-password",
	}, "")
	unknownEmail := doJSON(t, router, http.MethodPost, "/api/v1/auth/login", map[string]string{
		"email": "nobody@example.com", "password": "bad-password",
	}, "")

	// Ikkala holat ham bir xil javob berishi kerak, aks holda qaysi emaillar
	// ro'yxatdan o'tganini aniqlash mumkin bo'lardi.
	if wrongPassword.Code != unknownEmail.Code {
		t.Errorf("status differs: %d vs %d", wrongPassword.Code, unknownEmail.Code)
	}
	if wrongPassword.Body.String() != unknownEmail.Body.String() {
		t.Errorf("body differs:\n%s\n%s", wrongPassword.Body, unknownEmail.Body)
	}
}

func TestMeReturnsAuthenticatedUser(t *testing.T) {
	router, _ := newTestAPI(t)

	registered := doJSON(t, router, http.MethodPost, "/api/v1/auth/register",
		registerBody("me@example.com"), "")
	token := decode(t, registered)["data"].(map[string]any)["access_token"].(string)

	rec := doJSON(t, router, http.MethodGet, "/api/v1/auth/me", nil, token)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d (body: %s)", rec.Code, http.StatusOK, rec.Body)
	}
	userData := decode(t, rec)["data"].(map[string]any)["user"].(map[string]any)
	if userData["email"] != "me@example.com" {
		t.Errorf("email = %v", userData["email"])
	}
}

func TestMeRejectsMissingOrInvalidToken(t *testing.T) {
	router, _ := newTestAPI(t)

	cases := map[string]string{
		"no token":      "",
		"garbage token": "not-a-real-token",
	}

	for name, token := range cases {
		t.Run(name, func(t *testing.T) {
			rec := doJSON(t, router, http.MethodGet, "/api/v1/auth/me", nil, token)
			if rec.Code != http.StatusUnauthorized {
				t.Errorf("status = %d, want %d", rec.Code, http.StatusUnauthorized)
			}
		})
	}
}

func TestMeRejectsExpiredToken(t *testing.T) {
	router, _ := newTestAPI(t)

	expiredIssuer := auth.NewTokenIssuer(testSecret, time.Hour)
	token, _, err := expiredIssuer.Issue("some-user", time.Now().Add(-2*time.Hour))
	if err != nil {
		t.Fatalf("Issue: %v", err)
	}

	rec := doJSON(t, router, http.MethodGet, "/api/v1/auth/me", nil, token)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("status = %d, want %d", rec.Code, http.StatusUnauthorized)
	}
}
