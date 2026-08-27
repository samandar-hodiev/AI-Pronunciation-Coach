// Package user foydalanuvchi ma'lumotlari va autentifikatsiya mantiqini
// o'z ichiga oladi.
package user

import "time"

// User bazadagi foydalanuvchi yozuvi.
//
// PasswordHash `json:"-"` bilan belgilangan — u hech qachon JSON javobiga
// tushmasligi kerak.
type User struct {
	ID           string    `json:"id"`
	Name         string    `json:"name"`
	Email        string    `json:"email"`
	PasswordHash string    `json:"-"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

// Public mijozga yuborish xavfsiz bo'lgan ko'rinish.
//
// Alohida tur ishlatilgani sababli, kelajakda [User] ga maxfiy maydon
// qo'shilsa ham u tasodifan API javobiga chiqib ketmaydi.
type Public struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
}

// ToPublic xavfsiz ko'rinishga o'giradi.
func (u User) ToPublic() Public {
	return Public{
		ID:        u.ID,
		Name:      u.Name,
		Email:     u.Email,
		CreatedAt: u.CreatedAt,
	}
}
