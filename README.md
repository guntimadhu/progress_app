# PROgress - Daily Task Tracker

![Flutter](https://img.shields.io/badge/Flutter-3.41.9-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth-orange?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-3.11.5-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

> Level up everyday

## About
PROgress is a feature-rich Flutter productivity app that helps you track daily tasks, build streaks, and visualize your progress with beautiful analytics. Level up your productivity one task at a time.

## Screenshots
Screenshots coming soon

## Features
- Firebase Auth with Google Sign In, Email and Password, and Guest mode
- Daily task timeline with Personal and Professional categories
- 7 recurring task types: once, daily, weekday, weekend, weekly, monthly, every X days
- Streak tracking with Bronze, Silver, and Gold badges at 3, 7, and 30 days
- Focus Task banner highlighting first pending task
- Search, filter, and sort tasks
- Calendar view with color-coded heatmap
- Smart insights showing best productive hour and weekday vs weekend stats
- Analytics with doughnut and bar charts for weekly, monthly, and yearly views
- Reminders with local notifications
- End-of-day missed task alert at 23:55
- Undo delete with 7-second toast
- Dark mode
- Sound effects on task completion
- Onboarding slides on first launch

## Streak System
| Badge | Days Required |
|---|---|
| Bronze | 3 or more consecutive days |
| Silver | 7 or more consecutive days |
| Gold | 30 or more consecutive days |

## Recurring Task Types
- Once: single day task
- Daily: every day
- Weekday: Monday to Friday
- Weekend: Saturday and Sunday
- Weekly: select specific days
- Monthly: select specific dates
- Every X Days: custom interval

## Tech Stack
| Technology | Purpose |
|---|---|
| Flutter 3.41.9 | UI framework |
| Firebase Auth | Authentication |
| Hive | Local task storage |
| fl_chart | Analytics charts |
| flutter_local_notifications | Reminders |
| audioplayers | Sound effects |
| google_fonts Poppins | Typography |

## Getting Started
git clone https://github.com/guntimadhu/progress_app.git
cd progress_app

Add your google-services.json from Firebase Console to android/app/

flutter pub get
flutter run

## How to Use
1. Sign in with Google or Email
2. Tap + to add your first task
3. Set time, category, and recurring schedule
4. Check off tasks throughout the day
5. Build your streak and earn badges
6. Track progress in Analytics tab

## Contributing
Contributions are welcome!

## License
MIT License
