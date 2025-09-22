# Repository Guidelines

## Project Structure & Module Organization
- Source: `lib/`
  - Core: `lib/core/` (e.g., `theme.dart`, `di.dart`, `app_shell.dart`)
  - Features (DDD): `lib/features/<feature>/{domain,data,presentation}/`
    - Example: `lib/features/jobs/presentation/pages/discover_page.dart`
- Tests: `test/` (mirrors `lib/`), files end with `_test.dart`.
- Assets: `assets/` (declared in `pubspec.yaml`).
- Platforms: `android/`, `ios/`.

## Build, Test, and Development Commands
- Install deps: `flutter pub get`
- Analyze: `flutter analyze` (uses `flutter_lints` from `analysis_options.yaml`).
- Format: `dart format .` (run before committing).
- Run app: `flutter run -d ios|android|chrome`
- Tests: `flutter test` (add `--coverage` for LCOV).
- Build artifacts: `flutter build apk` | `flutter build ios`
- Codegen (if annotations used): `dart run build_runner build --delete-conflicting-outputs`

## Coding Style & Naming Conventions
- Follow Dart defaults and `flutter_lints`.
- Indentation: 2 spaces; max line length per formatter.
- Naming: `UpperCamelCase` types, `lowerCamelCase` members, `lower_snake_case` files.
- Architecture: keep feature code within `lib/features/<feature>/...` and shared code in `lib/core/`.
- Do not edit generated files (`*.g.dart`, `*.freezed.dart`).

## Testing Guidelines
- Frameworks: `flutter_test`, `bloc_test`, `mocktail`.
- Place tests under `test/` mirroring `lib/` paths; name with `_test.dart`.
- Include widget tests for UI and bloc/use‑case tests for logic.
- Golden tests belong in `test/golden_*` or similar; commit stable assets.
- Aim for 80%+ coverage on critical features.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`; optional scope (e.g., `feat(auth): add signup flow`).
- Keep subject ≤72 chars; imperative mood.
- PRs should include:
  - Clear description and motivation; link issues.
  - Screenshots/GIFs for UI changes.
  - Notes on testing and any migrations.
  - Checklist: `flutter analyze`, `dart format .`, and `flutter test` all pass.

## Security & Configuration
- Don’t commit secrets, keystores, or provisioning profiles.
- Pass environment values via `--dart-define` and read with `String.fromEnvironment`.
- Keep API clients and injection in `lib/core/di.dart` to centralize config.

