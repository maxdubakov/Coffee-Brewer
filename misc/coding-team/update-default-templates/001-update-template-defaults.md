# Task 001: Update default brew templates

## Context
The app has two built-in brew templates (V60 and Orea V4) defined in multiple places. Their names, parameters, and pour stages need updating.

## Objective
Rename templates and update all default values to match the user's actual brew recipes.

## Changes needed across 3 files

### 1. `Coffee Brewer/Models/CoreData/PourTemplate+Extensions.swift`
- Rename "V60 Default" → "V60"
- Rename "Orea V4 Default" → "Orea V4"
- **V60 stages** (percentage-based, total = 306ml):
  - Stage 0: type `"fast"`, waterPercentage `26.14` (80/306)
  - Stage 1: type `"slow"`, waterPercentage `39.22` (120/306)
  - Stage 2: type `"slow"`, waterPercentage `34.64` (106/306)
- **Orea V4 stages** (percentage-based, total = 306ml):
  - Stage 0: type `"fast"`, waterPercentage `26.14` (80/306)
  - Stage 1: type `"slow"`, waterPercentage `22.88` (70/306)
  - Stage 2: type `"fast"`, waterPercentage `26.14` (80/306)
  - Stage 3: type `"slow"`, waterPercentage `24.84` (76/306)

### 2. `Coffee Brewer/ViewModels/BrewEditorViewModel.swift`
In `makeFormData(for:)` and `defaultStages(for:)`:
- **Both methods**: grindSize `31.5`, grams `18`, ratio `17.0`, temperature `96.0`, waterAmount `306`
- **V60 stages**: fast 80ml + slow 120ml + slow 106ml
- **Orea V4 stages**: fast 80ml + slow 70ml + fast 80ml + slow 76ml

### 3. `Coffee Brewer/Models/BrewMethod.swift`
- Both V60 and Orea V4: `defaultGrams` = `18`, `defaultRatio` = `17.0`, `defaultTemperature` = `96.0`

## Non-goals
- No UI changes
- No type changes (grindSize is already Double)
- No data migration

## Build command
```
cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -50
```
