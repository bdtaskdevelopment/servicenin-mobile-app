# ServiceNin — Mobile App (Flutter)

Smart Citizen Super App for Dhaka. One identity (phone + OTP, JWT) → 12 service
modules. This repo is the Android + iOS app. The **visual + behavioural source of
truth** is the HTML design system (13 module prototypes); this app re-implements it
in Flutter against the ServiceNin REST API.

> Generated as a secure foundation + auth vertical slice. Continue module-by-module
> using the design prototypes as reference and the endpoint map below.

## Run

```bash
flutter pub get

# Android emulator (host localhost is 10.0.2.2)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

# iOS simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8080

# Physical device (same Wi-Fi as your API host)
flutter run --dart-define=API_BASE_URL=http://<your-LAN-IP>:8080
```

`API_BASE_URL` defaults to `http://10.0.2.2:8080` (see `lib/core/config/env.dart`).
The REST prefix `/api/v1` is appended automatically.

## Architecture

```
lib/
  app/            providers.dart (Riverpod DI + AuthController), router.dart (go_router + auth guard)
  core/
    config/       env.dart            — build-time config, base URLs
    network/      api_client.dart     — single configured Dio
                  auth_interceptor.dart — Bearer + single-flight 401 refresh + retry
    storage/      token_store.dart    — flutter_secure_storage (Keychain/Keystore)
    theme/        app_theme.dart      — design tokens (colors, fonts, module accents)
  features/
    auth/         data/ (models, repository) + ui/ (splash, phone, otp)
    dashboard/    ui/ (stub — build the 12-tile grid next)
```

State: **Riverpod**. Navigation: **go_router** with an auth `redirect`. HTTP: **Dio**.

## Security model (implemented)

- **Tokens** (`access_token`, `refresh_token`) are stored ONLY in
  `flutter_secure_storage` — iOS Keychain (`first_unlock`) / Android
  Keystore-backed encrypted storage. Never SharedPreferences, never plaintext.
- **AuthInterceptor** attaches `Authorization: Bearer <access>` to every
  non-auth request.
- On **401**, it performs a **single-flight** `/auth/refresh` (concurrent 401s
  await one refresh), updates the access token, and **retries the original
  request once**. If refresh fails → tokens cleared → `onLogout` → router sends
  user to `/phone`.
- Auth endpoints (`/auth/*`) never receive a stale Bearer header.

### Security TODO (do before production)
- **HTTPS only** in staging/prod (`Env.isProd` is wired; reject `http://` there).
- **Certificate pinning** (add a `badCertificateCallback` / pinned SHA-256 on Dio's
  `HttpClientAdapter`).
- **Biometric gate** on app resume for sensitive modules (wallet, payments) — the
  signup flow already designs for it; use `local_auth`.
- **Jailbreak/root + screenshot** hardening for KYC/payment screens.
- Clear tokens on `403 account disabled` and on app uninstall (Keychain may persist
  on iOS — clear on first run via a SharedPreferences "installed" flag).

## API endpoint → feature map (ServiceNin REST v1)

| Feature | Endpoints |
|---|---|
| Auth | `POST /auth/login`, `/auth/verify-otp`, `/auth/register`, `/auth/resend-otp`, `/auth/refresh` |
| Account | `GET /users/me`, `PUT /users/me/profile`, `GET /languages`, `/translations`, `/settings` |
| Healthcare | `GET /healthcare/doctors(/:id)(/venues)`, `POST /healthcare/appointments`, `GET /healthcare/appointments/my` |
| Ambulance | `GET /ambulance/types`, `/available`, `POST /ambulance/fare/estimate`, `/ambulance/bookings`, `GET /ambulance/bookings`, `POST /ambulance/driver/location` |
| Blood | `donors/register`+`verify-otp`, `donors/nearest`, `donors/leaderboard`, `donors/me`, `PATCH availability/notifications`, `requests` CRUD + `respond/accept/dismiss`, `fulfillments/:id/ confirm·chat·location·voice/token` |
| Home Service | `services/categories·catalog·sub-services·providers`, `POST /services/book`, `bookings/:id status·timeline·chat·location·proof·rate·dispute`, `plans`, `subscriptions/*`, `provider/jobs·earnings·balance·withdrawals` |
| Physio | `GET /physio/centers`, `POST /physio/appointments`, `GET /physio/appointments/my` |
| Matchmaking | `GET/POST /matchmaking/profiles`, `GET /matchmaking/interests/received` |
| Jobs | `GET /jobs(/:id)`, `POST /jobs`, `/jobs/:id/apply`, `GET /jobs/applications/my` |
| Education | `GET /education/centers(/:id)(/courses)`, `POST /education/interests` |
| Nagarik | `POST/GET /nagarik/grievances(/:id)`, `/nagarik/tickets(/:id)`, `/tickets/:id/messages` |
| Info | `GET /info`, `/info/emergency`, `/info/:id` |

Auth column: most module endpoints require the JWT (the interceptor handles it).

## Status in this drop (what's wired vs. to build)

- ✅ **Secure core** — JWT storage, Dio + refresh interceptor, env config.
- ✅ **Auth** (splash/phone/OTP) + **Account** (profile + edit) — full screens.
- ✅ **Dashboard** — real 12-tile grid (`lib/app/modules.dart`) routing to every module.
- ✅ **Data layer for ALL 12 modules** — typed models + repositories covering every
  endpoint, all sharing the authenticated Dio:
  `lib/features/{ambulance,blood,services,healthcare}/data/…` and
  `lib/features/more/data/more_apis.dart` (physio, matchmaking, jobs, education,
  nagarik, info, funeral). Providers in `lib/app/repositories.dart`.
- ✅ **Ambulance** — a worked example screen wired to its repo
  (`ambulance_home_screen.dart`) — copy this pattern.
- 🟡 **Remaining module screens** — each route currently shows `ModuleScaffold`
  (repo already injected). Build the multi-screen UI from the matching HTML
  prototype, calling the ready repository. This is the ideal task for **local
  Claude Code**: "Build the <module> screens from its HTML prototype using
  `<module>Repo`." Nothing else is blocking.

## Build order (matches the design prototypes)
Auth ✅ → Account → Ambulance → Blood → Home Service → Healthcare → Physio →
Matchmaking → Jobs → Education → Nagarik → Info → Funeral.

For each module: create `features/<module>/data/` (models + repository using the
shared Dio) and `features/<module>/ui/` (screens mirroring the HTML prototype).
Keep one repository per API group; reuse `AppColors.<accent>` per module.

## Design reference
The HTML prototypes (one file per module + `ServiceNin App.html` full tester)
are the canonical UI. Match layout, copy (bilingual বাংলা/English), spacing,
and the per-module accent color. Re-create interactions; don't pixel-trace.
