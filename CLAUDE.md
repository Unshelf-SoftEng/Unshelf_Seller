# Project Rules -- Unshelf Seller

## Coding Standards

Follow `CODING_STANDARDS.md` in the project root for all code conventions, naming, architecture patterns, testing patterns, and git practices.

## Git Workflow

- **Atomic commits**: Each commit should do exactly one thing. Never bundle unrelated changes.
- **No co-authored-by**: Do not add `Co-Authored-By` lines to commit messages.
- **Branch per phase**: Create a separate branch for each refactoring phase under `feature/`:
  - `feature/phase-1-bug-fixes`
  - `feature/phase-2-security`
  - `feature/phase-3-foundation`
  - `feature/phase-4-architecture`
  - `feature/phase-5-polish`
- Branch off `main` for each phase. Merge into `main` when phase is complete.

## Quality Gates

- **Code review before completion**: Every task must be reviewed by a separate agent before marking it as complete. Do not self-approve.
- **Tests before completion**: Every task must have passing tests verified (`flutter test` or `flutter analyze`) before marking it as complete. If tests fail, fix them before proceeding.
- **Verify compilation**: Run `flutter analyze` after every code change to catch issues early.

## Tech Stack

- Flutter 3.41.6 (stable), Dart 3.11
- Firebase (Auth, Firestore, Storage)
- Provider for state management
- get_it for dependency injection
- MVVM architecture with layer-based folder structure
- Flutter SDK path: `C:\flutter\bin` (add to PATH with `export PATH="/c/flutter/bin:$PATH"`)

## Project Structure

```
lib/
  core/           -- DI, base classes, constants, errors, interfaces, logger
  models/         -- Data models
  services/       -- Firebase service implementations
  viewmodels/     -- ChangeNotifier viewmodels extending BaseViewModel
  views/          -- Screen widgets
  components/     -- Reusable UI widgets
  authentication/ -- Auth views and viewmodel
  utils/          -- Helpers (colors)
```

## Conventions

- Models use `fromDocument()` for Firestore reads, `toMap()` for writes
- Nested models (BundleItem, OrderItem) use `fromMap()` / `toMap()`
- ViewModels extend `BaseViewModel` and use `runBusyFuture()` for async work
- Services implement interfaces from `core/interfaces/`
- Use `AppLogger` instead of `print()` for all logging
- Use constants from `core/constants/` instead of hardcoded strings
- Credentials live in `.env`, never hardcoded in source
