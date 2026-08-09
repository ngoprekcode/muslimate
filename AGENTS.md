# Muslimate Repository Guidelines

## Project overview

Muslimate is a Flutter Islamic application.

The project currently uses:

-   Flutter 3.41.9 managed through FVM
-   Dart SDK \^3.11.5
-   Provider and ChangeNotifier for state management
-   Material 3
-   SharedPreferences for lightweight local persistence
-   Flutter ARB localization for Indonesian and English
-   A feature-first folder structure

Follow the existing architecture unless a ticket explicitly requires a
larger refactor. Do not introduce a new architecture, state-management
solution, navigation system, or persistence technology as part of an
unrelated feature.

## Repository structure

Important directories:

-   `lib/core/`: application-wide theme, design tokens, and global
    providers.
-   `lib/features/<feature>/`: feature-specific UI, state, data, models,
    and supporting code.
-   `lib/shared/widgets/`: reusable widgets shared across multiple
    features.
-   `lib/shared/models/`: models shared across multiple features.
-   `lib/l10n/`: source ARB localization files.
-   `lib/generated/`: generated assets and localization code. Do not
    edit manually.
-   `assets/icons/`: application icons.
-   `assets/images/`: application images.

Keep new code inside the feature that owns it. Move code to
`lib/shared/` only when it is genuinely reused by multiple features. Do
not create premature abstractions for code that currently belongs to
only one feature.

## Architecture and state management

-   Preserve the existing feature-first architecture.
-   Use Provider and ChangeNotifier for application or feature state.
-   Register application-wide providers in `lib/main.dart`.
-   Keep feature-specific providers and logic inside the owning feature.
-   Keep temporary widget-only state inside the widget when it does not
    require persistence or access from other widgets.
-   Keep business logic, search logic, and persistence logic outside
    large widget build methods.
-   Add `data`, `models`, or `logic` directories only when the feature
    needs them.
-   Do not require repository, domain, or use-case layers for every
    small change.
-   Follow the closest existing feature implementation when adding
    similar code.
-   Do not introduce Bloc, Riverpod, GetX, or another state-management
    package without explicit approval.
-   Do not perform a broad architecture refactor while implementing a
    scoped Jira ticket.

## Navigation

-   Preserve the existing MaterialApp navigation approach.
-   Follow the existing `onGenerateRoute` convention.
-   Preserve the `MainShell` and `IndexedStack` behavior unless the
    ticket explicitly changes application navigation.
-   Use existing route naming and argument-passing conventions.
-   Do not introduce another routing package without explicit approval.
-   Back navigation must not trigger updates on providers or screens
    that are no longer active.

## UI and design system

-   Use the existing theme and design tokens from `lib/core/`.
-   Use `AppTheme`, `AppColors`, `AppSpacing`, `AppRadius`, and
    `AppDurations` where applicable.
-   Access semantic colors with `AppColors.of(context)`.
-   Support both light and dark themes.
-   Prefer typography from `Theme.of(context).textTheme`.
-   Use Plus Jakarta Sans for general interface text.
-   Follow the existing Arabic font or Arabic text component conventions
    for Quran verses and other Arabic content.
-   Reuse widgets from `lib/shared/widgets/` before creating a
    duplicate.
-   Promote a widget to `lib/shared/widgets/` only when it is shared or
    clearly intended to be shared by multiple features.
-   Do not add raw color values when a suitable semantic color token
    exists.
-   Do not duplicate existing card, header, toggle, spacing, radius, or
    navigation patterns.
-   Read `docs/design/DESIGN_GUIDELINES.md` before implementing or
    materially changing UI.
-   When an explicit Claude Design screen or component is provided as
    the reference, use the archived Claude Design HTML as the primary
    visual reference for the active UI scope.
-   Treat the Claude Design HTML as a visual reference only; do not copy
    its web architecture, bundled JavaScript, or CSS implementation
    literally into Flutter.
-   When a requested UI has no dedicated design, infer it conservatively
    from `docs/design/DESIGN_GUIDELINES.md` and the 2--3 closest
    existing Muslimate screens or components.
-   When design context is provided through Figma in the future, match
    the linked frame while preserving established repository
    conventions.
-   Map design-reference values to existing semantic Flutter tokens and
    shared widgets instead of hardcoding raw CSS values.
-   Do not introduce a new visual language for a single Jira ticket.
-   Inspect both light and dark states when explicit variants are
    available; otherwise derive theme behavior from the existing
    semantic Flutter theme.
-   Preserve responsive behavior and avoid hardcoding screen dimensions
    for a single device.
-   Use safe areas where content could overlap system UI.
-   Interactive elements must have an adequate touch target and clear
    visual state.

## Localization

-   New user-facing text must be localized.
-   Add new localization keys to both `lib/l10n/app_en.arb` and
    `lib/l10n/app_id.arb`.
-   Use `AppLocalizations` when displaying localized content.
-   Keep localization keys descriptive and feature-oriented.
-   Do not edit generated localization files manually.
-   Run localization generation after changing ARB source files.
-   Do not combine unrelated localization cleanup with a scoped ticket
    unless requested.
