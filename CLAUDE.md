# CLAUDE.md — Ballast

Operating instructions for Claude Code working in this repo. Read this first, every session. `README.md` is the product overview and the research rationale. This file is *how we build*.

---

## What we're building

A native iOS habit tracker that replaces the streak chain with a single honest number: a rolling 30-day consistency percentage per habit. Offline, local-only, no account, no subscription.

**Positioning (keep all copy consistent with this):** the calm alternative for people a streak app has already burned. Lead on **"the number dips, it doesn't break"** — never on gamification, never on guilt. A missed day dents the percentage; it never resets anything to zero. There is no code path anywhere that renders a "streak broken" state, because there is no streak field, streak counter, or streak copy anywhere in the app.

---

## Golden rules (do not break these)

1. **No streak language, ever.** No streak counts, no "chain," no fire emoji, no "don't break the streak" copy, no flame icons. Grep for "streak" before every commit — it should only ever appear in this file and the research report reference.
2. **Offline-first. Zero network calls in v1.** The habit list, Today view, consistency ring, history grid, weekly reflection, reminders, and CSV export must all work permanently in airplane mode — there is no "online" mode to fall back from.
3. **No backend. Ever, in v1.** Persistence is on-device SwiftData only. No server, no account, no auth, no sync.
4. **No analytics, no tracking, no ad SDKs.** The App Store privacy label must be able to say **Data Not Collected**. Don't add Firebase, Sentry, Mixpanel, or similar without an explicit decision recorded here.
5. **Features check `ProStatus`, never StoreKit directly.** All gating goes through the entitlement object so the business model stays a late, reversible decision. In v1 `isUnlocked = true`.
6. **Respect Reduce Motion everywhere.** Ring fills, check-in springs, and any celebratory motion are gated on `@Environment(\.accessibilityReduceMotion)`.
7. **Accessibility is not optional (WCAG AA).** Body/caption text ≥4.5:1; the consistency ring is never coloured red — colour bands run low→high but never signal failure; colour is never the sole signal (always pair with the percentage as text); VoiceOver labels on every habit row, ring, and grid cell; visible focus; 44×44pt tap targets; Dynamic Type.
8. **No guilt-based copy anywhere.** Empty states, reminder notification text, and the weekly reflection prompt are all worded gently — no "you're falling behind," no red exclamation states, no punitive framing of a missed day.
9. **No secrets in the repo.** There is nothing to key in v1 (no external API), so this stays true by construction — keep it that way; any future networked feature needs an explicit decision recorded here first.

---

## Stack & platform

- **Swift** + **SwiftUI**, iOS 17+ deployment target.
- **SwiftData** — persistence (`@Model`, `ModelContainer`).
- **UserNotifications** — local reminder scheduling only.
- **StoreKit 2** — present but dormant in v1 (wired only through `ProStatus`).
- No third-party packages in v1. Nothing added without a decision recorded here.

---

## Architecture

```
Ballast/
├── App/                        # @main entry, ModelContainer, root nav
│   └── BallastApp.swift
├── Models/                     # SwiftData @Model types
│   ├── Habit.swift              # name, emoji, createdAt, reminderTime, isArchived — no streak field
│   ├── CheckIn.swift             # one row per completed day per habit
│   └── Reflection.swift          # private weekly note, optional habit name
├── Services/
│   ├── ConsistencyCalculator.swift  # pure, dependency-free 30-day consistency math (see BallastTests)
│   ├── ReminderScheduler.swift      # UserNotifications wrapper
│   ├── ProStatus.swift              # feature-gating entitlement (StoreKit 2 ready)
│   └── CSVExporter.swift            # plain-text check-in export, no account required
├── DesignSystem/
│   └── Theme.swift               # BallastTheme (ring colour bands, spacing, corner radius), AppearanceOption
├── Views/
│   ├── Today/                    # TodayView, HabitRowView — the whole app in one screen
│   ├── HabitDetail/               # HabitDetailView, HeatmapGridView (90-day dot grid)
│   ├── AddEditHabit/               # AddEditHabitView
│   ├── Reflection/                 # WeeklyReflectionView
│   └── Settings/                    # SettingsView (appearance, CSV export, privacy statement)
└── Resources/
    └── Assets.xcassets            # AccentColor, AppIcon
```

- **One view/component per file**, named after the type.
- **Separate visual state from business state.** SwiftData models hold business state; view-local `@State`/animation values are UI-only.
- **`ConsistencyCalculator` is the one source of truth for the percentage.** Views never compute consistency inline — they call the calculator so there is exactly one place the math can be wrong (or tested).
- **`ReminderScheduler` owns all notification logic.** Views never call `UNUserNotificationCenter` directly.
- **`ProStatus` is the only gate.** `if proStatus.isUnlocked { … }` — never inspect transactions in a view.

