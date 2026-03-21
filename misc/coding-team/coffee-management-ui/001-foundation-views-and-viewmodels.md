# Task 001: Coffee Management — Foundation Views & ViewModels

## Context

Phase 3 of the app refactoring. The Coffee Core Data entity already exists with extensions (`Coffee+Extensions.swift`), and `CoffeeFormData.swift` is already written. We need the full UI layer: form component, add/edit screens with ViewModels, library row, and detail sheet.

The app follows MVVM + Coordinator. All new UI must follow the exact same patterns as the existing Roaster flow. Key reference files:
- `Views/Roasters/AddRoaster.swift` — add screen pattern
- `ViewModels/AddRoasterViewModel.swift` — VM pattern
- `Views/Roasters/RoasterDetailSheet.swift` — detail sheet pattern
- `Views/Library/RoasterLibraryRow.swift` — library row pattern
- `Views/Components/Form/RoasterForm.swift` — reusable form pattern
- `ViewModels/EditRoasterViewModel.swift` — edit VM pattern
- `Views/Roasters/EditRoaster.swift` — edit screen pattern

## Objective

Create 7 new files that provide the complete Coffee management UI (not yet wired into navigation — that's Task 002).

## Scope

### 1. `Views/Components/Form/CoffeeForm.swift`
Reusable form component, modeled after `RoasterForm.swift`.

Fields:
- **Name** — `FormKeyboardInputField`, required
- **Roaster** — picker/dropdown from existing Roasters (use `@FetchRequest` for Roaster entities). Display "None" when unset.
- **Country** — picker/dropdown from existing Countries (origin country). Display "None" when unset.
- **Process** — picker with predefined options: `Washed`, `Natural`, `Honey`, `Anaerobic`, `Other`. When "Other" is selected, show a free-text `FormKeyboardInputField` below it for custom input.
- **Notes** — `FormRichTextField`

Bindings: `@Binding var formData: CoffeeFormData`, `@Binding var focusedField: FocusedField?`

Use the same section layout pattern as RoasterForm (SVGIcon + SecondaryHeader + FormGroup + Dividers).

### 2. `ViewModels/AddCoffeeViewModel.swift`
Modeled after `AddRoasterViewModel.swift`.
- `@MainActor class AddCoffeeViewModel: ObservableObject`
- Published: `formData: CoffeeFormData`, `focusedField`, `showValidationAlert`, `validationMessage`, `isSaving`
- `validateAndSave() -> Bool` — name is required. Creates Coffee entity, sets all fields from formData, saves context, posts `.coffeeSaved` notification.
- `resetToDefaults()`, `hasUnsavedChanges() -> Bool`
- Add `Notification.Name.coffeeSaved` and `.coffeeUpdated` extensions.

### 3. `ViewModels/EditCoffeeViewModel.swift`
Modeled after `EditRoasterViewModel.swift`.
- Takes existing `Coffee` entity
- Pre-populates `CoffeeFormData` from entity
- `validateAndSave() -> Bool` — updates existing entity, saves, posts `.coffeeUpdated`

### 4. `Views/Coffees/AddCoffee.swift`
Modeled after `AddRoaster.swift`.
- `FixedBottomLayout` with `CoffeeForm` content and `StandardButton` save action
- `PageTitleH2("Add Coffee", subtitle: ...)` 
- Init takes `context: NSManagedObjectContext`

### 5. `Views/Coffees/EditCoffee.swift`
Modeled after `EditRoaster.swift`.
- Sheet presentation, takes `Coffee` entity + `isPresented` binding
- Same layout pattern with `CoffeeForm`

### 6. `Views/Library/CoffeeLibraryRow.swift`
Modeled after `RoasterLibraryRow.swift`.

Signature:
```swift
struct CoffeeLibraryRow: View {
    let coffee: Coffee
    let isEditMode: Bool
    let isSelected: Bool
    let onTap: () -> Void
}
```

Show: coffee name (primary), roaster name + process + brew count (subtitle). Use coffee bean icon or similar from existing SVGIcon set. Same layout/spacing/colors as RoasterLibraryRow.

### 7. `Views/Coffees/CoffeeDetailSheet.swift`
Modeled after `RoasterDetailSheet.swift`.
- Takes `let coffee: Coffee`
- Card showing: name, roaster, country/flag, process
- Sub-list: coffee's brews (sorted by date, most recent first), capped at `maxHeight: 160`
- Same visual treatment (gradient card, colors, spacing)

## Non-goals
- Navigation wiring (Task 002)
- AllLibraryView integration (Task 003)
- Tests
- "Quick add roaster" from within Coffee form

## Constraints
- Core Data entity classes are auto-generated at build time. LSP errors about `Coffee`, `Roaster`, `Country` types are false positives — ignore them.
- Main app target auto-discovers files — no pbxproj edits needed for new app source files.
- `CoffeeFormData.swift` already exists at `Models/CoffeeFormData.swift` — do NOT recreate it. The process field is a `String` there; the picker should write the selected option string (or custom text for "Other") into `formData.process`.
- Must build successfully: `cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -50`
- All 55 existing tests must still pass.

## Process picker implementation detail
Define a `CoffeeProcess` enum (or similar) with cases: `washed`, `natural`, `honey`, `anaerobic`, `other`. Each has a `displayName`. The picker binds to a local `@State` that maps to/from `formData.process`. When "Other" is selected and user types custom text, that custom text goes into `formData.process`. When editing an existing coffee whose process doesn't match any predefined option, select "Other" and show the existing text in the free-text field.
