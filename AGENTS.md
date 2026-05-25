# Agent Instructions — Flutter Dashing Kit

You are a senior Flutter engineer working on a mobility-oriented mobile application built on top of the **Flutter Dashing Kit** boilerplate (by 7span).

## Stack

- **Flutter** 3.13+ / **Dart** SDK `>=3.7.2 <4.0.0`
- **Melos** 7.3.0 — Dart workspace + monorepo orchestrator (`useRootAsPackage: true`)
- **flutter_bloc** — state management
- **auto_route** — Navigator 2.0 typed routing with code generation
- **envied** — typed env vars compiled from `.env.{dev,staging,prod}`
- **slang** — type-safe i18n / localization
- **Firebase** — multi-environment via flavors (`development`, `staging`, `prod`)
- **Atomic Design** in `packages/app_ui` (atoms / molecules / organisms / templates)
- **mason** — code scaffolding (see `bricks/feature`)
- **husky** + `lint_staged` — pre-commit `dart format -l 70` and `dart analyze --fatal-infos --fatal-warnings`
- **flutter_lints** — base lint ruleset (see `analysis_options.yaml`)

## Repository Layout

```
flutter-dashing-kit/
├── apps/
│   └── app_core/                  # Main Flutter app
│       ├── lib/
│       │   ├── main_development.dart    # Entry point — dev flavor
│       │   ├── main_staging.dart        # Entry point — staging flavor
│       │   ├── main_production.dart     # Entry point — prod flavor
│       │   ├── bootstrap.dart           # Shared app bootstrap (DI, error zone)
│       │   ├── app/                     # App-level wiring: routes, config, observers
│       │   ├── core/                    # data / domain / presentation core
│       │   └── modules/                 # Feature modules (auth, home, profile, …)
│       ├── android/                     # Android-specific (gradle, flavors)
│       ├── ios/                         # iOS-specific (xcconfig, Podfile)
│       └── pubspec.yaml
├── packages/
│   ├── api_client/                # HTTP client + interceptors
│   ├── app_notification_service/  # Push notifications wrapper
│   ├── app_subscription/          # In-app purchases / subscriptions
│   ├── app_translations/          # Generated i18n strings (slang)
│   ├── app_ui/                    # Design system (atomic design)
│   └── widgetbook/                # Component catalog
├── bricks/
│   └── feature/                   # Mason brick to scaffold a feature module
├── scripts/                       # Setup scripts (see "Scripts" below)
├── pubspec.yaml                   # Workspace root + melos config
└── analysis_options.yaml
```

## Daily Commands

Run from the repository root unless noted otherwise.

| Command | Purpose |
| --- | --- |
| `melos bs` | Bootstrap the workspace (resolve deps for every package) |
| `melos run analyze` | Run `dart analyze` across all packages |
| `melos run format` | Format with `dart format -l 70` and apply `dart fix` |
| `melos run build-runner` | Regenerate code in `apps/app_core` (auto_route, envied, freezed, json_serializable…) |
| `melos run asset-gen` | Regenerate `packages/app_ui` asset references |
| `melos run locale-gen` | Regenerate slang i18n files in `packages/app_translations` |
| `melos run widgetbook-gen` | Regenerate Widgetbook catalog |
| `melos run build-apk` / `build-bundle` / `build-ipa` | Production builds |
| `melos run go-ios-go` | Reset iOS Pods and reinstall |
| `flutter run -t apps/app_core/lib/main_development.dart --flavor development` | Launch the dev flavor |
| `flutter run -t apps/app_core/lib/main_staging.dart --flavor staging` | Launch the staging flavor |
| `mason get feature && mason make feature` | Scaffold a new feature module |

After editing anything that participates in code generation (routes, envied schemas, freezed models, JSON serializable classes), **run `melos run build-runner`** before committing.

## Scripts

| Script | When to use | Notes |
| --- | --- | --- |
| `scripts/check_environment_configuration.sh` | Verify Flutter / Melos / build_runner are installed and current | Non-interactive. Safe to run unattended. |
| `scripts/init.sh` | First-time boilerplate initialisation (env files, bootstrap, mason init, husky install) | Mostly non-interactive. Safe to run unattended. |
| `scripts/agent_setup.sh` | **Automation-friendly** project customisation: app name, package id, launcher icon | Accepts `--app-name`, `--package`, `--logo`. Prefer this over `project_setup.sh` in scripted environments. |
| `scripts/project_setup.sh` | Interactive customisation for humans | Uses `read` prompts; **cannot run unattended**. Do not invoke from an agent — use `agent_setup.sh` instead. |
| `scripts/firebase_setup.sh` / `firebase_app_distribution.sh` / `remove_firebase.sh` | Firebase configuration helpers | Read each script before running; some require credentials. |
| `scripts/delete_pubspec_lock.sh` | Wipe pubspec.lock files | Only when intentionally resetting locked versions. |

