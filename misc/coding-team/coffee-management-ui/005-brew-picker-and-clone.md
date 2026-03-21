# Task 005: Quick Brew — Picker Screen + Clone Logic (Phase 4b)

## Context

Phase 4a (Task 004) built the Brew Editor screen with inline stage editing, compact params, coffee picker, and Save & Brew. Currently the Brew tab shows the editor directly with hardcoded V60 defaults.

Phase 4b adds the **Starting Point Picker** — a screen shown first when the user opens the Brew tab, where they choose what to base their next brew on. This is Option A from the design discussion: two separate screens with push navigation.

Existing code:
- `BrewEditorViewModel` has `formData: BrewFormData` with all stage/param state
- `BrewFormData` already has `init(brewMethod:)` for template defaults and `init(cloning:)` for cloning from a previous brew
- `PourTemplate+Extensions` has `createStages(for:waterAmount:context:)` and `seedBuiltInTemplates(in:)`
- `PourTemplate` entities exist in Core Data with built-in V60 and Orea V4 templates
- The Brew tab currently shows `BrewEditor` directly in Main.swift

## Objective

Add a Starting Point Picker screen as the Brew tab's root view. The picker offers three quick options (V60 Default, Orea Default, Last Brew) and pushes to the Brew Editor with pre-filled data based on the selection.

## Scope

### 1. `Views/Brews/BrewPicker.swift` (NEW)

The Brew tab's new root view. Shows quick-pick options.

**Layout:**
- Title: "New Brew" or "Start Brewing" with subtitle
- Three prominent cards/buttons:
  1. **V60 Default** — loads V60 template defaults
  2. **Orea V4 Default** — loads Orea V4 template defaults
  3. **Last Brew: {coffee name}** — clones the most recent brew (show coffee name + date). If no brews exist, show this option as disabled/hidden.
- Each card taps to push `BrewEditor` via NavigationStack

**Data needs:**
- `@FetchRequest` for the most recent Brew (sorted by date descending, fetchLimit 1)
- Access to PourTemplate entities for the built-in templates (or just use `BrewFormData(brewMethod:)` which already has defaults)

**Style:** Match the app's visual language — `BrewerColors`, card backgrounds, `SVGIcon` where appropriate. These should feel like prominent action cards, not a plain list.

### 2. `BrewEditorViewModel.swift` — Add initialization modes

The ViewModel currently hardcodes V60 defaults. It needs to accept different starting configurations:

**Add an enum or init parameter:**
```swift
enum BrewStartingPoint {
    case template(BrewMethod)     // V60 or Orea V4 defaults
    case cloneFromBrew(Brew)      // Clone all params + stages from a previous brew
}
```

- `case .template(method)`: Use `BrewFormData(brewMethod: method)` with default stages for that method (Fast bloom + Slow pour for V60; Fast bloom + Slow pour + Fast pour for Orea V4). Coffee picker should be empty (user must select).
- `case .cloneFromBrew(brew)`: Use `BrewFormData(cloning: brew)` to copy all params + stages. Auto-fill `selectedCoffee = brew.coffee`. The coffee picker should show the cloned coffee pre-selected but allow changing.

**The ViewModel init should take `startingPoint: BrewStartingPoint`** instead of always using V60 defaults.

### 3. `Views/Brews/BrewEditor.swift` — Accept starting point

Update BrewEditor to accept the starting point and pass it to the ViewModel:
- The view should take a `startingPoint: BrewStartingPoint` parameter
- Create the ViewModel with that starting point

**Important consideration:** BrewEditor is currently created as `@StateObject` in the view. Since the starting point varies per navigation, the ViewModel needs to be created with the right starting point each time. Use `@StateObject private var viewModel: BrewEditorViewModel` with init that passes the starting point.

### 4. `Views/Main.swift` — Update Brew tab root

Change the Brew tab's root view from `BrewEditor` to `BrewPicker`. The BrewPicker will push to BrewEditor via the NavigationStack.

### 5. `NavigationCoordinator.swift` — Add navigation destination

Add `case brewEditor(BrewStartingPoint)` to `AppDestination` — or handle navigation within the Brew tab's NavigationStack using `.navigationDestination`. 

**Simpler approach:** Since BrewPicker and BrewEditor are in the same tab's NavigationStack, you can use a local `NavigationLink` or `.navigationDestination(for:)` within the Brew tab without adding to `AppDestination`. Pick whichever is simpler.

### 6. Post-save behavior

After saving a brew, `handleBrewSaved()` currently pops to root and switches to home. This should still work — the brew tab pops back to the BrewPicker, and the user is sent to home. When they return to the Brew tab, they see the picker fresh.

The `resetForNewBrew()` in the ViewModel is no longer needed since a new ViewModel is created each time the user navigates from the picker. You can keep it as a safety net or remove it.

## Non-goals
- "Browse experiments" list (Phase 4c)
- "Save as template" (Phase 4c)
- Custom templates beyond V60/Orea V4 built-ins
- Drag to reorder stages

## Constraints
- Core Data entity classes are auto-generated. LSP errors are false positives.
- `BrewFormData(cloning:)` already exists — use it for the clone logic.
- `BrewFormData(brewMethod:)` already exists — use it for template defaults. Check what default stages it creates; if it doesn't create stages, you'll need to add them (V60: Fast 20% + Slow 80%; Orea V4: Fast 20% + Slow 40% + Fast 40%, applied to a default water amount like 270ml).
- `AppDestination` must remain `Hashable`. If `BrewStartingPoint` contains a `Brew` (NSManagedObject), use `NSManagedObjectID` for hashability, or use a different navigation approach.
- Build: `cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -50`
- Tests: `cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" -only-testing:"Coffee BrewerTests" test 2>&1 | tail -50`

## Acceptance criteria
- Brew tab shows the Picker screen (not the editor directly)
- Three options visible: V60 Default, Orea V4 Default, Last Brew
- Tapping V60 Default pushes editor with V60 default stages and params
- Tapping Orea V4 Default pushes editor with Orea V4 default stages and params
- Tapping Last Brew pushes editor with cloned data from most recent brew (params + stages + coffee)
- Last Brew option shows the coffee name and is disabled/hidden when no brews exist
- Editor works correctly with all three starting points
- Save & Brew still creates Brew entity and navigates away correctly
- App builds, all existing tests pass
