# Project guide: how this Flutter app is built

Hand-off notes from the Casa Pointage project (staff attendance app for sector
supervisors: face clock-in, team list, absences, history). Use them to build the
same kind of app in a new project with the same structure and habits.

The domain (attendance) is only an example. The structure, patterns and pitfalls
below apply to any app built the same way.

## 1. Stack

- Flutter, Dart `^3.9.2`, **GetX** (`get`) for state, routing and DI.
- `flutter_screenutil` for sizing: `.w`, `.h`, `.r`, `.sp` everywhere.
- Localization with ARB files: **French is the template**, Arabic is RTL.
  `flutter_localizations` + `intl`, `generate: true`.
- `flutter_svg` for the custom icon set, `google_fonts`.
- `camera`, `image_picker`, `connectivity_plus`, `uuid`.
- Already in `pubspec.yaml` but **unused** (kept from the template): `dio`,
  `hive`, `injectable`, `freezed`, `get_it`, `flutter_secure_storage`.

## 2. Folder structure

```
lib/
  main.dart                 GetMaterialApp, locale, theme, ResponsiveShell
  base_imports.dart
  app/
    routes/                 app_pages.dart (GetPage list), app_routes.dart (part file)
    data/
      models/               plain immutable Dart classes + enums
      repo/                 abstract repos + Mock implementations
      utils/                pure business rules (e.g. attendance_rules.dart)
    modules/
      <feature>/
        bindings/<feature>_binding.dart
        controllers/<feature>_controller.dart
        views/<feature>_view.dart
        widgets/            feature-only widgets
  core/
    theme/                  app_colors.dart, app_theme.dart
    widgets/                shared: app_button, app_chip, app_icon, status_pill, ...
    localization/           locale_controller.dart, l10n_labels.dart
    utils/                  bidi.dart (ltr() for numbers/times in RTL)
  l10n/                     app_fr.arb (template), app_ar.arb
  generated/l10n/           generated, never edit
l10n.yaml                   arb-dir lib/l10n, output lib/generated/l10n
```

One module per screen (or per tab). Tabs live inside the `home` shell (an
`IndexedStack`); each tab has its own binding that `HomeBinding` calls.

## 3. Patterns to copy

**Repo interfaces, mock implementations.** Screens depend only on abstract
repos (`TeamRepo`, `AuthRepo`, `FaceRecognizer`). The mock keeps data in memory
and exposes `Stream<void> changes` so open screens refresh when data changes.
There is **no backend**. Do not build an API, offline store or sync layer
until the user says an API spec exists.

**Shared data registration.** `TeamBinding.registerData()` registers the repos
as `permanent: true`, guarded by `Get.isRegistered`, and every binding calls it.
That is what keeps the mock data alive between screens.

**Binding + controller + view.**
- Binding reads `Get.arguments` (a `String` id, an enum, or a small args class)
  and builds the controller with `Get.lazyPut`.
- Controller extends `GetxController`, uses `.obs` fields, loads in `onInit`,
  listens to `repo.changes`, and cancels subscriptions and timers in `onClose`.
- View extends `GetView<Controller>`, reads observables **inside** `Obx`.
  A widget that reads `.value` outside an `Obx` closure will not rebuild.

**Routes.** Add the constant in both `_Paths` and `Routes` in
`app_routes.dart`, add a `GetPage` in `app_pages.dart`. The route-name lints
(`constant_identifier_names`) are expected and ignored.

**Navigation with arguments.** Pass a matricule/id string, or a small class
(`ManualClockArgs`, `ClockDoneArgs`). Use `Get.toNamed` to push,
`Get.offNamed` to replace, `Get.until` to return to a route,
`Get.offAllNamed` for sign-out.

**Form screens** (manual clock-in, absence, anomaly): header with a close
button, numbered section titles, chips for choices, optional text field, a
fixed bottom bar with the submit button that stays disabled until the form is
valid, with a one-line hint saying what is missing. Selecting a selected chip
clears it.

**Localization.**
1. Add the key to `app_fr.arb` (with `@key` placeholders when needed) and to
   `app_ar.arb`.
2. Run `flutter gen-l10n`.
3. Enum labels live in `core/localization/l10n_labels.dart` as extensions.
No hardcoded user-facing strings.

**RTL.** Use `AlignmentDirectional`, `PositionedDirectional`, `EdgeInsetsDirectional`
when direction matters, and wrap times/numbers in `ltr()`. Direction icons
have `mirrorInRtl`.

**Mock data.** Deterministic, based on an FNV hash of id + date, so history
looks stable. Today's data is relative to the current shift so every state
appears.

**Camera.** The scan and enrolment screens show a silhouette when no camera is
available. Face recognition and enrolment are simulated behind
`FaceRecognizer` and `TeamRepo.saveEnrolment`.

**Placeholders.** `showComingSoon(context)` shows a toast for actions whose
screen does not exist yet.

## 4. Screens built (reference list)

Login, team list (home tab), face scan, clock-in confirmation, manual clock-in
(person, reason, photo), person detail, absence declaration, anomaly report,
enrolment tab + face capture, history tab + day detail, profile tab, pending
sync screen.

## 5. Commands

```bash
flutter pub get
flutter gen-l10n
flutter analyze lib/app/modules lib/app/data lib/core lib/main.dart
flutter run -d web-server --web-port 8099
```

Expected analyze output: only route-constant naming lints, plus old template
warnings in `lib/app/data/datasources/remote/errors/exceptions.dart`.

## 6. Pitfalls we hit

- **Disk space.** `flutter run` writes temp folders to `%TEMP%\flutter_tools.*`
  (about 175 MB each). Delete them before every run when C: is low.
- **Stale web build.** The browser can serve an old compiled app. Reload with a
  new query string (`/?v=2`) after changing code.
- **Hot reload is not used.** Restart the web server after each change.
- **Check `Get.find` order.** Controllers used by a tab must be registered in
  the tab's binding (called from `HomeBinding`) or the view throws.
- **ARB placeholders.** A placeholder needs its `@key` block with a `type`, or
  the generated method has the wrong signature.
- **Enum label switches** must be exhaustive, so adding an enum value needs a
  label and ARB keys in both languages.
- **Unused imports** show up as warnings after refactors. Run analyze on the
  touched folders every time.

## 7. Testing in the Claude browser pane (quirks)

- The pane blocks the camera. Camera and photo steps cannot be tested there.
- Screenshots often look **clipped on the right and bottom** after the viewport
  changes. The page itself is fine. Fix: pin the viewport with
  `resize_window` 374x646, then navigate to the app twice (new `?v=` each
  time), then log in.
- Click coordinates are in the screenshot frame (about 468x808), not CSS pixels.
- A tap too early after typing can hit a disabled button: wait a second.
- To test offline behavior, override `navigator.onLine` and
  `navigator.connection` with JS and dispatch an `offline` / `online` event.
- Typed text in Flutter fields works after clicking the field.
- Demo login for the mock auth: `h.idrissi` / `demo2026`.

## 8. How to work with the user

- Reply in the same language the user writes in; they prefer short answers
  with the next action first (ADHD-friendly style: numbered steps, one next
  action at the end, no filler).
- Build one screen at a time, test it in the browser, then say what was not
  tested.
- Write a task list for each request and a recap at the end.
