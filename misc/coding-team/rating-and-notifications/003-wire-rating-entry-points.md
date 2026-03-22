# Task 003: Wire rating sheet into entry points

## Context
`RatingSheet` and `HalfStarRating` were created in Task 002. Now they need to be wired into the app so users can actually rate brews.

## Objective
Add three ways to open the RatingSheet, and update star displays to support half-stars.

## Changes needed

### 1. BrewDetailSheet — Add "Rate" button
- **File:** `Coffee Brewer/Views/Brews/BrewDetailSheet.swift`
- Add a "Rate This Brew" button (or "Update Rating" if already assessed)
- Tapping it presents `RatingSheet` as a sheet, passing the brew
- Place it alongside or near the existing "Brew Again" button
- Add `@State private var showRatingSheet = false` and `.sheet(isPresented:)` modifier

### 2. BrewLibraryRow — Make "Assess" tappable
- **File:** `Coffee Brewer/Views/Library/BrewLibraryRow.swift`
- The existing "Assess" label (shown when `!brew.isAssessed`) needs to trigger a rating sheet
- Since BrewLibraryRow is used inside lists in multiple places (History, BrewsLibraryView), the cleanest approach is to add a callback: `var onRate: (() -> Void)? = nil`
- Make the "Assess" label tappable via `.onTapGesture { onRate?() }`
- In the parent views that use BrewLibraryRow (History.swift, BrewsLibraryView.swift), pass an `onRate` closure that sets state to present the RatingSheet for that brew
- Add the necessary `@State` and `.sheet` in each parent

### 3. Update star displays for half-star support
- **File:** `Coffee Brewer/Views/Brews/BrewDetailSheet.swift` — the existing star display (around lines 31-39) currently renders whole stars via `ForEach(1...5)` with `star.fill`/`star`. Update to use `HalfStarRating` component (read-only mode, or just render half-star icons correctly based on the Double rating).
- **File:** `Coffee Brewer/Views/Library/BrewLibraryRow.swift` — same: update star rendering to handle .5 values. Can use a small helper or inline logic: for each star position, check if rating >= position (full), >= position-0.5 (half), else empty.

## Non-goals
- Don't add notification deep-link (Task 004)
- Don't change RatingSheet itself

## Caveats
- BrewLibraryRow is a row component used in multiple list contexts — keep the `onRate` callback optional with nil default so existing usages don't break
- The HalfStarRating component from Task 002 takes a `@Binding`. For display-only contexts, you can either use `.constant(brew.rating)` binding or create a simpler display-only star view. Using `.constant()` with `allowsHitTesting(false)` is simplest.

## Build command
```
cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -50
```
