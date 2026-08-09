# Muslimate Design Guidelines

## Purpose

This document defines the visual language and UI implementation
principles for Muslimate.

It is derived from the archived Claude Design HTML and is intended to
serve as:

1.  a compact visual reference for implementation agents;
2.  a fallback design specification when a Jira feature has no dedicated
    design;
3.  a bridge between archived design references and the Flutter design
    system.

This document is **not** a replacement for the Flutter design tokens
already implemented in `lib/core/`. When a matching semantic token or
shared widget already exists in Flutter, reuse it instead of hardcoding
a value from this document.

## Design source priority

When implementing UI, use this priority:

1.  **Jira story and acceptance criteria** --- source of truth for
    required behavior and scope.
2.  **Explicit Claude Design screen/component reference** --- primary
    visual reference when the requested UI exists in the archived HTML.
3.  **Existing Flutter implementation** --- source of truth for
    architecture, reusable widgets, semantic tokens, responsive
    behavior, and established product conventions.
4.  **This design guideline** --- visual-language reference and fallback
    for UI that has no dedicated design.
5.  **Design inference** --- allowed only when the sources above do not
    define a detail; extrapolate conservatively from the closest
    existing Muslimate patterns.

Do not translate HTML/CSS literally into Flutter when an equivalent
Flutter token, theme value, or reusable component already exists.

------------------------------------------------------------------------

## Visual identity

Muslimate uses a calm, warm, devotional visual language rather than a
generic utility-app aesthetic.

The archived design establishes three prominent visual ideas:

-   warm neutral backgrounds;
-   deep navy/blue text and structural contrast;
-   restrained gold accents for Islamic/decorative emphasis.

The UI should feel:

-   calm;
-   focused;
-   respectful;
-   warm;
-   spacious;
-   modern without feeling sterile;
-   decorative only where it reinforces hierarchy or Islamic identity.

Avoid introducing highly saturated colors, aggressive gradients,
excessive shadows, or unrelated visual styles for individual features.

------------------------------------------------------------------------

## Typography

### Interface typography

Use **Plus Jakarta Sans** for general interface text.

The archived Claude Design includes multiple weights of Plus Jakarta
Sans. Flutter implementation should prefer the existing
`Theme.of(context).textTheme` hierarchy rather than recreating CSS font
declarations per widget.

General hierarchy:

-   Screen titles: strong weight and clear visual priority.
-   Section titles: semibold/bold, smaller than the screen title.
-   Body: regular/medium with comfortable line height.
-   Labels and metadata: smaller and visually secondary.
-   Buttons/CTAs: medium/semibold with concise wording.

Avoid arbitrary font sizes when an existing Material/TextTheme style
already expresses the intended hierarchy.

### Arabic typography

Use **Amiri** or the existing approved Arabic font/component convention
for Quran verses and Arabic religious content.

Arabic content should:

-   use RTL direction;
-   have generous line height;
-   remain visually distinct from translations and metadata;
-   preserve the exact approved Arabic text;
-   never be approximated or modified to fit layout constraints.

The archived design uses a substantially more generous Arabic line
height than normal interface text. Preserve that sense of breathing room
in Flutter.

### Typography implementation rule

Prefer:

``` dart
Theme.of(context).textTheme
```

and existing Arabic text components.

Do not create one-off `TextStyle` values solely to match a CSS
declaration when an existing semantic style is sufficiently close.

------------------------------------------------------------------------

## Color language

### Verified archive colors

The archived Claude Design explicitly establishes these colors:

  -----------------------------------------------------------------------
  Role                    Reference value         Intent
  ----------------------- ----------------------- -----------------------
  Warm canvas/background  `#EDE7DA`               Calm warm neutral
                                                  foundation

  Deep navy               `#0F2A44`               Primary text / strong
                                                  structural contrast

  Gold accent             `#C9A961`               Decorative or premium
                                                  Islamic accent

  Design-canvas outer     `#1F2A3A`               Archive/canvas
  background                                      presentation; not
                                                  automatically an app
                                                  token
  -----------------------------------------------------------------------

These values are **reference values**, not permission to hardcode them
throughout Flutter.

### Semantic color behavior

Implementation should map the design intent to existing semantic colors
such as:

-   app background;
-   surface/card;
-   primary text;
-   secondary/muted text;
-   primary/action;
-   accent;
-   divider/border;
-   success/warning/error where needed.

Use `AppColors.of(context)` and existing theme tokens.

If the archived HTML contains a color that has no equivalent semantic
token:

1.  determine whether the color is genuinely reusable;
2.  prefer adding or extending a semantic token rather than scattering
    raw values;
3.  do not modify the broader design system as part of a scoped Jira
    ticket without approval.

### Dark theme

The Claude HTML is a visual reference, but Flutter must continue to
support the project's light and dark themes.

