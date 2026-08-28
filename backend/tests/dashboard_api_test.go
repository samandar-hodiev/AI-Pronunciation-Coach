package tests

import (
	"context"
	"net/http"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/auth"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/dashboard"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/database"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/profile"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/server"
	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/user"
)

// newDashboardAPI auth, profil va bosh ekran yo'llari ulangan API qaytaradi.
func newDashboardAPI(t *testing.T) (*gin.Engine, *pgxpool.Pool) {
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
	profileRepo := profile.NewPostgresRepository(pool)

	router := server.NewRouter(server.Deps{
		Users: user.NewHandler(
			user.NewService(user.NewPostgresRepository(pool), tokens),
		),
		Profiles:  profile.NewHandler(profile.NewService(profileRepo)),
		Dashboard: dashboard.NewHandler(dashboard.NewService(profileRepo)),
		Tokens:    tokens,
	})

	return router, pool
}

func dashboardOf(t *testing.T, router *gin.Engine, token string) map[string]any {
	t.Helper()

	rec := doJSON(t, router, http.MethodGet, "/api/v1/dashboard", nil, token)
	if rec.Code != http.StatusOK {
		t.Fatalf("dashboard status = %d (body: %s)", rec.Code, rec.Body)
	}
	return decode(t, rec)["data"].(map[string]any)["dashboard"].(map[string]any)
}

// completeSetup profilni to'ldiradi va bosh ekran uchun real ma'lumot beradi.
func completeSetup(t *testing.T, router *gin.Engine, token string, name string, minutes int) {
	t.Helper()

	body := map[string]any{
		"name":                name,
		"pronunciation_goal":  "reduce_accent",
		"pronunciation_level": "intermediate",
		"daily_goal_minutes":  minutes,
	}
	if rec := doJSON(t, router, http.MethodPut, "/api/v1/profile", body, token); rec.Code != http.StatusOK {
		t.Fatalf("profile update status = %d (body: %s)", rec.Code, rec.Body)
	}
}

func TestDashboardRequiresAuthentication(t *testing.T) {
	router, _ := newDashboardAPI(t)

	cases := map[string]string{
		"no token":      "",
		"garbage token": "not-a-real-token",
	}

	for name, token := range cases {
		t.Run(name, func(t *testing.T) {
			rec := doJSON(t, router, http.MethodGet, "/api/v1/dashboard", nil, token)
			if rec.Code != http.StatusUnauthorized {
				t.Errorf("status = %d, want 401", rec.Code)
			}
		})
	}
}

func TestDashboardRejectsExpiredToken(t *testing.T) {
	router, _ := newDashboardAPI(t)

	issuer := auth.NewTokenIssuer(testSecret, time.Hour)
	expired, _, err := issuer.Issue("some-user", time.Now().Add(-2*time.Hour))
	if err != nil {
		t.Fatalf("Issue: %v", err)
	}

	rec := doJSON(t, router, http.MethodGet, "/api/v1/dashboard", nil, expired)
	if rec.Code != http.StatusUnauthorized {
		t.Errorf("status = %d, want 401", rec.Code)
	}
}

func TestDashboardReturnsRealProfileData(t *testing.T) {
	router, _ := newDashboardAPI(t)
	token := registerUser(t, router, "dash@example.com")

	completeSetup(t, router, token, "Dashboard User", 15)

	d := dashboardOf(t, router, token)

	// Ism va kunlik maqsad haqiqiy profildan kelishi kerak.
	userData := d["user"].(map[string]any)
	if userData["name"] != "Dashboard User" {
		t.Errorf("name = %v, want %q", userData["name"], "Dashboard User")
	}
	if d["daily_practice_goal_minutes"] != float64(15) {
		t.Errorf("daily goal = %v, want 15", d["daily_practice_goal_minutes"])
	}
}

func TestDashboardReportsUnavailableSectionsHonestly(t *testing.T) {
	router, _ := newDashboardAPI(t)
	token := registerUser(t, router, "empty@example.com")
	completeSetup(t, router, token, "Empty Sections", 10)

	d := dashboardOf(t, router, token)

	today := d["today"].(map[string]any)
	// Mashq o'lchovi hali yo'q — soxta nol qaytarilmasligi kerak.
	if today["tracking_available"] != false {
		t.Errorf("tracking_available = %v, want false", today["tracking_available"])
	}
	if today["completed_minutes"] != nil {
		t.Errorf("completed_minutes = %v, want nil while tracking is unavailable",
			today["completed_minutes"])
	}

	if d["progress"].(map[string]any)["available"] != false {
		t.Error("progress must report itself as unavailable")
	}
	if d["recent_practice"].(map[string]any)["available"] != false {
		t.Error("recent_practice must report itself as unavailable")
	}
}

func TestDashboardHandlesProfileWithoutSetup(t *testing.T) {
	router, _ := newDashboardAPI(t)
	token := registerUser(t, router, "nosetup@example.com")

	// Sozlash bajarilmagan — kunlik maqsad hali yo'q.
	d := dashboardOf(t, router, token)

	if d["daily_practice_goal_minutes"] != nil {
		t.Errorf("daily goal = %v, want nil before setup",
			d["daily_practice_goal_minutes"])
	}
	// Ism ro'yxatdan o'tishdan keladi va baribir mavjud bo'lishi kerak.
	if d["user"].(map[string]any)["name"] != "Samandar" {
		t.Errorf("name = %v", d["user"].(map[string]any)["name"])
	}
}

func TestDashboardIsolatedBetweenUsers(t *testing.T) {
	router, _ := newDashboardAPI(t)

	tokenA := registerUser(t, router, "dash-a@example.com")
	tokenB := registerUser(t, router, "dash-b@example.com")

	completeSetup(t, router, tokenA, "User A", 20)
	completeSetup(t, router, tokenB, "User B", 5)

	dashA := dashboardOf(t, router, tokenA)
	dashB := dashboardOf(t, router, tokenB)

	if dashA["user"].(map[string]any)["name"] != "User A" {
		t.Errorf("A sees %v", dashA["user"])
	}
	if dashB["user"].(map[string]any)["name"] != "User B" {
		t.Errorf("B sees %v", dashB["user"])
	}
	if dashA["daily_practice_goal_minutes"] != float64(20) {
		t.Errorf("A goal = %v, want 20", dashA["daily_practice_goal_minutes"])
	}
	if dashB["daily_practice_goal_minutes"] != float64(5) {
		t.Errorf("B goal = %v, want 5", dashB["daily_practice_goal_minutes"])
	}
}

func TestDashboardIgnoresClientSuppliedIdentity(t *testing.T) {
	router, _ := newDashboardAPI(t)

	tokenA := registerUser(t, router, "victim@example.com")
	tokenB := registerUser(t, router, "curious@example.com")

	completeSetup(t, router, tokenA, "Victim", 20)
	completeSetup(t, router, tokenB, "Curious", 5)

	// So'rov qatorida boshqa foydalanuvchini so'rashga urinish.
	rec := doJSON(t, router, http.MethodGet,
		"/api/v1/dashboard?user_id=whatever", nil, tokenB)
	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d", rec.Code)
	}

	d := decode(t, rec)["data"].(map[string]any)["dashboard"].(map[string]any)
	if d["user"].(map[string]any)["name"] != "Curious" {
		t.Errorf("query parameter changed the returned user: %v", d["user"])
	}
}