-   Existing hardcoded text may remain unchanged if it is outside the
    active ticket.

## Assets and generated files

-   Add image assets to `assets/images/`.
-   Add icon assets to `assets/icons/`.
-   Register new asset directories or files in `pubspec.yaml` when
    required.
-   Access generated assets through the existing generated asset API
    when available.
-   Do not manually edit files inside `lib/generated/`.
-   Run code generation after changing registered assets.
-   Do not commit temporary design exports, screenshots, build
    artifacts, or generated preview files.

## Persistence

-   Use the existing SharedPreferences approach for small local settings
    and simple MVP data.
-   Keep preference keys as private constants in the owning data source,
    provider, repository, or service.
-   Do not duplicate preference key strings across multiple files.
-   Define one clear source of truth for each persisted feature.
-   Bookmark, last-read, notification preference, and similar features
    must remain available after restarting the application when required
    by the ticket.
-   Handle missing or invalid stored values safely.
-   Keep stored data backward-compatible when changing an existing
    preference format.
-   Do not introduce Hive, Isar, SQLite, or another persistence package
    without explicit approval.
-   Do not silently delete existing user data during a migration.

## Quran-related functionality

-   Treat existing hardcoded Quran data as prototype data, not as the
    preferred implementation for production Quran features.
-   Quran data access should have one clear source of truth.
-   Reuse the same bookmark mechanism for Dashboard, Quran lists, and
    Quran detail screens.
-   Reuse the same Quran models instead of creating separate models for
    each screen.
-   A bookmark must have a stable identifier.
-   Last-read data must identify enough information to reopen the
    correct surah, ayah, and juz position.
-   Search behavior should be case-insensitive where relevant and should
    handle empty queries safely.
-   Search, bookmark, and last-read logic should be testable outside
    large widget build methods.
-   Do not duplicate Quran data or bookmark persistence for separate
    pages.
-   Preserve Arabic text exactly as supplied by the approved data
    source.
-   Do not invent, alter, or approximate Quran verse content.

## Async and provider lifecycle

-   Do not call `notifyListeners()` after a provider has been disposed.
-   Cancel stream subscriptions, timers, controllers, and listeners in
    `dispose()`.
-   Check widget mounted state before using BuildContext after
    asynchronous work when required.
-   Handle loading, success, empty, permission-denied, and error states
    when relevant.
-   Do not silently swallow errors unless the UI intentionally provides
    a safe fallback.
-   Avoid force unwraps and null assertions on values returned by
    asynchronous operations.
-   Prevent duplicate requests when a screen or provider is initialized
    more than once.
-   Do not update UI state after the user has left the relevant screen.

## External actions and permissions

For location, sharing, rating, feedback, help, privacy, notifications,
and social-media actions:

-   Reuse installed packages and existing platform integrations.
-   Handle unavailable applications or unsupported platform actions
    safely.
-   Handle permission granted, denied, and permanently denied states.
-   Provide a useful fallback when an external action cannot be
    completed.
-   Do not request a permission before it is needed.
-   Do not add a production dependency without approval.
-   Do not claim platform behavior is verified unless it was tested on
    the relevant platform.

## Dependencies

-   Reuse installed packages whenever practical.
-   Do not add, remove, or upgrade a production dependency without
    explicit approval.
-   Explain why an additional package is necessary before adding it.
-   Use `fvm flutter pub add` only after receiving approval.
-   Do not run broad dependency upgrades as part of an unrelated ticket.
-   Do not replace an installed package merely because another package
    is more familiar.
-   Keep `pubspec.lock` consistent with approved dependency changes.

## Commands

Use FVM for all Flutter and Dart commands.

Initial setup:

``` sh
fvm install
fvm flutter pub get
```

Generate localization:

``` sh
fvm flutter gen-l10n
```

Generate registered assets and other generated code when required:

``` sh
fvm dart run build_runner build --delete-conflicting-outputs
```

Format changed Dart files:

``` sh
fvm dart format <changed-files>
```

Run static analysis:

``` sh
fvm flutter analyze
```

Run all available tests:

``` sh
fvm flutter test
```

Run a focused test:

``` sh
fvm flutter test <test-file>
```

Do not use a globally installed Flutter SDK when the repository FVM
configuration is available. Do not run destructive code-generation or
cleanup commands unless they are required for the active ticket.

## Testing

The repository may not yet have complete test coverage. New
functionality should still be structured so it can be tested.

-   Add focused unit tests for new business logic when practical.
-   Prioritize tests for persistence, search, bookmarks, last-read
    behavior, and data transformations.
-   Add widget tests for important user interactions and UI states when
    they can be tested reliably.
-   Test both positive and safe failure paths where relevant.
-   Keep location, permission, compass, notification, and
    external-action code behind mockable boundaries when adding tests.
-   Do not create brittle tests based only on incidental widget
    structure.
-   Do not claim a test passed unless the command was actually run.
-   If relevant test infrastructure does not exist, report the
    limitation explicitly.
-   Do not remove or weaken an existing test merely to make a change
    pass.

## Jira implementation workflow

Before changing code:

