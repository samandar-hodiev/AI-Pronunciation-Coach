package user

import (
	"context"
	"errors"
	"fmt"
	"net/mail"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"

	"github.com/samandar-hodiev/AI-Pronunciation-Coach/backend/internal/auth"
)

// Xizmat darajasidagi xatolar.
var (
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrValidation         = errors.New("validation failed")
)

// ValidationError qaysi maydon noto'g'ri ekanini bildiradi.
type ValidationError struct {
	Field   string
	Message string
}

func (e ValidationError) Error() string { return e.Field + ": " + e.Message }

// Is [ErrValidation] bilan taqqoslashni ishlatish uchun.
func (e ValidationError) Is(target error) bool { return target == ErrValidation }

// Service autentifikatsiya biznes mantiqi.
//
// HTTP haqida hech narsa bilmaydi — shu sababli uni handler'siz test qilish
// mumkin.
type Service struct {
	repo   Repository
	tokens *auth.TokenIssuer
	now    func() time.Time
}

// NewService yangi xizmat yaratadi.
func NewService(repo Repository, tokens *auth.TokenIssuer) *Service {
	return &Service{repo: repo, tokens: tokens, now: time.Now}
}

// RegisterInput ro'yxatdan o'tish uchun kirish ma'lumotlari.
type RegisterInput struct {
	Name     string
	Email    string
	Password string
}

// Session muvaffaqiyatli autentifikatsiya natijasi.
type Session struct {
	User        Public
	AccessToken string
	ExpiresAt   time.Time
}

const maxNameLength = 100

// Register yangi foydalanuvchi yaratadi va sessiya qaytaradi.
func (s *Service) Register(ctx context.Context, in RegisterInput) (Session, error) {
	name := strings.TrimSpace(in.Name)
	email := normalizeEmail(in.Email)

	if name == "" {
		return Session{}, ValidationError{Field: "name", Message: "Name is required."}
	}
	if utf8.RuneCountInString(name) > maxNameLength {
		return Session{}, ValidationError{Field: "name", Message: "Name is too long."}
	}
	if err := validateEmail(email); err != nil {
		return Session{}, err
	}
	if err := validatePassword(in.Password); err != nil {
		return Session{}, err
	}

	hash, err := auth.HashPassword(in.Password)
	if err != nil {
		return Session{}, fmt.Errorf("hash password: %w", err)
	}

	now := s.now().UTC()
	u := User{
		ID:           uuid.NewString(),
		Name:         name,
		Email:        email,
		PasswordHash: hash,
		CreatedAt:    now,
		UpdatedAt:    now,
	}

	if err := s.repo.Create(ctx, u); err != nil {
		return Session{}, err
	}

	return s.newSession(u)
}

// LoginInput tizimga kirish ma'lumotlari.
type LoginInput struct {
	Email    string
	Password string
}

// Login parolni tekshiradi va sessiya qaytaradi.
//
// Foydalanuvchi topilmagan va parol noto'g'ri holatlar bir xil xato
// qaytaradi: aks holda qaysi emaillar ro'yxatdan o'tganini aniqlash mumkin
// bo'lardi.
func (s *Service) Login(ctx context.Context, in LoginInput) (Session, error) {
	email := normalizeEmail(in.Email)

	u, err := s.repo.FindByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, ErrNotFound) {
			// Vaqt bo'yicha farqni kamaytirish uchun baribir xeshlash
			// bajariladi.
			auth.VerifyPassword(dummyHash, in.Password)
			return Session{}, ErrInvalidCredentials
		}
		return Session{}, err
	}

	if !auth.VerifyPassword(u.PasswordHash, in.Password) {
		return Session{}, ErrInvalidCredentials
	}

	return s.newSession(u)
}

// CurrentUser identifikatorga ko'ra foydalanuvchini qaytaradi.
func (s *Service) CurrentUser(ctx context.Context, id string) (Public, error) {
	u, err := s.repo.FindByID(ctx, id)
	if err != nil {
		return Public{}, err
	}
	return u.ToPublic(), nil
}

func (s *Service) newSession(u User) (Session, error) {
	token, expiresAt, err := s.tokens.Issue(u.ID, s.now())
	if err != nil {
		return Session{}, fmt.Errorf("issue token: %w", err)
	}
	return Session{
		User:        u.ToPublic(),
		AccessToken: token,
		ExpiresAt:   expiresAt,
	}, nil
}

// dummyHash mavjud bo'lmagan foydalanuvchi uchun ham bcrypt ishlashini
// ta'minlaydi, shunda javob vaqti foydalanuvchi bor-yo'qligini oshkor
// qilmaydi. Bu haqiqiy paroldan olingan emas.
const dummyHash = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy"

func normalizeEmail(email string) string {
	return strings.ToLower(strings.TrimSpace(email))
}

func validateEmail(email string) error {
	if email == "" {
		return ValidationError{Field: "email", Message: "Email is required."}
	}
	if _, err := mail.ParseAddress(email); err != nil {
		return ValidationError{Field: "email", Message: "Enter a valid email address."}
	}
	return nil
}

func validatePassword(password string) error {
	if password == "" {
		return ValidationError{Field: "password", Message: "Password is required."}
	}
	if utf8.RuneCountInString(password) < auth.MinPasswordLength {
		return ValidationError{
			Field:   "password",
			Message: fmt.Sprintf("Password must be at least %d characters.", auth.MinPasswordLength),
		}
	}
	if len(password) > auth.MaxPasswordLength {
		return ValidationError{
			Field:   "password",
			Message: fmt.Sprintf("Password must be at most %d characters.", auth.MaxPasswordLength),
		}
	}
	return nil
}
