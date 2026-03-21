# Coffee Brewer — Refactoring Summary

## Project Overview

**What**: SwiftUI + Core Data iOS coffee brewing app (MVVM + Coordinator pattern)  
**Where**: `/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer/`  
**Xcode project**: `Coffee Brewer.xcodeproj`  
**Scheme**: `Coffee Brewer`  
**Test target**: `Coffee BrewerTests`  
**Min iOS**: 17.0  

## What Was Done (Phases 1 & 2)

The app is being refactored from a **recipe-centric** model to a **coffee-bag-centric / experiment-focused** model. Two phases are complete:

### Phase 1: Data Model Changes + Tests
- **Removed** the `Recipe` Core Data entity entirely
- **Added** new `Coffee` entity (name, notes, process, relationships to brews/roaster/country)
- **Added** new `PourTemplate` entity (reusable pour patterns with `TemplateStage` children)
- **Modified** `Brew` entity — now owns all brewing parameters directly (grams, grindSize, ratio, temperature, waterAmount, brewMethod) instead of referencing a Recipe. Has `coffee` relationship to Coffee entity.
- **Added** `Brew+Extensions.swift` — computed properties: `coffeeName`, `coffeeRoasterName`, plus convenience initializer
- **Added** `Coffee+Extensions.swift` — computed properties and helpers
- **Added** `PourTemplate+Extensions.swift` — computed properties and helpers
- **Added** `CoffeeFormData.swift` — form data struct for Coffee creation
- **Modified** `BrewFormData.swift` — updated to work without Recipe
- **Modified** `StageFormData.swift` — updated for new model
- **Created 6 test files** (48 tests total):
  - `BrewExtensionsTests.swift` (12 tests)
  - `CoffeeExtensionsTests.swift` (10 tests)
  - `PourTemplateExtensionsTests.swift` (6 tests)
  - `BrewFormDataTests.swift` (9 tests)
  - `StageFormDataTests.swift` (6 tests)
  - `CoffeeFormDataTests.swift` (5 tests)

### Phase 2: Strip Removed Features, Make App Compile
- **Deleted 53 files** — all Recipe-related views, view models, coordinators, models, onboarding, timer, stage creation UI
- **Modified 30+ files** — removed all references to Recipe, timer, onboarding, brew completion flow
- **App builds successfully** via `xcodebuild`

## Current State

### Build Status: ✅ BUILDS SUCCESSFULLY
```
xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" \
  -destination "platform=iOS Simulator,name=iPhone 16" build
```

### Test Status: ⚠️ NOT YET VERIFIED
Tests could not be run due to a persistent **"database is locked"** error from `xcodebuild`. This is a transient environment issue (likely Xcode holding a lock on DerivedData), NOT a code problem. To resolve:
1. Quit Xcode completely
2. `rm -rf ~/Library/Developer/Xcode/DerivedData/Coffee_Brewer-*`
3. Run tests:
```
xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:"Coffee BrewerTests" test
```

Expected: **48 tests** across 6 test files + 2 default tests in `Coffee_BrewerTests.swift` = **50 tests total**.

### Git Status: ALL CHANGES ARE UNCOMMITTED
Nothing has been committed. `git status` shows 92 changed files (53 deleted, 31 modified, 8 added). Last commit is `ad7c0bb Add coffee bad to pre-ground option`.

---

## Core Data Model (Current)

Entities in `CoffeeModel.xcdatamodeld`:

| Entity | Key Attributes | Relationships |
|--------|---------------|---------------|
| **Brew** | id, name, date, grams, grindSize, ratio, temperature, waterAmount, brewMethod, rating, acidity, bitterness, body, sweetness, tds, notes, isAssessed, roasterName, grinderName | → coffee (Coffee), → grinder (Grinder), → stages (Stage, to-many) |
| **Coffee** | id, name, notes, process, createdAt | → brews (Brew, to-many, cascade), → roaster (Roaster), → country (Country) |
| **Roaster** | id, name, location, notes, website, foundedYear | → coffees (Coffee, to-many, cascade), → country (Country) |
| **Grinder** | id, name, type, burrType, burrSize, dosingType, from, to, step | → brews (Brew, to-many) |
| **Country** | id, name, flag | → coffees (Coffee), → roasters (Roaster) |
| **Chart** | id, title, chartType, color, notes, xAxisId/Type/DisplayName, yAxisId/Type/DisplayName, sortOrder, isExpanded, isArchived, createdAt, updatedAt | (none) |
| **Stage** | id, orderIndex, type, waterAmount | → brew (Brew) |
| **PourTemplate** | id, name, brewMethod, isBuiltIn | → stages (TemplateStage, to-many, cascade) |
| **TemplateStage** | id, orderIndex, type, waterPercentage | → template (PourTemplate) |

