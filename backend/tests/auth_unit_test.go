package tests

import (
	"testing"
	"time"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/auth"
)

var testSecret = []byte("test-secret-that-is-at-least-32-bytes-long")

func TestHashPasswordProducesVerifiableHash(t *testing.T) {
	const password = "correct-horse-battery"

	hash, err := auth.HashPassword(password)
	if err != nil {
		t.Fatalf("HashPassword: %v", err)
	}

	if hash == password {
		t.Fatal("hash must not equal the plain password")
	}
	if !auth.VerifyPassword(hash, password) {
		t.Error("VerifyPassword rejected the correct password")
	}
	if auth.VerifyPassword(hash, "wrong-password") {
		t.Error("VerifyPassword accepted an incorrect password")
	}
}

func TestHashPasswordIsSaltedPerCall(t *testing.T) {
	const password = "same-password"

	first, err := auth.HashPassword(password)
	if err != nil {
		t.Fatalf("HashPassword: %v", err)
	}
	second, err := auth.HashPassword(password)
	if err != nil {
		t.Fatalf("HashPassword: %v", err)
	}

	// Bir xil parol har safar boshqa xesh berishi kerak, aks holda bazadan
	// bir xil parolli foydalanuvchilarni aniqlab olish mumkin bo'lardi.
	if first == second {
		t.Error("two hashes of the same password must differ")
	}
}

func TestIssueAndVerifyToken(t *testing.T) {
	issuer := auth.NewTokenIssuer(testSecret, time.Hour)
	now := time.Now()

	token, expiresAt, err := issuer.Issue("user-123", now)
	if err != nil {
		t.Fatalf("Issue: %v", err)
	}
	if token == "" {
		t.Fatal("token must not be empty")
	}
	if !expiresAt.After(now) {
		t.Error("expiry must be in the future")
	}

	userID, err := issuer.Verify(token)
	if err != nil {
		t.Fatalf("Verify: %v", err)
	}
	if userID != "user-123" {
		t.Errorf("user id = %q, want %q", userID, "user-123")
	}
}

func TestVerifyRejectsExpiredToken(t *testing.T) {
	issuer := auth.NewTokenIssuer(testSecret, time.Hour)

	// Bir soatlik token ikki soat oldin chiqarilgan — muddati o'tgan.
	token, _, err := issuer.Issue("user-123", time.Now().Add(-2*time.Hour))
	if err != nil {
		t.Fatalf("Issue: %v", err)
	}

	if _, err := issuer.Verify(token); err == nil {
		t.Error("expired token was accepted")
	}
}

func TestVerifyRejectsTokenSignedWithAnotherSecret(t *testing.T) {
	attacker := auth.NewTokenIssuer([]byte("attacker-secret-at-least-32-bytes-long"), time.Hour)
	server := auth.NewTokenIssuer(testSecret, time.Hour)

	token, _, err := attacker.Issue("user-123", time.Now())
	if err != nil {
		t.Fatalf("Issue: %v", err)
	}

	if _, err := server.Verify(token); err == nil {
		t.Error("token signed with a different secret was accepted")
	}
}

func TestVerifyRejectsGarbage(t *testing.T) {
	issuer := auth.NewTokenIssuer(testSecret, time.Hour)

	for _, token := range []string{"", "not-a-token", "a.b.c"} {
		if _, err := issuer.Verify(token); err == nil {
			t.Errorf("garbage token %q was accepted", token)
		}
	}
}
