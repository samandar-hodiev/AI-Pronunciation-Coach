package tests

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/server"
)

func TestMain(m *testing.M) {
	gin.SetMode(gin.TestMode)
	m.Run()
}

// TestHealthEndpoint asserts the liveness contract the deployment platform and
// docker-compose healthchecks rely on: 200 with {"status":"ok"}.
func TestHealthEndpoint(t *testing.T) {
	router := server.NewRouter()

	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}

	var body map[string]string
	if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode body: %v (raw: %s)", err, rec.Body.String())
	}

	if got := body["status"]; got != "ok" {
		t.Errorf(`status field = %q, want "ok"`, got)
	}
}

// TestUnknownRouteReturns404 guards against a catch-all being introduced by
// accident when feature routes are added.
func TestUnknownRouteReturns404(t *testing.T) {
	router := server.NewRouter()

	req := httptest.NewRequest(http.MethodGet, "/does-not-exist", nil)
	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, req)

	if rec.Code != http.StatusNotFound {
		t.Errorf("status = %d, want %d", rec.Code, http.StatusNotFound)
	}
}