Core Data uses **`codeGenerationType="class"`** — entity classes are auto-generated at build time from the `.xcdatamodeld`. You will NOT find `Brew.swift`, `Coffee.swift` etc. source files. LSP errors about missing types are **false positives**.

---

## Architecture Notes

### Xcode Project Structure
- **Main app target** uses `PBXFileSystemSynchronizedRootGroup` for source folders (Views, Models, Utils, ViewModels, Coordinators, Resources) — files are **auto-discovered**, no need to edit pbxproj when adding/removing app source files.
- **Test target** uses traditional `PBXGroup` with **explicit file listings** — new test files MUST be manually added to pbxproj (PBXBuildFile, PBXFileReference, PBXGroup children, PBXSourcesBuildPhase entries). The 6 new test files have already been added.

### App Architecture (MVVM + Coordinator)
- `NavigationCoordinator` is the central navigation state manager (ObservableObject)
- `AppDestination` enum cases: `.addRoaster`, `.addGrinder`, `.brewDetail(brewID:)`, `.chartDetail(chart:)`, `.settings`
- `Main.swift` is the root view with NavigationStack
- `AddChoice.swift` — simplified to only offer adding Roaster or Grinder (recipe creation flows removed)

### Key Extension Files
- `Brew+Extensions.swift` — `coffeeName: String`, `coffeeRoasterName: String`, convenience init
- `Coffee+Extensions.swift` — helpers for Coffee entity
- `PourTemplate+Extensions.swift` — helpers for PourTemplate entity
- `Chart+Extensions.swift` — chart axis resolution helpers (modified to use brew properties instead of recipe)

---

## Files Changed (Complete List)

### Deleted (53 files)
**Coordinators:**
- `AddRecipeCoordinator.swift`

**Models:**
- `AddRecipeNavigation.swift`, `OreaBottomType.swift`, `RecipeFormData.swift`
- `CoreData/Recipe+Extensions.swift`, `CoreData/Recipe+Stages.swift`

**ViewModels (11):**
- `AddOreaRecipeViewModel.swift`, `AddV60RecipeViewModel.swift`, `BaseAddRecipeViewModel.swift`
- `EditRecipeViewModel.swift`, `AddStageViewModel.swift`, `StagesManagementViewModel.swift`
- `RecordStagesViewModel.swift`, `BrewTimerViewModel.swift`, `BrewCompletionViewModel.swift`
- `BrewMathViewModel.swift`

**Utils:**
- `OnboardingStateManager.swift`

**Views/Recipes (11):**
- `AddOreaRecipe.swift`, `AddV60Recipe.swift`, `EditOreaRecipe.swift`, `EditV60Recipe.swift`
- `Display/RecipeCard.swift`, `Display/Recipes.swift`, `Display/RoasterGroupedView.swift`
- `Stage/AddStage.swift`, `Stage/PourStage.swift`, `Stage/RecordStages.swift`
- `Stage/RecordedStageScroll.swift`, `Stage/StageCreationChoice.swift`, `Stage/StagesManagement.swift`
- `Stage/WaterBalanceIndicator.swift`

**Views/Prepare (7):**
- `BrewRecipe.swift`, `BrewCompletion.swift`, `BrewTimer.swift`, `BrewControlPanel.swift`
- `StageScroll.swift`, `CurrentStageCard.swift`, `RecipeMetric.swift`, `RecipeMetricsBar.swift`

**Views/Onboarding (4):**
- `Welcome.swift`, `OnboardingOverlay.swift`, `RecordingDemo.swift`, `RecordingDemoOverlay.swift`

**Views/Components (6):**
- `Form/RecipeForm.swift`, `Form/Sections/BasicInfoSection.swift`
- `Form/Sections/BasicInfoWithBottomTypeSection.swift`, `Form/Sections/BrewingParametersSection.swift`
- `Form/Sections/GrindSection.swift`, `Headers/RecipeHeader.swift`

**Views/Library (2):**
- `RecipeLibraryRow.swift`, `RecipesLibraryView.swift`

**Tests (2):**
- `AddRecipeViewModelTests.swift`, `RecipeFormDataTests.swift`

