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
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/profile"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/server"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/user"
)

// newProfileAPI auth va profil yo'llari ulangan API qaytaradi.
func newProfileAPI(t *testing.T) (*gin.Engine, *pgxpool.Pool) {
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
	// Profillar users'ga bog'langan, shuning uchun kaskad bilan tozalanadi.
	if _, err := pool.Exec(ctx, "TRUNCATE users CASCADE"); err != nil {
		t.Fatalf("truncate: %v", err)
	}

	tokens := auth.NewTokenIssuer(testSecret, time.Hour)
	userService := user.NewService(user.NewPostgresRepository(pool), tokens)
	profileService := profile.NewService(profile.NewPostgresRepository(pool))

	router := server.NewRouter(server.Deps{
		Users:    user.NewHandler(userService),
		Profiles: profile.NewHandler(profileService),
		Tokens:   tokens,
	})

	return router, pool
}

// registerUser yangi foydalanuvchi yaratadi va uning tokenini qaytaradi.
func registerUser(t *testing.T, router *gin.Engine, email string) string {
	t.Helper()

	rec := doJSON(t, router, http.MethodPost, "/api/v1/auth/register",
		registerBody(email), "")
	if rec.Code != http.StatusCreated {
		t.Fatalf("register status = %d (body: %s)", rec.Code, rec.Body)
	}
	return decode(t, rec)["data"].(map[string]any)["access_token"].(string)
}

func validProfileBody() map[string]any {
	return map[string]any{
		"name":                "Samandar",
		"learning_language":   "en",
		"pronunciation_goal":  "reduce_accent",
		"pronunciation_level": "intermediate",
		"daily_goal_minutes":  10,
	}
}

func profileOf(t *testing.T, router *gin.Engine, token string) map[string]any {
	t.Helper()

	rec := doJSON(t, router, http.MethodGet, "/api/v1/profile", nil, token)
	if rec.Code != http.StatusOK {
		t.Fatalf("get profile status = %d (body: %s)", rec.Code, rec.Body)
	}
	return decode(t, rec)["data"].(map[string]any)["profile"].(map[string]any)
}

func TestProfileStartsIncomplete(t *testing.T) {
	router, _ := newProfileAPI(t)
	token := registerUser(t, router, "fresh@example.com")

	p := profileOf(t, router, token)

	if p["setup_completed"] != false {
		t.Errorf("setup_completed = %v, want false for a new user", p["setup_completed"])
	}
	if p["pronunciation_goal"] != nil {
		t.Errorf("pronunciation_goal = %v, want nil", p["pronunciation_goal"])
	}
	if p["learning_language"] != "en" {
		t.Errorf("learning_language = %v, want en", p["learning_language"])
	}
	// Ism ro'yxatdan o'tishdan keladi.
	if p["name"] != "Samandar" {
		t.Errorf("name = %v", p["name"])
	}
}

func TestProfileUpdateCompletesSetup(t *testing.T) {
	router, pool := newProfileAPI(t)
	token := registerUser(t, router, "setup@example.com")

	body := validProfileBody()
	body["name"] = "Updated Name"

	rec := doJSON(t, router, http.MethodPut, "/api/v1/profile", body, token)
	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d (body: %s)", rec.Code, rec.Body)
	}

	updated := decode(t, rec)["data"].(map[string]any)["profile"].(map[string]any)
	if updated["setup_completed"] != true {
		t.Error("setup_completed must be true after a successful update")
	}
	if updated["name"] != "Updated Name" {
		t.Errorf("name = %v", updated["name"])
	}

	// Keyingi GET ham saqlangan qiymatlarni qaytarishi kerak.
	fetched := profileOf(t, router, token)
	if fetched["pronunciation_goal"] != "reduce_accent" {
		t.Errorf("goal = %v", fetched["pronunciation_goal"])
	}
	if fetched["pronunciation_level"] != "intermediate" {
		t.Errorf("level = %v", fetched["pronunciation_level"])
	}
	if fetched["daily_goal_minutes"] != float64(10) {
		t.Errorf("daily_goal_minutes = %v", fetched["daily_goal_minutes"])
	}

	// Ma'lumot haqiqatan bazada bo'lishi kerak.
	var completed bool
	var goal string
	if err := pool.QueryRow(context.Background(), `
		SELECT p.setup_completed, p.pronunciation_goal
		FROM user_profiles p JOIN users u ON u.id = p.user_id
		WHERE u.email = $1`, "setup@example.com",
	).Scan(&completed, &goal); err != nil {
		t.Fatalf("read database: %v", err)
	}
	if !completed || goal != "reduce_accent" {
		t.Errorf("database has completed=%v goal=%q", completed, goal)
	}

	// Ism `users` jadvalida yangilanishi kerak, profilda takrorlanmasligi.
	var name string
	if err := pool.QueryRow(context.Background(),
		"SELECT name FROM users WHERE email = $1", "setup@example.com",
	).Scan(&name); err != nil {
		t.Fatalf("read name: %v", err)
	}
	if name != "Updated Name" {
		t.Errorf("users.name = %q", name)
	}
}

