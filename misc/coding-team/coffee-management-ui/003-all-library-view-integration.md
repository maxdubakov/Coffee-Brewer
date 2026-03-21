# Task 003: Coffee Management — AllLibraryView Integration

## Context

Tasks 001 and 002 created all Coffee UI components and wired them into navigation. The last piece: `AllLibraryView.swift` still uses inline code for coffee rows instead of the new `CoffeeLibraryRow` component, and lacks context menus and detail sheet support for coffees.

Reference: how Roasters and Grinders are handled in the same file — they use dedicated row components (`RoasterLibraryRow`, `GrinderLibraryRow`), have context menus (Edit/Delete), detail sheet bindings, and delete alert bindings.

## Objective

Replace the inline coffee row code in `AllLibraryView` with `CoffeeLibraryRow`, and add full context menu + detail sheet + delete alert support — matching the Roaster/Grinder patterns in the same file.

## Scope

All changes are in `Views/Library/AllLibraryView.swift`:

### 1. Add state for coffee detail sheet
- Add `@State private var selectedCoffeeForDetail: Coffee?`

### 2. Replace inline coffee rows with `CoffeeLibraryRow`
The coffees section currently has inline `HStack` code for each coffee row. Replace it with:
```swift
CoffeeLibraryRow(
    coffee: coffee,
    isEditMode: isEditMode,
    isSelected: selectedCoffees.contains(coffee.objectID),
    onTap: { /* handle tap — toggle selection in edit mode, show detail in normal mode */ }
)
```
Follow the exact same pattern as the Roaster rows section.

### 3. Add context menu for coffee rows
Mirror the Roaster context menu pattern:
- "Edit" → `navigationCoordinator.editingCoffee = coffee`
- "Delete" → `navigationCoordinator.confirmDeleteCoffee(coffee)`

### 4. Add detail sheet binding
```swift
.sheet(item: $selectedCoffeeForDetail) { coffee in
    CoffeeDetailSheet(coffee: coffee)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}
```

### 5. Add delete alert binding
Mirror the Roaster delete alert:
```swift
.alert("Delete Coffee", isPresented: $navigationCoordinator.showingDeleteCoffeeAlert) {
    Button("Delete", role: .destructive) {
        navigationCoordinator.deleteCoffee(in: viewContext)
    }
    Button("Cancel", role: .cancel) {
        navigationCoordinator.cancelDeleteCoffee()
    }
} message: {
    Text("Are you sure? This will also delete all brews associated with this coffee.")
}
```

### 6. Normal-mode tap behavior
When not in edit mode, tapping a coffee row should set `selectedCoffeeForDetail = coffee` to show the detail sheet (same as Roaster tap behavior).

## Non-goals
- Changing any other sections (Roasters, Grinders, Brews)
- Adding new components (everything needed already exists)

## Constraints
- Follow the existing Roaster/Grinder patterns in the same file exactly.
- Build must succeed. All 55 tests must pass.
