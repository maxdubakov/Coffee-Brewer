# Task 001: Hide Home Tab, Make Brew Default

## Context

The app has 4 tabs: Home, Brew, Add, History. The user wants to hide Home and make Brew the default landing tab. The Home tab shows `LibraryContainer` — that content is NOT being deleted, just the tab entry point is removed. The Library is still accessible via other paths if needed later.

## Objective

Remove the Home tab from the tab bar. App opens to Brew tab by default.

## Scope

### `NavigationCoordinator.swift`
- Change `_selectedTab` default from `.home` to `.brew`
- `handleBrewSaved()`: currently does `popToRoot(for: .brew)` then `_selectedTab = .home` — change to `_selectedTab = .brew` (stay on brew tab after saving)
- `handleCoffeeSaved()`, `handleRoasterSaved()`, `handleGrinderSaved()`: currently navigate to `.home` — change to `.brew` (or `.add` — use your judgment, but `.brew` is the new "home")
- `navigateToHome()`: either remove or redirect to `.brew`
- `navigateToLibraryBrews()`: this navigates to Home tab and posts a notification. Since Home tab is gone, remove this method or make it a no-op for now. Check if anyone calls it — if so, remove those call sites too.
- Remove `homePath` if nothing else references it. If `LibraryContainer` is still referenced elsewhere (e.g., via sheets), keep it available but remove the tab's NavigationStack.

### `Main.swift`
- Remove the Home tab block entirely (the NavigationStack + .tabItem + .tag for `.home`)
- Remove `.home` from the `Tab` enum
- Keep the remaining 3 tabs: Brew, Add, History
- Update `TabView(selection:)` — it should still work with the binding

### Other files that reference `Tab.home` or `navigateToHome()`
- Search for usages and update/remove. Likely: `BrewPicker` has a "Browse past brews" link that calls `navigateToHistory()` (that's fine). Check for any `navigateToHome()` or `navigateToLibraryBrews()` calls.

## Non-goals
- Don't delete `LibraryContainer` or any library views — just remove the tab entry point
- Don't change tab icons or labels yet (Task 002)
- Don't touch keyboard handling (Task 003)

## Constraints
- Must build successfully after changes
- All existing tests must pass
- Verify in simulator (iPhone 16 Pro Max) that app opens to Brew tab and Home tab is gone

## Acceptance criteria
- App launches to Brew tab
- Only 3 tabs visible: Brew, Add, History
- Saving a brew returns to Brew tab (not a missing Home tab)
- Saving a coffee/roaster/grinder navigates somewhere sensible (not Home)
- Build + tests pass
