# Smart-Care Flutter App

A fully functional Flutter implementation of the Smart-Care medical platform UI.

## Screens

1. **Splash / Landing** (`/`) — Hero image, feature highlights, Get Started & Login CTAs
2. **Onboarding** (`/onboarding`) — 3-page carousel: Smart Search, Online Booking, Seamless Care
3. **Role Selection** (`/role`) — Doctor vs Patient role picker with animated cards
4. **Login** (`/login`) — Practitioner login with SSO, form validation, keep-me-logged-in
5. **Register** (`/register`) — Patient/Practitioner toggle, full registration form with specialty dropdown

## Setup

```bash
cd smart_care
flutter pub get
flutter run
```

## Requirements

- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.0.0

## Dependencies

- `google_fonts` — DM Sans typography
- `smooth_page_indicator` — page dots
- `flutter_svg` — SVG support

## Color Palette

| Token         | Hex       | Usage                  |
|---------------|-----------|------------------------|
| Primary       | #0D3B38   | Buttons, headers       |
| Accent        | #F5C518   | CTAs, highlights       |
| Teal          | #3DB8A8   | Icons, badges          |
| Background    | #F5F7F5   | Screen backgrounds     |

## Navigation Flow

```
Splash → Onboarding → Role Selection → Login ↔ Register
```

All navigation is active and wired up using named routes.
