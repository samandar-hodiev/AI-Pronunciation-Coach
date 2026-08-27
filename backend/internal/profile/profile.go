// Package profile foydalanuvchining talaffuz sozlamalarini boshqaradi.
package profile

import "time"

// Profile foydalanuvchining sozlash ma'lumotlari.
//
// Ism bu yerda saqlanmaydi — u `users` jadvalida, ro'yxatdan o'tishda
// olingan. Ikki joyda saqlash ma'lumotlarning bir-biriga zid bo'lishiga
// olib kelardi.
type Profile struct {
	UserID             string
	LearningLanguage   string
	PronunciationGoal  *string
	PronunciationLevel *string
	DailyGoalMinutes   *int
	SetupCompleted     bool
	CreatedAt          time.Time
	UpdatedAt          time.Time
}

// View mijozga qaytariladigan ko'rinish.
//
// Ism `users` dan qo'shiladi, shunda mobil ilova sozlash formasini bitta
// so'rov bilan to'ldira oladi.
type View struct {
	Name               string  `json:"name"`
	LearningLanguage   string  `json:"learning_language"`
	PronunciationGoal  *string `json:"pronunciation_goal"`
	PronunciationLevel *string `json:"pronunciation_level"`
	DailyGoalMinutes   *int    `json:"daily_goal_minutes"`
	SetupCompleted     bool    `json:"setup_completed"`
}

// Ruxsat etilgan qiymatlar.
//
// Ular ilovadagi ro'yxatlar bilan bir xil bo'lishi shart. Backend ham
// tekshiradi: mijoz validatsiyani aylanib o'tib noto'g'ri qiymat yubora
// olmasligi kerak.
var (
	// AllowedLanguages — hozircha faqat ingliz tili.
	AllowedLanguages = []string{"en"}

	// AllowedGoals ilovadagi GoalOptions bilan mos.
	AllowedGoals = []string{
		"speak_clearly",
		"difficult_sounds",
		"reduce_accent",
		"speak_confidently",
		"exam_preparation",
	}

	// AllowedLevels ilovadagi EnglishLevels bilan mos.
	AllowedLevels = []string{
		"beginner",
		"elementary",
		"intermediate",
		"upper_intermediate",
		"advanced",
	}

	// AllowedDailyGoalMinutes ilovadagi tanlovlar bilan mos.
	AllowedDailyGoalMinutes = []int{5, 10, 15, 20}
)

func allowedString(values []string, candidate string) bool {
	for _, v := range values {
		if v == candidate {
			return true
		}
	}
	return false
}

func allowedInt(values []int, candidate int) bool {
	for _, v := range values {
		if v == candidate {
			return true
		}
	}
	return false
}