func TestProfileUpdateRejectsInvalidValues(t *testing.T) {
	router, _ := newProfileAPI(t)
	token := registerUser(t, router, "invalid@example.com")

	cases := map[string]func(map[string]any){
		"empty name":       func(b map[string]any) { b["name"] = "  " },
		"unknown goal":     func(b map[string]any) { b["pronunciation_goal"] = "become_fluent" },
		"unknown level":    func(b map[string]any) { b["pronunciation_level"] = "expert" },
		"unsupported lang": func(b map[string]any) { b["learning_language"] = "fr" },
		"odd daily goal":   func(b map[string]any) { b["daily_goal_minutes"] = 7 },
		"zero daily goal":  func(b map[string]any) { b["daily_goal_minutes"] = 0 },
	}

	for name, mutate := range cases {
		t.Run(name, func(t *testing.T) {
			body := validProfileBody()
			mutate(body)

			rec := doJSON(t, router, http.MethodPut, "/api/v1/profile", body, token)
			if rec.Code != http.StatusUnprocessableEntity {
				t.Errorf("status = %d, want %d (body: %s)",
					rec.Code, http.StatusUnprocessableEntity, rec.Body)
			}
		})
	}

	// Hech bir noto'g'ri so'rov sozlashni tugallangan deb belgilamasligi kerak.
	if profileOf(t, router, token)["setup_completed"] != false {
		t.Error("setup_completed must stay false after failed updates")
	}
}

func TestProfileRequiresAuthentication(t *testing.T) {
	router, _ := newProfileAPI(t)

	cases := map[string]string{
		"no token":      "",
		"garbage token": "not-a-real-token",
	}

	for name, token := range cases {
		t.Run(name+" get", func(t *testing.T) {
			rec := doJSON(t, router, http.MethodGet, "/api/v1/profile", nil, token)
			if rec.Code != http.StatusUnauthorized {
				t.Errorf("status = %d, want 401", rec.Code)
			}
		})
		t.Run(name+" put", func(t *testing.T) {
			rec := doJSON(t, router, http.MethodPut, "/api/v1/profile",
				validProfileBody(), token)
			if rec.Code != http.StatusUnauthorized {
				t.Errorf("status = %d, want 401", rec.Code)
			}
		})
	}
}

func TestProfileRejectsExpiredToken(t *testing.T) {
	router, _ := newProfileAPI(t)

	issuer := auth.NewTokenIssuer(testSecret, time.Hour)
	expired, _, err := issuer.Issue("some-user", time.Now().Add(-2*time.Hour))
	if err != nil {
		t.Fatalf("Issue: %v", err)
	}

	rec := doJSON(t, router, http.MethodGet, "/api/v1/profile", nil, expired)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("status = %d, want 401", rec.Code)
	}
}

func TestProfileIsolatedBetweenUsers(t *testing.T) {
	router, _ := newProfileAPI(t)

	tokenA := registerUser(t, router, "alice@example.com")
	tokenB := registerUser(t, router, "bob@example.com")

	// A o'z profilini to'ldiradi.
	bodyA := validProfileBody()
	bodyA["name"] = "Alice"
	bodyA["pronunciation_goal"] = "exam_preparation"
	if rec := doJSON(t, router, http.MethodPut, "/api/v1/profile", bodyA, tokenA); rec.Code != http.StatusOK {
		t.Fatalf("A update status = %d", rec.Code)
	}

	// B hali sozlamagan bo'lishi va A ning ma'lumotini ko'rmasligi kerak.
	profileB := profileOf(t, router, tokenB)
	if profileB["setup_completed"] != false {
		t.Error("B's profile must not be affected by A")
	}
	if profileB["name"] == "Alice" {
		t.Error("B must not see A's name")
	}
	if profileB["pronunciation_goal"] != nil {
		t.Errorf("B's goal = %v, want nil", profileB["pronunciation_goal"])
	}

	// A ning profili o'zgarmagan bo'lishi kerak.
	profileA := profileOf(t, router, tokenA)
	if profileA["name"] != "Alice" {
		t.Errorf("A's name = %v", profileA["name"])
	}
}

func TestProfileIgnoresClientSuppliedIdentity(t *testing.T) {
	router, _ := newProfileAPI(t)

	tokenA := registerUser(t, router, "owner@example.com")
	tokenB := registerUser(t, router, "attacker@example.com")

	// B o'z so'roviga A ning identifikatorini va setup_completed ni qo'shadi.
	// Ikkalasi ham e'tiborsiz qoldirilishi kerak.
	body := validProfileBody()
	body["name"] = "Attacker"
	body["user_id"] = "00000000-0000-0000-0000-000000000000"
	body["setup_completed"] = false

	if rec := doJSON(t, router, http.MethodPut, "/api/v1/profile", body, tokenB); rec.Code != http.StatusOK {
		t.Fatalf("status = %d", rec.Code)
	}

	// A ning profili tegilmagan bo'lishi kerak.
	profileA := profileOf(t, router, tokenA)
	if profileA["name"] == "Attacker" {
		t.Error("another user's profile was modified")
	}
	if profileA["setup_completed"] != false {
		t.Error("A's setup state was modified")
	}

	// B ning setup_completed baribir true bo'lishi kerak — mijoz uni
	// false qilib yubora olmaydi.
	profileB := profileOf(t, router, tokenB)
	if profileB["setup_completed"] != true {
		t.Error("setup_completed must be decided by the server, not the client")
	}
}