---

## Conventions

- SwiftUI-first: prefer **implicit animations** (`.animation`, `withAnimation`) for the ring fill and check-in tap, gated on Reduce Motion.
- Prefer value types and `@Observable` for services. Inject via environment.
- Every view has a `#Preview` seeded with a couple of demo habits at different consistency levels so screens are inspectable without data entry.
- Dates: store `Date` on `CheckIn`; compute consistency on read via `ConsistencyCalculator`. Never persist a running percentage or a streak count.
- Copy: sentence case, active voice, gentle tone (see Golden rule 8). British spelling ("colour", "organise").
- Accessibility: two-tier signalling (colour band + text percentage), colour never the sole signal, VoiceOver labels on every habit row and the ring (e.g. "Reading, 73 percent consistent over the last 30 days"), visible focus, 44×44pt targets, Dynamic Type.

---

## Build order

Build in this sequence — each step must run before the next.

1. Project scaffold (`project.yml`, XcodeGen) + `DesignSystem/Theme.swift`.
2. SwiftData models (`Habit`, `CheckIn`, `Reflection`) + `ModelContainer`.
3. `ConsistencyCalculator` + its unit tests (`BallastTests`) — get the math right and tested before any UI depends on it.
4. `TodayView` + `HabitRowView` — the core daily loop: see habits, tap to check in, see the ring move.
5. `ConsistencyRing` component — the shared ring view used on Today and Habit Detail.
6. `HabitDetailView` + `HeatmapGridView` — the 90-day dot history.
7. `AddEditHabitView` — create/edit/archive a habit, with an optional reminder time.
8. `ReminderScheduler` — schedule on save, cancel/replace on edit, request permission on first reminder set.
9. `WeeklyReflectionView` — the weekend banner and the reflection sheet, aimed at the least consistent habit.
10. `SettingsView` — appearance switch, `CSVExporter`, privacy statement.
11. `ProStatus` entitlement (leave `isUnlocked = true`).
12. Accessibility pass — contrast, colour-not-sole-signal, VoiceOver, focus rings, Dynamic Type, Reduce Motion.

---

## Commands

Xcode is the primary environment. From the terminal:

```bash
# regenerate the project after adding files or changing build settings
xcodegen generate

# open in Xcode
open Ballast.xcodeproj

# build (adjust scheme/simulator as needed)
xcodebuild -scheme Ballast -destination 'platform=iOS Simulator,name=iPhone 17' build

# run tests
xcodebuild -scheme Ballast -destination 'platform=iOS Simulator,name=iPhone 17' test
```

- **`project.yml` is the source of truth for the Xcode project**, not `Ballast.xcodeproj`. The `.xcodeproj` is generated by [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`) and is git-ignored — never edit it by hand, and run `xcodegen generate` after adding a file or a target.
- After changing the data model, verify a clean install still launches (SwiftData migrations are easy to break early — prefer additive schema changes).
- Don't commit `*.xcuserstate`, `DerivedData/`, or other build artifacts.
- This repo was scaffolded and its Swift source written by Claude running in a sandboxed environment with no Xcode/Swift toolchain available, so nothing in it has been compiled or run yet. Treat the first `xcodegen generate` + build as step zero of this session — fix whatever the compiler finds before adding anything new.

---

## Definition of done (v1.0)

- Today view, habit detail (ring + 90-day grid), add/edit habit, weekly reflection, settings — all working offline.
- Reminders fire at their configured time (verified in simulator with a near-future time).
- `ConsistencyCalculator` unit tests pass, including the 30-day window cap and the young-habit (shorter window) case.
- **Accessibility:** body/caption ≥4.5:1, colour never the sole signal, VoiceOver labels on habit rows + ring, visible focus, Dynamic Type and Reduce Motion all pass a manual check.
- `ProStatus` in place, `isUnlocked = true`, no StoreKit calls in views.
- No analytics, no backend, no streak language anywhere (grep clean).
- Privacy policy URL ready and App Store privacy label set to Data Not Collected (see `README.md` → Compliance).

---

## Out of scope for v1 (do not build yet)

Home-screen widget, end-to-end-encrypted iCloud sync, Apple Watch companion, multiple reminder times per habit, a Rive-animated ring, a live StoreKit paywall. These are roadmap items (`README.md` → Roadmap) — leave clean seams for them, don't implement.
