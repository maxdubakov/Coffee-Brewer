# Task 002: Coffee Management — Navigation Wiring

## Context

Task 001 created all Coffee UI components (AddCoffee, EditCoffee, CoffeeForm, CoffeeDetailSheet, CoffeeLibraryRow, ViewModels). None are wired into the app's navigation yet. This task connects them.

The app uses a Coordinator pattern: `NavigationCoordinator` manages navigation state, `Main.swift` handles destination routing, `AddChoice.swift` is the "add new item" screen, and `LibraryContainer.swift` manages edit sheets.

Reference files for the Roaster wiring pattern:
- `Coordinators/NavigationCoordinator.swift` — has Roaster/Grinder navigation, edit, delete methods
- `Views/Main.swift` — destination routing via `switch` on `AppDestination`
- `Views/AddChoice.swift` — add item cards
- `Views/Library/LibraryContainer.swift` — edit sheets

## Objective

Wire Coffee into the app's navigation so users can:
- Navigate to AddCoffee from AddChoice (as the **first** / most prominent option)
- Navigate back to home after saving a coffee
- Edit a coffee via sheet from the library
- Delete a coffee with confirmation alert

## Scope

### 1. `Coordinators/NavigationCoordinator.swift`
- Add `case addCoffee` to `AppDestination` enum
- Add `@Published var editingCoffee: Coffee?`
- Add `@Published var showingDeleteCoffeeAlert = false`
- Add `@Published var coffeeToDelete: Coffee?`
- Add `navigateToAddCoffee()` — sets tab to `.add`, appends `.addCoffee` to `addPath`
- Add `handleCoffeeSaved()` — pops to root, switches tab to `.home` (mirror `handleRoasterSaved()`)
- Add `confirmDeleteCoffee(_:)` — sets `coffeeToDelete` and `showingDeleteCoffeeAlert`
- Add `deleteCoffee(in:)` — deletes from context, saves (mirror `deleteRoaster(in:)`)
- Add notification observers for `.coffeeSaved` and `.coffeeUpdated` in `setupNotificationObservers()` (if that method exists) or in `init`

### 2. `Views/Main.swift`
- Add destination case: `case .addCoffee: AddCoffee(context: viewContext)`

### 3. `Views/AddChoice.swift`
- Add a Coffee card as the **first option** (before Roaster and Grinder)
- Use `PrimaryChoiceCard` or `SecondaryChoiceCard` — check what the existing cards use and make Coffee the most prominent
- Navigation: `navigationCoordinator.addPath.append(AppDestination.addCoffee)`

### 4. `Views/Library/LibraryContainer.swift`
- Add `.sheet(item: $navigationCoordinator.editingCoffee)` with `EditCoffee(coffee:, isPresented:)` wrapped in `NavigationStack` + `.environment(\.managedObjectContext, ...)` + `.tint(BrewerColors.cream)`

## Non-goals
- AllLibraryView integration (Task 003)
- Any new UI components (all created in Task 001)

## Constraints
- `AppDestination` must remain `Hashable`. `addCoffee` has no associated values so this is trivial.
- Follow existing Roaster wiring patterns exactly.
- Build must succeed. All 55 tests must pass.