1.  Read the complete Jira story and acceptance criteria.
2.  Identify the user outcome requested by the story.
3.  Inspect the related feature and its closest existing implementation.
4.  Inspect reusable components and design tokens.
5.  Read `docs/design/DESIGN_GUIDELINES.md` for UI work.
6.  If the ticket names a Claude Design screen/component, inspect that
    reference in the archived HTML.
7.  Inspect a linked Figma frame when one is explicitly provided.
8.  If no dedicated design exists, inspect 2--3 closest existing
    Muslimate screens/components and extrapolate conservatively.
9.  Identify dependencies on earlier Jira stories.
10. Identify ambiguities that would materially change behavior.
11. Keep the planned implementation inside the ticket scope.

When an ambiguity materially affects data structure, user behavior,
persistence, architecture, or dependencies, ask for clarification before
implementing it. Small implementation details that can be safely
inferred from established repository patterns do not require
clarification.

During implementation:

-   Preserve existing behavior outside the active ticket.
-   Do not combine unrelated cleanup with the ticket.
-   Prefer a complete testable user outcome over disconnected UI-only
    changes.
-   Do not leave fake buttons, dead CTAs, or placeholder interactions
    unless the acceptance criteria explicitly permit them.
-   Reuse existing foundations created by earlier tickets.
-   Do not duplicate services, providers, models, preference keys, or
    components.
-   Keep changes reviewable and focused.
-   Follow the explicitly referenced design without overriding
    established repository conventions unnecessarily.
-   For UI that exists in the Claude Design archive, preserve its visual
    intent while implementing it with existing Flutter tokens and
    components.
-   For UI without a dedicated reference, follow
    `docs/design/DESIGN_GUIDELINES.md` and established Muslimate
    patterns rather than inventing a new style.

## Scope control

Changes must remain within the active Jira ticket.

Allowed supporting changes include:

-   Small refactors required to implement the requested behavior safely.
-   Reusing or extracting a component that is directly needed by the
    ticket.
-   Adding focused tests for the changed behavior.
-   Adding localization entries required by the feature.
-   Updating a model or persistence service directly required by the
    feature.

Changes that require separate approval include:

-   Broad architecture refactors.
-   State-management migration.
-   Navigation replacement.
-   Design-system replacement.
-   Production dependency additions or upgrades.
-   Database introduction.
-   Unrelated code cleanup.
-   Large localization migrations.
-   Removing existing user-facing functionality outside the ticket
    scope.

## Definition of done

A change is complete when:

-   The Jira acceptance criteria are satisfied.
-   The complete requested user flow works.
-   The implementation follows the existing feature-first structure.
-   UI uses the existing theme, tokens, and shared components.
-   Light and dark themes remain usable.
-   New user-facing text is localized in Indonesian and English.
-   Persistence survives an application restart when required.
-   Relevant loading, empty, error, and permission states are handled.
-   Async operations do not update inactive or disposed screens.
-   Changed Dart files are formatted.
-   `fvm flutter analyze` passes, or pre-existing failures are clearly
    separated from new failures.
-   Relevant tests pass.
-   No generated file was manually edited.
-   No unapproved production dependency was added.
-   No unrelated functionality was changed.

The final implementation report must include:

-   Implemented behavior.
-   Changed files.
-   Commands that were run.
-   Test and analysis results.
-   Any pre-existing failures.
-   Remaining limitations.
-   Platform behavior that could not be verified.
-   Any manual verification steps still required.

## Git workflow

-   Work on a dedicated branch for each Jira story.
-   Keep one Jira story as the primary scope of a branch.
-   Use the Jira issue key in the branch name when available.
-   Do not rewrite or discard unrelated user changes.
-   Do not commit generated build artifacts.
-   Do not commit secrets, local environment files, or machine-specific
    files.
-   Do not create a commit, push a branch, or open a pull request unless
    explicitly requested.
-   Before committing, inspect the diff and make sure it only contains
    intended changes.

Suggested branch naming:

``` text
feature/MUS-123-short-description
fix/MUS-123-short-description
chore/MUS-123-short-description
```

Suggested commit naming:

``` text
feat(quran): implement surah bookmark
fix(prayer): hide adhan sound configuration
chore(mvp): hide non-MVP features
```

If the team already uses another branch or commit convention, follow the
existing repository convention instead.

## Security and sensitive data

-   Do not commit API keys, credentials, tokens, signing files, or
    secrets.
-   Do not print sensitive configuration values in logs or final
    reports.
-   Do not hardcode secrets in Dart files.
-   Use the project's established environment configuration when one
    exists.
-   Treat location and user preference data as private user data.
-   Store only the minimum user data required by the feature.

## Prohibited changes without explicit approval

-   Changing the state-management solution.
-   Introducing a new application architecture.
-   Adding, removing, or upgrading production dependencies.
-   Replacing the navigation system.
-   Reworking the complete design system.
-   Introducing a new local database.
-   Editing generated files manually.
-   Performing broad refactors outside the active Jira ticket.
-   Removing existing user-facing functionality outside the ticket
    scope.
-   Changing signing, release, CI, or deployment configuration.
-   Committing, pushing, or opening a pull request.