Do not force light-design reference colors into dark mode.

When no dark design is explicitly available, derive dark presentation
from existing Muslimate semantic theme tokens while preserving:

-   hierarchy;
-   contrast;
-   component identity;
-   accent intent;
-   readable Quran text.

------------------------------------------------------------------------

## Spacing and layout

Muslimate should use consistent spacing rather than per-screen arbitrary
gaps.

Use `AppSpacing` wherever possible.

### Layout principles

-   Keep primary screen content aligned to a consistent horizontal
    inset.
-   Separate major sections more strongly than items inside a section.
-   Keep card internal padding comfortable and consistent.
-   Preserve whitespace around Quran/Arabic content.
-   Avoid edge-to-edge dense content unless the existing feature
    intentionally uses it.
-   Prefer natural responsive constraints over fixed screen dimensions.
-   Use `SafeArea` where system UI could overlap content.

### When exact HTML spacing exists

Treat HTML spacing as a visual target, not a required literal pixel
value.

Map it to the closest existing `AppSpacing` token unless the difference
materially changes the design.

------------------------------------------------------------------------

## Shape and radius

The design language favors softened containers and controls.

Use `AppRadius` and existing shared component shapes.

Rules:

-   Cards should share an established radius family.
-   Buttons, search fields, chips, and containers should not each invent
    unrelated radii.
-   Prefer subtle borders/surface separation over heavy outlines.
-   Avoid excessive pill shapes unless the component is semantically a
    chip, badge, segmented control, or compact action.

If a Claude Design component exists, match its perceived shape while
still using the closest existing radius token.

------------------------------------------------------------------------

## Surfaces, borders, and elevation

Muslimate should generally feel layered through surface contrast and
spacing rather than heavy elevation.

Prefer:

-   warm/neutral surfaces;
-   subtle borders;
-   restrained shadows;
-   clear content grouping.

Avoid:

-   large dark drop shadows;
-   glassmorphism unless explicitly present in the referenced design;
-   decorative elevation on every card;
-   nesting multiple visually heavy cards.

------------------------------------------------------------------------

## Iconography

Use the project's existing icon assets or established Material icon
conventions first.

Icons should:

-   support comprehension rather than decoration alone;
-   use consistent visual weight;
-   align with surrounding text and touch targets;
-   inherit semantic colors where practical.

Do not introduce a new icon library for a single Jira ticket without
approval.

Islamic decorative motifs may use the gold-accent language when
appropriate, but should remain secondary to content.

------------------------------------------------------------------------

## Core component language

### Cards

Cards are used to group related information and actions.

Typical characteristics:

-   clear surface separation;
-   consistent radius;
-   comfortable padding;
-   strong title/primary-content hierarchy;
-   secondary metadata with lower emphasis;
-   optional trailing action such as bookmark or chevron.

Do not create a new card style when an existing shared card can be
extended.

### Buttons and CTAs

Primary actions should be visually obvious but not compete with every
other element.

Guidelines:

-   one dominant action per local context where possible;
-   concise labels;
-   clear enabled/disabled/pressed states;
-   adequate touch targets;
-   secondary actions should have lower visual emphasis.

### Search

Search should follow existing Quran/list patterns where available.

Expected behavior:

-   obvious search affordance;
-   safe empty-query behavior;
-   clear focus state;
-   predictable clear/reset interaction;
-   no visual redesign between screens without reason.

### Tabs / segmented navigation

Use tabs to switch between closely related datasets or views, such as
Surah and Juz.

Keep:

-   active state unmistakable;
-   inactive state quieter;
-   spacing and typography consistent;
-   interaction aligned with existing navigation patterns.

### Bookmark actions

Bookmark icons/actions should be visually consistent across Dashboard
and Quran experiences.

The same state should use the same visual treatment wherever possible.

### Empty, loading, and error states

When no dedicated design exists:

-   reuse the closest existing state pattern;
-   keep copy concise;
-   provide an actionable CTA only when the user can meaningfully
    resolve the state;
-   do not invent elaborate illustrations unless an approved asset
    exists.

------------------------------------------------------------------------

## Quran and religious-content presentation

Quran content deserves stronger readability constraints than ordinary
app content.

### Arabic verse

-   Preserve approved Arabic text exactly.
-   Use the approved Arabic font/component.
-   Use RTL direction.
-   Provide generous line height.
-   Avoid truncating verse text in contexts where truncation could
    create ambiguity.
-   If a preview must be limited, ensure the UI clearly communicates
    that it is a preview.

### Translation and metadata

Visually separate:

1.  Arabic verse;
2.  translation;
3.  Surah/Ayah/Juz metadata;
4.  actions such as bookmark or continue reading.

Do not let metadata compete visually with the Arabic content.

### Religious accuracy

Visual implementation must never alter religious content to solve a
layout problem.

