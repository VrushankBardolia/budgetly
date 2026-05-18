<div align="center">

# Budgetly

**A modern personal budget & expense tracker built with Flutter and Firebase.**

Track expenses, manage budgets, and understand your spending — all in one clean app.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase)](https://firebase.google.com)
[![GetX](https://img.shields.io/badge/GetX-State%20Management-8A2BE2)](https://pub.dev/packages/get)
[![Version](https://img.shields.io/badge/Version-1.5-success)](#changelog)

</div>

---

## Overview

Budgetly is a Flutter-based mobile app that makes personal finance simple. Whether you're logging daily coffee runs or tracking a full year's financial flow, Budgetly gives you the tools to stay on top of your money.

---

## Features

### Security
- **Biometric authentication** — unlock with fingerprint or Face ID

### Expense Tracking
- Add, edit, and delete daily expenses
- Restrict future date selection to keep records accurate
- View current month's expenses directly from the home screen

### Categories
- Create custom categories with emoji icons
- Dedicated category detail screen with spending breakdown
- Transaction count and total amounts per category

### Monthly View
- Full monthly expense breakdown
- Sort and filter transactions with ease

### Sheets *(new in 1.5)*
- Manage and track yearly financial flow
- View your total sheet balance right from the home tab

### Budget
- Set monthly budgets per category
- Track spending against your limits in real time

### Insights
- Pie and line charts for visual spending analysis
- Dashboard updated with improved data visualization

### Profile
- Edit your profile details
- Delete your account at any time

### Reminders
- Daily push notifications to log your expenses on time

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| State Management | GetX |
| Backend & Auth | Firebase (Firestore, Auth) |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- A Firebase project with Firestore and Authentication enabled

---

## Changelog

### v1.5 *(Latest)*
- Introduced **Sheets** — manage and track yearly financial flow
- Added total sheet balance card on the Home tab
- Refined card UI for a more modern look

### v1.4
- Biometric authentication (fingerprint / Face ID)
- Sort and filter options in the month detail screen
- Manage Profile screen with delete account support
- Category Details screen for deeper spending insights
- Improved dashboard chart visualization

### v1.3.2
- Restricted future date selection when adding or editing expenses
- Fixed user initials not showing in the Settings tab
- Minor bug fixes and stability improvements

### v1.3.1
- Fixed dashboard data not loading after a fresh install and login

### v1.3
- Daily notification reminders to log expenses
- Removed email/password authentication in favour of Google Sign-In
- Added initial loading screen for a smoother startup experience

### v1.2.1
- Fixed black screen on app launch

### v1.2
- Google Sign-In support
- New Categories tab for better transaction organisation
- Transaction count and totals displayed on category tiles

### v1.1
- Current month expenses visible directly on the home screen
- Toggle to open the current month detail screen from home
- Improved bottom navigation bar visibility
- Shimmer loading effects for a smoother feel
- Refreshed icon set

### v1.0
- Expense tracking with add, edit, and delete
- Custom categories with emoji support
- Year-wise and month-wise expense views
- Budget setting and comparison
- Analytics with pie and line charts
- Dark-themed modern UI

---

## License

This project is licensed under the [MIT License](LICENSE).