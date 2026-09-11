# Ballast

**Steady, not streaky.**
A calm, private, offline habit tracker that replaces the all-or-nothing streak chain with one honest number: how consistent you've actually been over the last 30 days.

---

## Why this exists

This came out of a wider market-research pass on 10 breakout indie iOS apps (see `iOS_App_Market_Research_Report.docx` in the Output folder). Two findings kept repeating across almost every habit/productivity app studied: **subscription fatigue** is the single most common reason people one-star an app they otherwise like, and **streak anxiety** — the guilt and all-or-nothing thinking a broken chain triggers — is a named, rising, and startlingly under-served problem. Grit Method, Habitica, Streaks, and Way of Life all still frame consistency as a chain that resets to zero the moment you miss a day.

Ballast is the app for the people that chain has already burned: everyone who's deleted a habit tracker specifically because one missed day made the whole month feel wasted.

### The wedge

- **No streaks** — a rolling 30-day consistency percentage instead of a chain that snaps back to zero.
- **No subscription, ever** — a single one-time purchase (see Monetisation).
- **No account, no cloud** — everything stays on the device.
- **A weekly reflection, not daily guilt** — one gentle, optional check-in at the end of the week, aimed at whichever habit needs it most.

### Positioning

Grit Method is the closest thing to a direct inspiration — its "no penalty for missed days" philosophy is right, but it still renders progress as a streak-shaped grid and hard-codes four fixed categories. Habitica and Streaks are further from this: gamified RPG mechanics on one side, flexible-but-emotionally-flat chains on the other. Nothing in the category leads with the number itself being incapable of hitting zero.

- **Headline:** *"Miss a day. The number dips. That's all."*
- **Moat / proof:** the whole app is built around a single non-punitive calculation (`ConsistencyCalculator`) instead of a streak counter — there is no code path anywhere that can render a "streak broken" state, because there is no streak.
- **Target buyer:** someone who has already tried and quit 2+ habit trackers, specifically over streak-guilt or subscription paywalls — a narrower, more qualified audience than "everyone who wants to build habits," and one primed to recognise the pitch immediately.

---

## Features (v1)

- **Habit list** — create, edit, archive habits with a name, an emoji, and an optional daily reminder.
- **Today view** — a simple daily checklist; tapping a habit logs (or un-logs) today, nothing more.
- **Consistency ring** — a rolling 30-day percentage per habit, colour-banded but never red.
- **90-day history grid** — a plain dot grid of what was completed. No "broken streak" highlighting, ever.
- **Weekly reflection** — an optional, gentle end-of-week prompt aimed at the least consistent habit, saved privately on-device.
- **Gentle local reminders** — one optional daily nudge per habit, non-urgent copy, no streak-loss framing.
- **CSV export** — every check-in, out as plain text, no account required.
- **Light/dark/system appearance.**

## Screens

| Screen | Purpose |
|---|---|
| **Today** | Every active habit, today's checkbox, and its consistency ring. The whole app in one screen. |
| **Habit detail** | The big consistency ring, the 90-day dot grid, and a reminder of the "no streaks" philosophy. |
| **Add / edit habit** | Name, emoji, optional daily reminder time. |
| **Weekly check-in** | A short, optional reflection sheet aimed at whichever habit needs it most that week. |
| **Settings** | Appearance, CSV export, and a plain statement of what the app does and doesn't collect. |

## Tech stack

- **SwiftUI** — the entire UI, iOS 17+.
- **SwiftData** — on-device persistence for habits, check-ins, and reflections. No backend.
- **UserNotifications** — local, on-device reminder scheduling only.
- **StoreKit 2** — wired for a future optional Pro tier via `ProStatus`; dormant in v1 (`isUnlocked = true`).

No analytics, no ad networks, no tracking SDKs, no third-party dependencies.

## Offline behaviour

**The app makes zero network requests in v1.** Every feature works in airplane mode, permanently — there is no "online" mode to fall back from.

## Data model

- `Habit` — name, emoji, creation date, optional reminder time, archive flag. Has no `currentStreak` field by design.
- `CheckIn` — one row per completed day per habit. Absence of a row is neutral, never a recorded "miss."
- `Reflection` — a private weekly note, optionally tied to a habit name.

`ConsistencyCalculator` is the one piece of business logic the whole app hinges on: a pure, dependency-free function (see `BallastTests`) that turns a list of check-in dates into a 0–1 rolling consistency score, capped at a 30-day window.

## Monetisation

A single one-time purchase (price TBD — no in-app purchase code is live yet). `ProStatus.isUnlocked` is hard-coded to `true` in v1; if a future Pro tier is added (e.g. unlimited habits, extra themes), it should only ever be read through that object, never by inspecting StoreKit transactions in a view.

## Roadmap (not v1 — see "Out of scope" in `CLAUDE.md`)

- Home Screen widget showing today's rings.
- Optional end-to-end-encrypted iCloud sync (still no account).
- Multiple reminder times per habit.
- A Rive-animated consistency ring for the celebration/empty states.
- Apple Watch companion for one-tap logging.

## Compliance / privacy

- No analytics, no ad SDKs, no tracking of any kind.
- Local notifications only — no push infrastructure, no server.
- App Store privacy label target: **Data Not Collected.**

## Research basis

Ballast is Grit Method Idea #1 ("Anchor," renamed) from the accompanying research report — chosen because it directly answers the two clearest, most repeated findings across all 10 apps studied (subscription fatigue and streak anxiety), requires no external API or backend, and is realistically scoped for a solo build on a twice-weekly cadence.
