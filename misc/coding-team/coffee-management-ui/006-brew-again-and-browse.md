# Task 006: "Brew Again" + Browse Past Brews (Phase 4c)

## Context

Phase 4b added the BrewPicker with V60 Default, Orea V4 Default, and Last Brew options. Users also need to clone older brews (not just the most recent). Rather than embedding a list on the picker, we add:
1. A "Browse past brews" link on BrewPicker that switches to the History tab
2. "Brew Again" actions on brew items throughout the app

The `.cloneFromBrew(brew)` path in BrewEditorViewModel already works — we just need to add entry points to it.

## Objective

Let users start a new brew by cloning any past brew, accessible from:
- BrewPicker → "Browse past brews" link → History tab
- History tab → "Brew Again" on any brew
- Library → Brews section → "Brew Again" in context menu
- BrewDetailSheet → "Brew Again" button

## Scope

### 1. `NavigationCoordinator.swift` — Add `startBrewFromClone(brew:)`
New method that:
- Switches to the `.brew` tab
- Pushes the BrewEditor with `.cloneFromBrew(brew)` onto `brewPath`

**Implementation note:** Since BrewEditor uses local `.navigationDestination` (not `AppDestination`), you need to push a value that triggers the brew editor. Check how BrewPicker currently navigates to BrewEditor — it likely uses `NavigationLink` with a value or direct destination. The coordinator method needs to use the same mechanism.

One approach: define a simple `BrewEditorNavigation` Hashable struct/enum that goes on `brewPath`, and use `.navigationDestination(for:)` in the brew tab's NavigationStack. Both BrewPicker's NavigationLinks and the coordinator's `startBrewFromClone` would push this value. This replaces BrewPicker's current inline `NavigationLink { BrewEditor(...) }` with value-based navigation.

### 2. `Views/Brews/BrewPicker.swift` — Add "Browse past brews" link
Below the three picker cards, add a tappable text link:
- Text: "Browse past brews →" or similar
- Style: `BrewerColors.caramel` or `BrewerColors.cream` with subtle styling (not a card, just a text link)
- Action: `navigationCoordinator.selectedTab = .history` (switch to History tab)
- Only show if there are brews (use the same `@FetchRequest` that checks for the last brew)

### 3. `Views/History/History.swift` — Add "Brew Again" to brew items
Read this file to understand how brews are displayed. Add a "Brew Again" action:
- If brews are shown as cards/rows: add a context menu item "Brew Again" or a visible button
- Action: `navigationCoordinator.startBrewFromClone(brew: brew)`
- Use a coffee cup or repeat icon to make it recognizable

### 4. `Views/Library/AllLibraryView.swift` — Add "Brew Again" to brew context menu
The Brews section already has context menus (or should — check). Add a "Brew Again" option:
- In the brew row's context menu, add "Brew Again" alongside any existing options
- Action: `navigationCoordinator.startBrewFromClone(brew: brew)`

### 5. `Views/Brews/BrewDetailSheet.swift` — Add "Brew Again" button
Add a prominent "Brew Again" button to the detail sheet:
- Position: near the top or bottom of the sheet, clearly visible
- Style: a button matching the app's visual language (could be a `StandardButton` or a styled text button)
- Action: dismiss the sheet, then `navigationCoordinator.startBrewFromClone(brew: brew)`
- Note: dismissing the sheet and navigating may need coordination (e.g., dismiss first, then on a slight delay navigate, or use the coordinator to handle both)

### 6. Navigation architecture for programmatic push
The key challenge is that `startBrewFromClone` needs to **programmatically push** a BrewEditor onto the brew tab's NavigationStack. Currently BrewPicker uses inline `NavigationLink { BrewEditor(...) }` which doesn't support programmatic pushing.

**Recommended approach:**
- Define a navigation value type (e.g., `BrewEditorRoute`) that's `Hashable` and carries the `BrewStartingPoint` info (use `NSManagedObjectID` for the brew reference to satisfy Hashable)
- Register `.navigationDestination(for: BrewEditorRoute.self)` in the brew tab's NavigationStack (in Main.swift or BrewPicker)
- BrewPicker pushes by appending to `navigationCoordinator.brewPath`
- `startBrewFromClone` pushes by appending to `navigationCoordinator.brewPath`
- Resolve the `Brew` from `NSManagedObjectID` using the managed object context in the destination handler

## Non-goals
- Save as template (deferred to future)
- Brew grouping by coffee/roaster in History
- Any analysis features
- Changing History tab layout/structure

## Constraints
- Core Data entity classes are auto-generated. LSP errors are false positives.
- Must not break existing navigation flows (History charts, brew detail, etc.)
- `AppDestination` must remain `Hashable` — do NOT put `Brew` objects in it.
- Build: `cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -50`
- Tests: `cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:"Coffee BrewerTests" test 2>&1 | tail -50`

## Acceptance criteria
- BrewPicker shows "Browse past brews →" link that switches to History tab
- History tab brews have "Brew Again" action
- Library brews have "Brew Again" in context menu
- BrewDetailSheet has "Brew Again" button
- All "Brew Again" paths correctly clone the brew and open the editor on the Brew tab
- Existing navigation (History charts, brew detail sheets, etc.) still works
- App builds, all tests pass
