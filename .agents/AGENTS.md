# Flutter Monorepo - AI Agent Operating Guidelines

This file serves as the main entrypoint and rule index for AI coding assistants working across Flutter monorepo applications.

---

## Workspace Structure

The project follows a modular monorepo structure managed with **Melos**:

-   **App Modules**: `apps/[app_name]/lib/modules/[feature]/` (or `lib/modules/[feature]/`)
-   **UI Package**: `packages/app_ui/` (Assets, Design System, Common Widgets)
-   **Translations Package**: `packages/app_translations/` (Slang i18n JSON & generated translations)
-   **API Client Package**: `packages/api_client/` (HTTP Client, Interceptors, Base API setup)

---

## Core Rules Index

Always adhere to the specific rules in `.agents/rules/`:

1.  **Architecture & Feature Structure**: [.agents/rules/structure.md](file://.agents/rules/structure.md)
    -   4-layer structure (`bloc/`, `model/`, `repository/`, `screen/`) under `lib/modules/[feature_name]/`.
    -   Repositories return `TaskEither<Failure, T>` using functional error handling.
2.  **BLoC & State Management**: [.agents/rules/bloc.md](file://.agents/rules/bloc.md)
    -   Sealed class events, private constructor states with named constructors + `copyWith`.
3.  **Atomic Design & UI Components**: [.agents/rules/atomic-design-rule.md](file://.agents/rules/atomic-design-rule.md)
    -   ALWAYS use `app_ui` components (`AppText`, `AppButton`, `VSpace`, `HSpace`, `AppScaffold`).
    -   NEVER use raw `SizedBox` for spacing or raw Material buttons.
4.  **Translations & Localization**: [.agents/rules/atomic-design-rule.md](file://.agents/rules/atomic-design-rule.md)
    -   ALWAYS use `context.t.[key]`. NEVER hardcode user-visible strings.
    -   Run `melos run locale-gen` after editing `en.i18n.json`.
5.  **Asset Management**: [.agents/rules/assets-rules.md](file://.agents/rules/assets-rules.md)
    -   Place assets in `packages/app_ui/assets/`.
    -   ALWAYS use `Assets.[category].[name].[method]()`. NEVER use raw string paths.
    -   Run `melos run asset-gen` after adding assets.
6.  **Navigation & Routing**: [.agents/rules/auto-route.md](file://.agents/rules/auto-route.md)
    -   Screens annotated with `@RoutePage()`. Implement `AutoRouteWrapper` for state management setup.
    -   Run `melos run build-runner` after updating routes.
7.  **Flutter & Dart Best Practices**: [.agents/rules/flutter-dart.md](file://.agents/rules/flutter-dart.md)
8.  **Colors & Typography**: [.agents/rules/color.md](file://.agents/rules/color.md)
9.  **Figma to Flutter UI Conversion**: [.agents/rules/figma-to-app-ui.md](file://.agents/rules/figma-to-app-ui.md)

---

## Code Generation Commands

Run these commands using `run_command` whenever relevant files change:

Change Type

Command

Description

**Translations**

`melos run locale-gen`

Generates slang translation classes after editing `en.i18n.json`

**Assets**

`melos run asset-gen`

Generates `Assets` class after adding images/icons in `app_ui`

**Routes / Code Gen**

`melos run build-runner`

Runs `build_runner` code generation for AutoRoute, models, BLoC

**Analysis**

`flutter analyze`

Checks for lint warnings, type errors, or syntax issues

---

## Available Skills & Workflows

-   `/grill-with-docs` — Run the official iterative design interview and record the shared glossary/decisions. Install it locally with `bash scripts/install-grill-with-docs.sh`.
-   **Automatic transcript routing** — When a teammate supplies a client-call transcript for project understanding, delegate the complete task to the project-understanding subagent automatically. The teammate must not need to invoke `/grill-with-docs` separately. The delegated subagent owns official-skill bootstrap, transcript-based grilling, question persistence, answer reconciliation, and final documentation. Relay its questions into the current conversation and send the teammate’s answers back to that same subagent.
-   `/refine` — Formulate complete specs from raw feature prompts before coding
-   `/new-feature` — Implement a new feature using BLoC + TaskEither repository architecture
-   `/change-flow` — Modify existing screen flow, layout, navigation, or interaction logic
-   `/fix-bug` — Diagnose root cause and apply minimal fixes with verification