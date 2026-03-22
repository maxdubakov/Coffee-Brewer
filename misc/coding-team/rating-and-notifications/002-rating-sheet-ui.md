# Task 002: Rating Sheet UI

## Context
Rating type was changed to Double in Task 001. Now we need the actual rating UI — a sheet that lets users quickly rate a brew with half-star precision, optional taste profile sliders, and notes.

The app follows MVVM. Reusable components go in `Views/Components/`. The app uses `BrewerColors` for theming.

## Objective
Create a `RatingSheet` view that allows rating a brew. This is a sheet presented over other content, taking a `Brew` Core Data object as input.

## What to build

### 1. Half-Star Rating Component (`Views/Components/HalfStarRating.swift`)
- A reusable view that displays 5 stars and accepts tap input
- Supports 0.5 increments (0.5, 1.0, 1.5, 2.0, ... 5.0)
- Each star has two tap zones: left half = .5, right half = whole number
- Uses SF Symbols: `star.fill` (full), `star.leadinghalf.filled` (half), `star` (empty)
- Takes a `@Binding var rating: Double`
- Visual style: use `BrewerColors.caramel` for filled stars (matches existing star color usage in BrewLibraryRow)

### 2. Rating Sheet (`Views/Brews/RatingSheet.swift`)
- Takes an `ObservedObject` or direct `Brew` reference + `NSManagedObjectContext`
- Layout (top to bottom):
  1. **Header**: brew name + coffee name + date (compact, 1-2 lines)
  2. **Star rating**: the HalfStarRating component, prominent/centered
  3. **Taste profile section** (collapsible, collapsed by default):
     - Section header "Taste Profile" with expand/collapse chevron
     - When expanded: 4 labeled sliders (Acidity, Sweetness, Bitterness, Body)
     - Each slider: 0-10 range, Int steps, shows current value
     - When expanded for first time, sliders default to 5 (middle)
     - Values stay at 0 if section never expanded (0 = "not set")
  4. **Notes**: a `TextEditor` or `TextField` for free-text notes (2-3 lines)
  5. **Save button**: saves rating + taste profile + notes to the Brew, sets `isAssessed = true`, dismisses sheet

- The save should write directly to the Brew's managed object context and save.
- After save, dismiss the sheet via `@Environment(\.dismiss)`.

## Non-goals
- Don't wire this into BrewDetailSheet or BrewLibraryRow yet (Task 003)
- Don't handle notifications (Task 004)
- Don't add navigation coordinator changes

## Caveats
- `BrewerColors` is the app's color palette — use it for all colors
- Follow existing component patterns in `Views/Components/` for style consistency
- The sheet should be lightweight — "5 seconds to rate" is the design goal
- Taste profile fields on Brew are `Int16` (acidity, bitterness, body, sweetness). Convert slider Double values to Int16 on save.

## Build command
```
cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -50
```
