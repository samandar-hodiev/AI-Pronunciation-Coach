// Package httperr mijozga qaytariladigan xatolarning yagona shaklini beradi.
package httperr

import "github.com/gin-gonic/gin"

// Response barcha xato javoblarining tuzilishi.
//
//	{"success": false, "error": {"code": "...", "message": "..."}}
type Response struct {
	Success bool  `json:"success"`
	Error   Error `json:"error"`
}

// Error mijozga ko'rsatiladigan xato.
type Error struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

// Xato kodlari. Mijoz aynan shu kodlarga qarab xatti-harakat tanlaydi,
// matnga emas.
const (
	CodeValidation   = "VALIDATION_ERROR"
	CodeEmailTaken   = "EMAIL_ALREADY_REGISTERED"
	CodeInvalidCreds = "INVALID_CREDENTIALS"
	CodeUnauthorized = "UNAUTHORIZED"
	CodeNotFound     = "NOT_FOUND"
	CodeInvalidState = "INVALID_STATE"
	CodeInternal     = "INTERNAL_ERROR"
)

// Write xato javobini yozadi va so'rovni to'xtatadi.
//
// Ichki xato tafsilotlari (SQL, stack trace) hech qachon bu yerdan
// o'tkazilmaydi — ular faqat serverda log qilinadi.
func Write(c *gin.Context, status int, code, message string) {
	c.AbortWithStatusJSON(status, Response{
		Success: false,
		Error:   Error{Code: code, Message: message},
	})
}
