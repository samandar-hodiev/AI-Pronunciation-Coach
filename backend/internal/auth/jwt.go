package auth

import (
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// ErrInvalidToken token yaroqsiz, muddati o'tgan yoki imzosi noto'g'ri
// bo'lganda qaytariladi.
var ErrInvalidToken = errors.New("invalid token")

// TokenIssuer JWT access tokenlarni chiqaradi va tekshiradi.
type TokenIssuer struct {
	secret []byte
	ttl    time.Duration
}

// NewTokenIssuer yangi chiqaruvchi yaratadi.
func NewTokenIssuer(secret []byte, ttl time.Duration) *TokenIssuer {
	return &TokenIssuer{secret: secret, ttl: ttl}
}

// Issue berilgan foydalanuvchi uchun imzolangan token va uning tugash
// vaqtini qaytaradi.
func (t *TokenIssuer) Issue(userID string, now time.Time) (string, time.Time, error) {
	expiresAt := now.Add(t.ttl)

	claims := jwt.RegisteredClaims{
		Subject:   userID,
		IssuedAt:  jwt.NewNumericDate(now),
		ExpiresAt: jwt.NewNumericDate(expiresAt),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString(t.secret)
	if err != nil {
		return "", time.Time{}, fmt.Errorf("sign token: %w", err)
	}

	return signed, expiresAt, nil
}

// Verify tokenni tekshiradi va foydalanuvchi identifikatorini qaytaradi.
//
// Imzolash usuli aniq cheklanadi: `alg: none` yoki asimmetrik usulga
// almashtirish orqali qilinadigan hujumning oldi olinadi.
func (t *TokenIssuer) Verify(tokenString string) (string, error) {
	parsed, err := jwt.ParseWithClaims(
		tokenString,
		&jwt.RegisteredClaims{},
		func(token *jwt.Token) (any, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			return t.secret, nil
		},
		jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}),
	)
	if err != nil || !parsed.Valid {
		return "", ErrInvalidToken
	}

	claims, ok := parsed.Claims.(*jwt.RegisteredClaims)
	if !ok || claims.Subject == "" {
		return "", ErrInvalidToken
	}

	return claims.Subject, nil
}
