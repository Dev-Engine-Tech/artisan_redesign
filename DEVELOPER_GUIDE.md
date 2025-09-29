# Artisans Circle — Developer Guide

This guide helps newer developers work effectively in this codebase using BLoC, SOLID principles, and a TDD workflow. It covers structure, dependencies, patterns, and common change‑flows.

## Project Structure

- Source: `lib/`
  - Core: `lib/core/` — shared infra (DI, networking, theme, widgets, services)
  - Features (DDD): `lib/features/<feature>/{domain,data,presentation}/`
    - Domain: entities, repositories (abstract), usecases
    - Data: models, remote/local datasources, repository implementations
    - Presentation: blocs/cubits, pages, widgets
- Tests: `test/` mirrors `lib/`; files end with `_test.dart`.
- Assets: `assets/` (declared in `pubspec.yaml`).
- Platforms: `android/`, `ios/`.

## Key Technologies

- State management: `bloc` + `flutter_bloc`
- DI: `get_it`
- Networking: `dio` via `HttpService` abstraction
- Testing: `flutter_test`, `bloc_test`, `mocktail`

## How Things Fit Together (SOLID Overview)

- Single Responsibility — keep classes focused:
  - `RemoteDataSource`: Only HTTP + JSON parsing
  - `RepositoryImpl`: Adapts data sources to domain interfaces
  - `UseCase`: Single action (e.g., `GetJobs`)
  - `Bloc`: Orchestrates usecases → states for UI
- Open/Closed — prefer extending via new classes (e.g., new usecases) over editing internals
- Liskov Substitution — respect interfaces (`JobRepository`) for testing and swapping impls
- Interface Segregation — small, focused abstractions (`HttpService`, `JobRepository`)
- Dependency Inversion — depend on abstractions; inject concrete impls in DI (`core/di.dart`)

## BLoC in Practice

1. Events describe user intents or lifecycle triggers (e.g., `LoadJobs`).
2. Bloc receives events, calls usecases, wraps results into states (e.g., `JobStateLoaded`).
3. UI reacts to states via `BlocBuilder` / `BlocListener`.

Example: Jobs
- Domain/usecases: `features/jobs/domain/usecases/*`
- Data: `features/jobs/data/*` (Dio calls, parsing)
- Bloc: `features/jobs/presentation/bloc/*`
- UI: `features/jobs/presentation/pages/*`, widgets under `widgets/`

## Networking & Configuration

- Endpoints in `core/api/endpoints.dart`.
- Dio is configured in `core/di.dart` and injected everywhere; `HttpService` wraps Dio with caching and request de‑duplication.
- Auth headers are added by an interceptor (token from `SecureStorage`).

Banner example
- `core/services/banner_service.dart` selects the best endpoint and parses multiple API shapes.
- `features/home/presentation/widgets/enhanced_banner_carousel.dart` consumes the service.

## Common Change Flows

### Add a new API endpoint
1. Add constant to `core/api/endpoints.dart`.
2. Update the relevant `RemoteDataSource` to call it and parse JSON into `Model`.
3. Map `Model` → `Entity` in repository or `Model` directly if already an entity.
4. Add/extend `UseCase` to wrap the repository call.
5. Add event/handler in the `Bloc` that invokes the new usecase and emits states.
6. Update UI to dispatch the event and render states.
7. Write tests (see TDD section).

### Add a new job/application status or UI action
- Update `features/jobs/domain/entities/job_status.dart` with new variants/parsing.
- Ensure `JobModel.fromJson` understands the new fields.
- Add state/branch in `JobDetailsPage` and `ApplicationCard` to show the right buttons.
- Test state rendering via widget tests and bloc tests.

### Modify Orders tab behavior
- Orders derive from `CatalogRequestsBloc` events/states.
- UI is in `features/home/presentation/widgets/home_tab_section.dart` (`OrdersTabContent`).
- Buttons dispatch `ApproveRequestEvent`/`DeclineRequestEvent`; after success, refresh with `RefreshCatalogRequests()`.

### Banners not loading
- Check `core/services/banner_service.dart` and ensure:
  - Auth token exists in `SecureStorage`.
  - Category strings in `BannerCategoryExtension` match backend.
  - One of the fallback endpoints is valid for your environment.

## TDD Workflow (Recommended)

1. Write a failing unit test for your usecase/repository behavior (mock the datasource).
2. Implement the smallest code to pass (usecase → repository → datasource).
3. Add bloc test for the event→state expectations.
4. Add widget test for UI (rendering states).
5. Refactor while keeping tests green.

Testing tools
- `bloc_test` for bloc: arrange mocks → dispatch event → expect states.
- `mocktail` for mocking repositories or datasources.
- `flutter_test` for widget tests; pump widgets with `BlocProvider`/`RepositoryProvider` and assert UI.

## Coding Standards

- Follow `flutter_lints` (see `analysis_options.yaml`).
- No `print()` statements (use structured logs or temporary `debugPrint`/`dev.log` gated in debug if needed). This repo removed direct prints.
- File naming: `lower_snake_case.dart`.
- Types: `UpperCamelCase`; members: `lowerCamelCase`.
- Keep feature code within `lib/features/<feature>` and shared code in `lib/core`.

## Running & Tooling

- Install deps: `flutter pub get`
- Analyze: `flutter analyze`
- Format: `dart format .`
- Run app: `flutter run -d ios|android|chrome`
- Tests: `flutter test` (add `--coverage` for LCOV)
- Build: `flutter build apk` | `flutter build ios`
- Codegen (if needed): `dart run build_runner build --delete-conflicting-outputs`

## Dependency Injection (get_it)

- All concrete implementations are registered in `core/di.dart`.
- Blocs are registered as factories; external clients (Dio, SecureStorage) are singletons.
- In widgets, prefer `BlocProvider.value(value: getIt<MyBloc>())` if the instance is provided by AppShell, or `BlocProvider(create: (_) => getIt<MyBloc>())` for isolated pages.

## Performance & Security Notes

- HTTP client has caching and de‑duplication; prefer `HttpService` over creating raw `Dio`.
- SSL relaxations are dev‑only and isolated; do not enable in production.
- Avoid heavy work in build methods; use `BlocBuilder` and lazy lists.
- Do not log secrets; avoid `print()` logs in production paths.

## Examples

### New feature outline
```
lib/features/awesome/
  domain/
    entities/awesome.dart
    repositories/awesome_repository.dart
    usecases/get_awesome.dart
  data/
    models/awesome_model.dart
    datasources/awesome_remote_data_source.dart
    repositories/awesome_repository_impl.dart
  presentation/
    bloc/awesome_bloc.dart (events, states)
    pages/awesome_page.dart
    widgets/awesome_card.dart
```
Wire it in `core/di.dart`, then write tests for usecase + bloc + widget.

### UI placeholder (images)
- Job cards (discover): if no `thumbnailUrl`, show subtle avatar placeholder with first letter (already implemented in `DiscoverJobCard`).

## Troubleshooting

- Orders tab spinning:
  - Ensure `LoadCatalogRequests()` is dispatched on the same bloc the UI reads (provided by AppShell). Do not create and close your own instance in pages.
- Banners not loading:
  - Confirm token and category mapping; use one of the fallback endpoints in `BannerService`.
- iOS build error “Directives must appear before any declarations”:
  - Always place `import` statements before class declarations (fixed in `JobBloc`).

## Contribution Guidelines

- Use Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`)
- Keep changes focused; update or add tests accordingly.
- Ensure `flutter analyze`, `dart format .`, and `flutter test` pass before pushing.

Happy building!
