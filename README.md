<div align="center">

# PROgress ⬆️

### *Level up everyday*

![Flutter](https://img.shields.io/badge/Flutter-3.41.9-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-3.11.5-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-764ba2?style=for-the-badge)

</div>

---

## ✨ About

**PROgress** is a comprehensive daily productivity and habit-tracking app built with Flutter and Firebase. Manage personal and professional tasks, build streaks, visualize your productivity with charts and a calendar heatmap, and stay on track with smart reminders — all in a beautiful purple gradient UI designed to keep you motivated every single day.

---

## 📱 Screenshots

> Screenshots coming soon

---

## 🚀 Features

- 🔐 **Firebase Authentication** — Sign in with Google, Email/Password, or continue as Guest
- 📋 **Daily Task Timeline** — Separate Personal and Professional categories for clean organization
- 🔄 **7 Recurring Task Types** — Once, Daily, Weekday, Weekend, Weekly, Monthly, Every X Days
- 🛡️ **Duplicate Prevention** — Smart deduplication for recurring task instances
- 🔥 **Streak Tracking** — Track your consistency with Bronze / Silver / Gold streak badges
- 🎯 **Focus Task Banner** — Always highlights your first pending task to keep you moving
- 🔍 **Search, Filter & Sort** — Quickly find tasks by name, category, or status
- 📅 **Calendar Heatmap** — Color-coded monthly view (🟢 green / 🟠 orange / 🔴 red) showing your productivity at a glance
- 💡 **Smart Insights** — Discover your best productive hour and weekday vs weekend performance breakdown
- 📊 **Analytics Dashboard** — Doughnut and bar charts with Weekly / Monthly / Yearly views powered by `fl_chart`
- 🔔 **Task Reminders** — Local push notifications so you never miss a deadline
- 🌙 **End-of-Day Alert** — Automated missed-task reminder at 23:55 each night
- 🗑️ **Soft Delete + Undo** — 7-second undo toast to recover accidentally deleted tasks
- 🌙 **Dark Mode** — Full dark theme support
- 🔊 **Sound Effects** — Satisfying completion sounds on task check-off
- 🎬 **Onboarding Flow** — Guided intro slides on first launch
- ✨ **Splash Screen** — Branded launch experience with purple gradient

---

## 🏆 Streak System

PROgress rewards consistency with a tiered streak badge system:

| Badge | Milestone | Description |
|---|---|---|
| 🥉 **Bronze** | 3-day streak | You're building momentum — keep going! |
| 🥈 **Silver** | 7-day streak | One full week of consistency — impressive! |
| 🥇 **Gold** | 30-day streak | A month of discipline — you're unstoppable! |

Streaks are tracked per day — complete at least one task daily to maintain your streak. Missing a day resets the counter, so stay consistent!

---

## 🔄 Recurring Task Types

PROgress supports 7 flexible recurrence patterns so your tasks always show up exactly when you need them:

| Type | Description |
|---|---|
| **Once** | Single one-time task, never repeats |
| **Daily** | Repeats every day, including weekends |
| **Weekday** | Repeats Monday through Friday only |
| **Weekend** | Repeats Saturday and Sunday only |
| **Weekly** | Repeats on the same day each week |
| **Monthly** | Repeats on the same date each month |
| **Every X Days** | Repeats on a custom interval (e.g., every 3 days) |

---

## 🛠️ Tech Stack

| Technology | Version / Package |
|---|---|
| **Flutter** | 3.41.9 |
| **Dart** | 3.11.5 |
| **Auth & Backend** | Firebase Auth |
| **Local Storage** | `hive` + `hive_flutter` |
| **Charts** | `fl_chart` |
| **Notifications** | `flutter_local_notifications` |
| **Audio** | `audioplayers` |
| **Fonts** | `google_fonts` — Poppins |
| **Date Formatting** | `intl` |

---

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK 3.41+ installed
- A Firebase project with Authentication enabled

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/progress_app.git
cd progress_app

# 2. Add your Firebase config files
#    Android: place google-services.json in android/app/
#    iOS:     place GoogleService-Info.plist in ios/Runner/

# 3. Install dependencies
flutter pub get

# 4. Run the app
flutter run
```

> **Note:** Enable Google Sign-In and Email/Password in your Firebase Console under Authentication → Sign-in methods.

---

## 📖 How to Use

1. **Sign in** with Google, Email/Password, or tap *Continue as Guest*
2. **Complete onboarding** to learn the key features
3. **Add tasks** using the + FAB — set a title, category (Personal/Professional), recurrence type, and optional reminder time
4. **Check off tasks** during the day to build your streak and earn badge milestones
5. **Use the Focus Banner** at the top of your timeline to tackle your most urgent pending task first
6. **Browse the Calendar** to see your productivity heatmap and spot patterns
7. **Check Analytics** for chart breakdowns by week, month, or year
8. **Review Insights** to find your peak productive hour and Personal vs Professional split
9. **Search and filter** your task list to quickly find what you need

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Built with ❤️ using Flutter & Firebase

*PROgress v1.0.0 — Daily Productivity & Habit Tracker*

</div>
