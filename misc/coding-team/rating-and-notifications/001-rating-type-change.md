# Task 001: Change rating type from Int16 to Double

## Context
The `rating` field on the `Brew` Core Data entity is currently `Int16`. To support half-star ratings (e.g., 3.5), it needs to be `Double`. No data migration is needed — the app has never been deployed to production.

## Objective
Change `rating` from `Int16` to `Double` everywhere it's referenced, so the model supports 0.5-increment star ratings.

## Scope

### 1. Core Data model
- **File:** `Coffee Brewer/Models/CoreData/CoffeeModel.xcdatamodeld/.../contents`
- Change the `rating` attribute on the `Brew` entity from `attributeType="Integer 16"` to `attributeType="Double"` (keep `usesScalarValueType="YES"`)

### 2. BrewFormData
- **File:** `Coffee Brewer/Models/BrewFormData.swift`
- Change `var rating: Int16 = 0` → `var rating: Double = 0.0`
- Update both initializers (`init(cloning:)` and `init(from:)`) — the cloning init should keep rating at 0.0 (already does), the `from:` init should read `brew.rating` as Double

### 3. Display code
- **File:** `Coffee Brewer/Views/Brews/BrewDetailSheet.swift` — the star display section (around lines 31-39) references `brew.rating`. Update any `Int16` comparisons/casts to work with `Double`.
- **File:** `Coffee Brewer/Views/Library/BrewLibraryRow.swift` — the star display (around lines 48-73). Update `brew.rating > 0` and star rendering to handle Double.

### 4. Export/Import
- **File:** `Coffee Brewer/Models/CoreData/CoreDataExportable.swift` — find where `rating` is exported/imported. Update any `as? Int16` casts to `as? Double`.

### 5. Analytics/Charts
- Search for any references to `brew.rating` in chart/analytics code and update if needed.

## Non-goals
- Don't change taste profile fields (acidity, bitterness, body, sweetness) — they stay Int16
- Don't build the rating UI yet — that's Task 002
- Don't update star rendering to show half-stars yet — that's Task 003

## Build command
```
cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -50
```
