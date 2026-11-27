# MyGrade — Windows deployment guide

## 1. Install and configure

Use Node.js 22 LTS, at least 22.13, and VS Code PowerShell. From this folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup.ps1
code .env
```

The setup script copies `.env.example` only if `.env` is absent, installs locked dependencies using npm ci, and runs the original reader tests. The execution policy applies only to this process. Fill the two public values from your authorized Supabase project's Connect/API Keys page. Use the `sb_publishable_` key, not the secret or legacy service-role key. Save `.env`, then run `npm.cmd run check:config` (format check only). No database password goes in this app. A fresh Supabase project has no existing cloud backups or cloud accounts. For an existing deployment, obtain owner approval, use the original project and original signing credentials, and plan backup/data migration before switching projects.

## 2. Configure Supabase once

- https://supabase.com/dashboard — create or open your authorized project.
- SQL Editor: copy the supplied SQL with `Get-Content -Raw .\supabase\setup.sql | Set-Clipboard`, paste in New query, and Run. Verify `public.backups` exists and has row-level security enabled. For an existing project, review policies before running this SQL: it replaces four named policies.
- Authentication: enable Email/password and Allow anonymous sign-ins. Keep email confirmation enabled for real use and configure SMTP for production email delivery. The app uses email/password for backup and separate anonymous sessions for AI scanning.
- https://aistudio.google.com/apikey — create or obtain an authorized Gemini key. In Supabase Edge Functions > Secrets add `GEMINI_API_KEY`. The optional `GEMINI_MODEL` and `GEMINI_HANDWRITING_MODEL` override the source default `gemini-3.5-flash`; verify model availability and quota in your account. Never put Gemini in `.env`, EAS public variables, source or chat.
- Log into Supabase CLI, then deploy (the script prints and confirms the target project):

```powershell
npx.cmd --yes supabase login
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\deploy-reader.ps1
```

The function has its own bearer-token verification (`auth.getUser`); the deploy flag disables the gateway legacy JWT check, not the function's authentication. Supabase supplies its internal URL and anon key as runtime environment variables. No Docker is required with API-based deployment.

## 3. Run and test

```powershell
npm.cmd run check:config
npm.cmd run test:reader
npm.cmd run test:reader:live
npx.cmd expo start --clear
```

Live test uses synthetic photos, creates an anonymous user and consumes Gemini quota. It is optional but recommended before shipping. Scan the Expo QR code using a compatible Expo Go version on Android if supported by your device/SDK; otherwise build and install the APK below. A native module may require a native build. This is a mobile project; a browser is not a validated replacement. Test local teacher registration, manual entry offline, cloud signup/login/backup/restore, scanner success/failure and report export on Android. Use only fictitious student records during testing.

## 4. Android APK via Expo EAS

Sign in at https://expo.dev, then from this folder:

```powershell
npx.cmd --yes eas-cli@latest login
npx.cmd --yes eas-cli@latest init
```

Choose your authorized Expo account and create or link the intended EAS project. The old EAS project reference was removed intentionally; the Android package `com.scilla.mygrade` is unchanged. To update an existing installed app, retain its package ID and original signing key; a new key may prevent updates. Coordinate with the existing owner before distributing or publishing.

In the new Expo project dashboard, create the two public variables from `.env` in the **preview** environment (Plain text visibility): `EXPO_PUBLIC_SUPABASE_URL` and `EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY`. This is necessary because `.env` is ignored by Git/EAS uploads. Alternatively use the EAS CLI env:set commands shown in Expo documentation. Never upload Gemini or DB credentials. For production profile builds, set the same public variables in the production environment too.

```powershell
npx.cmd --yes eas-cli@latest build --platform android --profile preview
```

If asked to initialize Git, approve only for this clean extracted copy (or use an existing authorized Git repo). If asked for a keystore, generate one for a NEW app only. For an update use the existing signing credentials. Download the APK from the EAS build page after it succeeds and install on Android. This is not a Play Store release; an AAB and store setup are separate.

## 5. Deployment changes and limits

- Moved original public Supabase settings to Expo public environment variables, with a format check and offline fallback. This package accepts standard hosted Supabase URLs and publishable keys.
- Removed the original EAS account/project bindings and Supabase CLI linked-project cache. Preserved the Android application ID, screens, existing SQLite schema, cloud SQL and AI implementation.
- Added setup and function deployment scripts, example environment file, ignore rules and explicit EAS environments. Updated live test environment loading and removed the broken starter reset script command. Corrected the original README: current scanning sends the image to Gemini directly; local ML Kit helpers are not used in this path.
- Before public use: review anonymous sign-in abuse protection (CAPTCHA/rate limits, per-user AI quotas), restrict usage, and set Gemini billing limits. The existing function accepts anonymous authenticated sessions; it does not implement a per-user AI spending limit. Enabling CAPTCHA may require adapting the app's anonymous login. Backups include student records and local teacher credential hashes; assess data protection, retention and cloud permissions. Do not send real student photos without authorization. These production security improvements are not implemented here.
- Offline reader tests pass in the preparation environment. Dependency installation, native build, live cloud services and device testing are not verified here. This package is configured for deployment but is not a certified production build.
