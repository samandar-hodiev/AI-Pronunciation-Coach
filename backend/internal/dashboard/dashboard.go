// Package dashboard bosh ekran uchun ma'lumotlarni yig'adi.
//
// Bu paket o'z jadvaliga ega emas: u mavjud foydalanuvchi va profil
// ma'lumotlarini bitta javobga birlashtiradi. Shu sababli mobil ilova bosh
// ekranni ochish uchun bir nechta so'rov yubormaydi.
package dashboard

// View bosh ekranga yuboriladigan ma'lumot.
type View struct {
	User                     UserView     `json:"user"`
	DailyPracticeGoalMinutes *int         `json:"daily_practice_goal_minutes"`
	Today                    TodayView    `json:"today"`
	Progress                 SectionState `json:"progress"`
	RecentPractice           SectionState `json:"recent_practice"`
}

// UserView bosh ekranda ko'rsatiladigan foydalanuvchi ma'lumoti.
type UserView struct {
	Name string `json:"name"`
}

// TodayView bugungi mashq holati.
type TodayView struct {
	// TrackingAvailable mashq vaqtini o'lchash imkoni bor-yo'qligini
	// bildiradi.
	//
	// Hozircha doim `false`: mashq funksiyasi hali yaratilmagan. Ataylab
	// `completed_minutes: 0` qaytarilmaydi — u o'lchov mavjud, lekin
	// foydalanuvchi hali mashq qilmagan degan ma'noni berardi. Bu esa
	// haqiqatga to'g'ri kelmaydi.
	TrackingAvailable bool `json:"tracking_available"`

	// CompletedMinutes faqat [TrackingAvailable] rost bo'lganda to'ldiriladi.
	CompletedMinutes *int `json:"completed_minutes"`
}

// SectionState ma'lumot mavjudligini bildiradi.
//
// Mobil ilova bunga qarab bo'sh holat ko'rsatadi. Soxta qiymat o'rniga
// "hali ma'lumot yo'q" deyish to'g'riroq.
type SectionState struct {
	Available bool `json:"available"`
}
