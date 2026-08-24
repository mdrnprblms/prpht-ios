# prpht iOS

SwiftUI port of the prpht betting-app demo (`../prpht/index.html`).

## Build (on a Mac)

Option A — XcodeGen (classic app project):

```bash
brew install xcodegen
cd prpht-ios
xcodegen generate          # produces prpht.xcodeproj
open prpht.xcodeproj       # Cmd+R on an iOS 17+ simulator
```

Option B — open the folder in Xcode 16 directly; `Package.swift` builds the
sources as a package target for quick syntax checking.

## Layout

- `prpht/prphtApp.swift` — entry point
- `prpht/Sources/`
  - `DemoData.swift` — generated from index.html: all 61 fixtures/markets,
    friends' bets, chat threads, sweepstakes. Do not edit by hand.
  - `AppState.swift` — feed builder, betslip, settlement simulation, group bets
  - `Theme.swift` — brand tokens (White Grape #A6BE47, blush/black bases)
  - `BlobBackground.swift` — animated ambient noise wash (Canvas port of the JS blob field)
  - `AvatarAssets.swift` — dp-*.jpg loading with initials fallback
- `prpht/Views/`
  - `RootView.swift` — paged tabs FOR YOU → BETSLIP → FIXTURES → FRIENDS + bottom nav with centre (+)
  - `ForYouView.swift` — vertical snap feed, swipe cards, sport strip, pill bet buttons
  - `BetslipView.swift` — singles with 5p-grid stake sliders, acca block, settlement sim
  - `FixturesFriendsView.swift` — fixtures timeline clusters + friends split page
  - `Sheets.swift` — account sheet, PM history graph (seeded random walk, drag-scrub), chat threads with copyable bet bubbles
  - `GroupBetAndSweeps.swift` — new-group-bet sheet (slides up from bottom) and sweep details
- `prpht/Resources/` — avatars, logo, sport icons copied from the web project
- `project.yml` — XcodeGen spec

## Parity notes

- Page order matches the web app after the 3.2.18 reorder.
- Group bet sheet slides from the bottom (iOS sheets do natively).
- Odds ladder drift, fractional display, win-chance curve (`fair^0.88`, clamped 3%–92%), £1 flat acca stake, 5p stake grid all ported 1:1.
- Demo-only: balance £10, no real money anywhere.