------------------------------------------------------------------------

## Navigation

Preserve the established Muslimate navigation model.

For new screens:

-   use existing app-bar/header conventions;
-   preserve back-navigation behavior;
-   keep bottom-navigation behavior consistent with `MainShell`;
-   do not create parallel navigation patterns because the archived HTML
    uses a different interaction.

Visual references describe appearance; repository navigation remains
authoritative for implementation.

------------------------------------------------------------------------

## Motion and interaction

The archived design includes subtle animation concepts such as pulse,
fade-up, and slow rotation.

Motion should remain restrained.

Use motion only when it:

-   communicates state;
-   supports orientation;
-   provides feedback;
-   reinforces a meaningful devotional/time-based element.

Prefer `AppDurations`.

Do not add animation merely because the HTML contains a CSS keyframe. A
CSS animation is reference material, not an implementation requirement
unless the Jira/design intent requires it.

------------------------------------------------------------------------

## Screen implementation workflow

When asked to implement a screen that exists in the Claude Design
archive:

1.  Read the Jira story and acceptance criteria.
2.  Locate the named screen/component in the archived Claude Design
    HTML.
3.  Identify the visual hierarchy, layout, component treatment,
    typography, and states relevant to the ticket.
4.  Inspect the closest existing Flutter screen.
5.  Inspect `AppColors`, `AppSpacing`, `AppRadius`, typography, and
    shared widgets.
6.  Map the design to existing semantic tokens and components.
7.  Implement behavior from Jira and visual intent from the reference.
8.  Preserve unrelated existing behavior.
9.  Verify responsive layout and light/dark theme.
10. Run relevant analysis/tests and visually inspect the rendered result
    when possible.

### Important

Do **not** rebuild the entire screen solely because the HTML version
differs.

The Jira ticket defines scope.

------------------------------------------------------------------------

## Designing a feature with no existing reference

When a Jira feature has no matching Claude Design screen/component:

1.  inspect 2--3 closest existing Muslimate screens/components;
2.  read this guideline;
3.  reuse existing Flutter components and tokens;
4.  define the information hierarchy before styling;
5.  extrapolate conservatively from established patterns;
6.  avoid introducing a new visual language;
7.  keep the result visually compatible with screens that do have Claude
    Design references.

The goal is not to imitate Claude's implementation technique. The goal
is to preserve Muslimate's visual identity.

------------------------------------------------------------------------

## HTML reference rules

The archived Claude Design HTML is a **design archive**, not application
source code.

Use it for:

-   screen composition;
-   component appearance;
-   hierarchy;
-   color intent;
-   typography intent;
-   spacing rhythm;
-   shape;
-   decorative treatment;
-   interaction cues.

Do not use it as authority for:

-   Flutter architecture;
-   state management;
-   navigation implementation;
-   persistence;
-   data models;
-   localization architecture;
-   dependency choices;
-   production Quran data;
-   platform behavior.

Never copy bundled JavaScript or web-only implementation into Flutter
merely to reproduce the design.

------------------------------------------------------------------------

## Design conflict resolution

If sources disagree:

### Jira vs design

Jira wins for behavior and scope.

### Claude Design vs Flutter tokens

Preserve the Claude Design's visual intent, but implement it through
existing Flutter semantic tokens/components whenever possible.

### Claude Design vs existing implemented screen

Do not silently redesign unrelated existing UI.

For the active Jira scope, use the explicitly requested design
reference. Preserve unaffected areas unless the ticket requests broader
alignment.

### Design guideline vs explicit screen reference

The explicit screen/component reference wins.

This guideline is primarily a shared visual-language and fallback
document.

------------------------------------------------------------------------

## Agent checklist

Before implementing UI, confirm:

-   [ ] I read the complete Jira story and acceptance criteria.
-   [ ] I know whether an explicit Claude Design screen/component is
    referenced.
-   [ ] I inspected the closest existing Flutter implementation.
-   [ ] I checked existing shared widgets before creating new ones.
-   [ ] I mapped colors to semantic Flutter tokens.
-   [ ] I mapped spacing/radius to existing tokens where practical.
-   [ ] I used Plus Jakarta Sans through the existing theme hierarchy.
-   [ ] I used the approved Arabic typography convention for Arabic
    content.
-   [ ] I preserved light and dark theme behavior.
-   [ ] I did not introduce a new visual language for one ticket.
-   [ ] I handled relevant loading/empty/error/permission states.
-   [ ] I visually inspected the result when possible.

------------------------------------------------------------------------

## Maintenance

Update this document when:

-   a new recurring visual pattern is intentionally introduced;
-   the Flutter design system changes;
-   a newer approved design reference supersedes the Claude Design
    archive;
-   a previously inferred rule becomes explicitly defined.

Do not update this guideline merely to justify a one-off implementation.
