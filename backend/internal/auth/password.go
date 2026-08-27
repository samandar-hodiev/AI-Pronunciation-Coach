// Package auth parol xeshlash va JWT tokenlar bilan ishlaydi.
package auth

import "golang.org/x/crypto/bcrypt"

// Parol uzunligi chegaralari.
//
// bcrypt 72 baytdan uzun kirishni jimgina qirqadi, shuning uchun uzunlik
// aniq tekshiriladi — aks holda ikki xil uzun parol bir xil hisoblanardi.
const (
	MinPasswordLength = 8
	MaxPasswordLength = 72
)

// HashPassword parolni bcrypt bilan xeshlaydi.
func HashPassword(password string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hash), nil
}

// VerifyPassword parol xeshga mos kelishini tekshiradi.
//
// Taqqoslash bcrypt ichida doimiy vaqtda bajariladi.
func VerifyPassword(hash, password string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)) == nil
}
