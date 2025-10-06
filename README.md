# ZIBENE SECURITY – Flutter UI

Prototype UI implementing the features from `FRONCTIONNALITES.md` with the dark design seen in the screenshots. The app contains two navigation shells: Client and Admin. All data is mocked for now (no backend wiring).

## Run

1. Flutter 3.x installed
2. From project root:
   - `flutter pub get`
   - Ensure Firebase is configured (see Firebase setup below)
   - Run with Stripe key (optional for development):
     `flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=YOUR_STRIPE_PK`

### Firebase Setup

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project named "zibene-security" or similar
   - Enable Authentication (Email/Password provider)
   - Enable Cloud Firestore
   - Enable Firebase Storage (for profile pictures)

2. **Configure FlutterFire**:
   - Run `flutterfire configure` in project root
   - This will generate `firebase_options.dart` with your project configuration
   - The app automatically uses these settings

3. **Database Structure**:
   - Collections are automatically created when first used:
     - `users`: User accounts with role-based access
     - `agent_profiles`: Extended agent information
     - `bookings`: Service bookings with status tracking
     - `payments`: Payment records with Stripe integration
     - `reviews`: Client ratings and feedback
     - `notifications`: User notifications

Notes
- Firebase configuration is handled automatically via `firebase_options.dart`
- Security rules are enforced at the Firestore level
- The app works offline with local persistence enabled

## Roles

- Welcome → Log In → choose role (Client or Admin)
- Client shell tabs: `Home`, `Agents`, `Bookings`, `Profile`
- Admin shell tabs: `Dashboard`, `Agents`, `Users`, `Reports`
  - Drawer: `Alerts`, `System Monitor`, `Roles & Permissions`, `Send Notification`, `Activity Log`

## Code Map

- `lib/utils/theme.dart` – Dark theme and palette (#121212 background, yellow #FFC107)
- `lib/screens/shells/*` – Client/Admin navigation shells
- `lib/screens/user/*` – Client-facing pages (search agents, booking flow, profile/settings)
- `lib/screens/admin/*` – Admin pages (dashboard, agents/users, reports, alerts, etc.)
- `lib/services/mock_data_service.dart` – In-memory demo data

## Next

- Add full flows (reviews, payments capture, exports)
- Implement role-based auth guards and permissions
- Add real-time messaging and live location tracking