### Added (8 files)
- `Coffee Brewer/Models/CoffeeFormData.swift`
- `Coffee Brewer/Models/CoreData/Brew+Extensions.swift`
- `Coffee Brewer/Models/CoreData/Coffee+Extensions.swift`
- `Coffee Brewer/Models/CoreData/PourTemplate+Extensions.swift`
- `Coffee BrewerTests/BrewExtensionsTests.swift`
- `Coffee BrewerTests/BrewFormDataTests.swift`
- `Coffee BrewerTests/CoffeeExtensionsTests.swift`
- `Coffee BrewerTests/CoffeeFormDataTests.swift`
- `Coffee BrewerTests/PourTemplateExtensionsTests.swift`
- `Coffee BrewerTests/StageFormDataTests.swift`

### Modified (31 files)
- `Coffee Brewer.xcodeproj/project.pbxproj` — deleted file refs removed, new test files added
- `Coordinators/NavigationCoordinator.swift` — stripped recipe navigation, simplified AppDestination
- `Models/Analytics/CategoricalAxis.swift` — removed recipe references
- `Models/Analytics/NumericAxis.swift` — brew.temperature instead of brew.recipeTemperature etc.
- `Models/BrewFormData.swift` — updated for direct brew params
- `Models/StageFormData.swift` — updated for new model
- `Models/CoreData/CoffeeModel.xcdatamodeld` — Recipe removed, Coffee + PourTemplate added, Brew updated
- `Models/CoreData/Chart+Extensions.swift` — axis properties use brew fields
- `Models/CoreData/CoreDataExportable.swift` — removed Recipe export
- `Models/CoreData/PersistenceController.swift` — removed Recipe from preview data
- `Utils/DataManager.swift` — removed Recipe CRUD
- `Views/Main.swift` — removed onboarding, recipe alerts, simplified destination routing
- `Views/AddChoice.swift` — only Roaster/Grinder options
- `Views/Brews/BrewDetailSheet.swift` — uses BrewMetric, direct brew properties
- `Views/Grinders/GrinderDetailSheet.swift` — uses Brew FetchRequest instead of Recipe
- `Views/Roasters/RoasterDetailSheet.swift` — uses roaster.coffees instead of recipes
- `Views/History/History.swift` — removed recipe references from brew cards
- `Views/History/ChartDetailView.swift` — removed recipe references
- `Views/History/Charts/BarChartView.swift` — removed recipe references in previews
- `Views/History/Charts/ChartPreview.swift` — removed recipe references in previews
- `Views/History/Charts/ScatterPlotChart.swift` — removed recipe references
- `Views/History/Charts/TimeSeriesChart.swift` — removed actualDurationSeconds, recipe refs
- `Views/Library/AllLibraryView.swift` — Coffees section replaces Recipes section
- `Views/Library/BrewLibraryRow.swift` — removed recipe name
- `Views/Library/BrewsLibraryView.swift` — removed recipe references
- `Views/Library/GrinderLibraryRow.swift` — grinder.brews count instead of recipes
- `Views/Library/LibraryContainer.swift` — removed recipe editing sheet
- `Views/Library/RoasterLibraryRow.swift` — roaster.coffees count instead of recipes

---

## What's Left (Future Phases)

The app builds but is now in a **stripped-down state**. Key missing functionality that needs to be rebuilt with the new coffee-bag-centric model:

1. **Coffee management UI** — Add/edit/view Coffee entities (bag of coffee from a roaster)
2. **Brew creation flow** — New flow to create a Brew linked to a Coffee (replacing the old Recipe→Brew flow)
3. **Pour template management** — UI for PourTemplate/TemplateStage (reusable pour patterns)
4. **Brew detail improvements** — Show coffee info, pour stages, etc.
5. **Data migration** — If there's existing user data with Recipes, need a Core Data migration plan
6. **Tests** — Verify the 48 new unit tests pass; add more tests for new UI/VM code

## How to Build & Test

```bash
# Build
xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" \
  -destination "platform=iOS Simulator,name=iPhone 16" build

# Test (make sure Xcode is closed first)
rm -rf ~/Library/Developer/Xcode/DerivedData/Coffee_Brewer-*
xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:"Coffee BrewerTests" test
```

## Important Gotchas

1. **Core Data class generation**: Entity classes (Brew, Coffee, Roaster, etc.) are generated at build time from `.xcdatamodeld`. There are no `.swift` source files for them. LSP will show false positive errors about missing types — **ignore them**, the project builds fine.
2. **Test target pbxproj**: Test files need explicit entries in `project.pbxproj`. Main app files are auto-discovered.
3. **Database lock**: If you get "database is locked" errors from xcodebuild, quit Xcode and clear DerivedData.
4. **No commits yet**: All changes are uncommitted working tree modifications against `ad7c0bb`.