The scripts use a `#!/bin/zsh` shebang. On Linux/CI prefer invoking them explicitly: `sh scripts/...` (POSIX-compatible parts) or `zsh scripts/...` if zsh is installed. `agent_setup.sh` uses `#!/usr/bin/env bash` and works on both Linux and macOS.

## Conventions

### State management (BLoC)

- One BLoC per feature/use-case; keep it presentation-agnostic.
- Events are verbs (`LoadProfileRequested`); states are nouns or adjectives (`ProfileLoading`, `ProfileLoaded`).
- Use `Equatable` (or `freezed`) for events and states.
- Prefer `BlocProvider` scoped to the route/screen over global providers.

### Routing (auto_route)

- Declare routes in `apps/app_core/lib/app/routes/`. After any change, run `melos run build-runner`.
- Use typed route classes (`const FooRoute(id: 'x')`), not string paths.

### Env vars (envied)

- Define typed env schemas; values come from `apps/app_core/.env.{dev,staging,prod}`.
- Never commit `.env.*` files with real secrets. The `init.sh` script seeds them with placeholders.
- After editing an envied schema, run `melos run build-runner`.

### i18n (slang)

- Add/edit translations in `packages/app_translations/lib/i18n/*.i18n.json`.
- Run `melos run locale-gen` to regenerate type-safe accessors.
- Reference strings as `t.feature.key`, never as raw strings in widgets.

### UI / Atomic Design (`packages/app_ui`)

- **atoms/**: indivisible widgets (buttons, icons, typography tokens).
- **molecules/**: small compositions of atoms (form field with label + error).
- **organisms/**: feature-level widgets (cards, list items with actions).
- **templates/**: page-level layout scaffolds.
- New visual primitives go into `app_ui`, not into the app module.

### Code style

- Lines wrap at **70 columns** (`dart format -l 70`).
- `dart analyze` must pass with `--fatal-infos --fatal-warnings` (enforced by `lint_staged`).
- Single quotes preferred (matches `flutter_lints` recommendation).
- Require trailing commas — `dart fix --apply --code=require_trailing_commas` runs in `melos run format`.

### Scaffolding a feature

```sh
mason get feature        # one-time per workspace
mason make feature --name <feature_name>
```

The brick generates the module skeleton under `apps/app_core/lib/modules/<feature_name>`.

### Git workflow

- Branch naming: `feat/<topic>`, `fix/<topic>`, `refactor/<topic>`, `docs/<topic>`, `chore/<topic>`.
- Never commit on `main`.
- Pre-commit hooks (husky + `lint_staged`) run `dart format -l 70` and `dart analyze --fatal-infos --fatal-warnings` on staged Dart files. Do not bypass with `--no-verify`.
- Push the branch to `origin` after each commit; open a PR targeting `main` for review.

## What NOT to do

- Do not edit `scripts/project_setup.sh` to remove its prompts — the upstream (`7span/dashing-kit`) keeps it interactive. For non-interactive needs, use or extend `scripts/agent_setup.sh`.
- Do not change the package identifier or app name by hand-editing `build.gradle.kts`, `AndroidManifest.xml`, or iOS plists. Go through `scripts/agent_setup.sh --package=… --app-name=…`.
- Do not commit generated files outside the ones the original boilerplate already tracks (slang outputs and auto_route outputs are committed; build_runner-generated `*.g.dart` / `*.freezed.dart` follow the boilerplate's convention).
- Do not introduce new state management libraries (Riverpod, GetX, MobX). Stick to BLoC.
- Do not bypass the `analysis_options.yaml` for a specific lint without an inline `// ignore: <rule>` comment justifying it.
- Do not run `flutter clean` followed by `melos bs` as a debugging reflex; investigate first.
- Do not change Flutter SDK constraints in `pubspec.yaml` without checking compatibility across every workspace package.
