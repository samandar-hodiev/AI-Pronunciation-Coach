package auth

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/httperr"
)

// contextUserIDKey autentifikatsiyadan o'tgan foydalanuvchi identifikatori
// saqlanadigan kalit.
const contextUserIDKey = "auth.user_id"

// Middleware `Authorization: Bearer <token>` sarlavhasini tekshiradi.
//
// Token yaroqsiz bo'lsa so'rov 401 bilan to'xtaydi va handler'ga yetib
// bormaydi.
func Middleware(tokens *TokenIssuer) gin.HandlerFunc {
	return func(c *gin.Context) {
		header := c.GetHeader("Authorization")

		token, ok := bearerToken(header)
		if !ok {
			httperr.Write(c, http.StatusUnauthorized, httperr.CodeUnauthorized,
				"Authentication required.")
			return
		}

		userID, err := tokens.Verify(token)
		if err != nil {
			httperr.Write(c, http.StatusUnauthorized, httperr.CodeUnauthorized,
				"Your session has expired. Please sign in again.")
			return
		}

		c.Set(contextUserIDKey, userID)
		c.Next()
	}
}

// UserID [Middleware] o'rnatgan foydalanuvchi identifikatorini qaytaradi.
func UserID(c *gin.Context) (string, bool) {
	value, exists := c.Get(contextUserIDKey)
	if !exists {
		return "", false
	}
	id, ok := value.(string)
	return id, ok && id != ""
}

func bearerToken(header string) (string, bool) {
	const prefix = "Bearer "
	if len(header) <= len(prefix) || !strings.EqualFold(header[:len(prefix)], prefix) {
		return "", false
	}
	token := strings.TrimSpace(header[len(prefix):])
	return token, token != ""
}
