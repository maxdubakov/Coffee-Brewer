# Coffee Brewer — Refactoring Summary

## Project Overview

**What**: SwiftUI + Core Data iOS coffee brewing app (MVVM + Coordinator pattern)  
**Where**: `/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer/`  
**Xcode project**: `Coffee Brewer.xcodeproj`  
**Scheme**: `Coffee Brewer`  
**Test target**: `Coffee BrewerTests`  
**Min iOS**: 17.0  

---

## Vision, Workflow & Design Decisions

### The User's Real Brewing Workflow

The owner brews pour-over coffee (V60, Orea V4) every morning while also preparing breakfast. The workflow is:

1. **Buy a new pack** (e.g., from MadHeads roaster)
2. **First brew with default recipe** — a recipe that barely changes between packs or even roasters. One default for V60, one for Orea V4.
3. **Taste it**, notice what's off (too sour, too bitter, etc.)
4. **Change 1-2 things** for the next brew — almost always the **pour pattern** (number of pours, fast vs slow, water amounts per pour). Rarely grind size. Rarely temperature. Grind size is treated as a "basement" — you change everything else first.
5. **Repeat** — iterate daily until the coffee tastes right for that pack
6. **New pack arrives** → back to step 2 with the default

**Key insight**: The pour pattern is the primary variable, not grind size. The user iterates by cloning the previous experiment and tweaking 1-2 pour parameters.

### What the User Does NOT Want
- **No timer in the app** — they have a timer on their coffee scale. The app should not be needed during actual brewing.
- **No "record live" feature** — tapping through stages while pouring is too tedious during a morning rush
- **No heavy forms** — entering lots of data while brewing is a non-starter
- **No wait stages** — the user watches the coffee bed visually and pours when it's about to go dry. Timing between pours is managed by feel/sight, not the app.
- **No auto water redistribution** (yet) — when changing one pour's amount, don't auto-adjust others. The user will manually tweak. This avoids surprising behavior. Can be added later.
- **No onboarding** — removed, was overengineered

### What the User DOES Want
- **Small, slick, beautiful app** — minimal, not feature-heavy
- **The app is a log, not a brewing guide** — set up experiment before brewing, rate after brewing, never interact during brewing
- **Clone from previous experiment** as the primary way to create a new brew — "last brew + tweak 1-2 things"
- **Delayed rating via push notification** — ~1 hour after brew is saved, send a local notification. User rates whenever convenient (could be hours later). The notification can hang around.
- **Quick access to what matters later** — pour pattern, grind, rating. The user wants to see "what did I do and what did I think about it" to decide what to change next.
- **TDS tracking** (future) — planning to buy a TDS meter, so the field exists but isn't priority UX

### The Quick Brew Screen (Core UX — Not Yet Built)

This is the most important screen in the app. One screen, no navigation, everything inline.

**Entry point**: Tap "Brew" → three quick-pick options:
```
┌──────────────────────────────────┐
│  [V60 Default]  [Orea Default]  │
│  [Last Brew: Ethiopian Natural]  │
│                                  │
│  Browse experiments...      [▼]  │  ← expands to full list
└──────────────────────────────────┘
```

**After picking a starting point**, params load and user can adjust:
```
┌─────────────────────────────────────┐
│  Ethiopian Natural · Mad Heads      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  Fast ▼         60ml  [▼]  │   │  ← row per stage
│  ├─────────────────────────────┤   │
│  │  Slow ▼        230ml  [▼]  │   │
│  └─────────────────────────────┘   │
│  [ + Add pour ]                     │
│                                     │
│  Grind  26 · Dose 18g · 1:15       │  ← compact params row
│  Temp 93°C · V60                    │
│                                     │
│  [ Save & Brew ]                    │
└─────────────────────────────────────┘
```

**Stage rows** (top, prominent — this is what changes most):
- One row per stage
- Tap type to toggle Fast ↔ Slow
- Tap amount to edit ml inline (no second screen)
- Swipe row left to delete
- `+` to add a new pour at the end
- Long-press drag to reorder (rare but available)

**Compact params row** (bottom, secondary — rarely changed):
- Grind, dose, ratio, temp, brew method shown in a compact row
- Tap any value to edit inline (one tap, no sub-screen)
- These are touched maybe once every 5-10 brews

**"Save & Brew"** saves the brew and returns. User goes and brews with their scale timer. No app interaction during brewing.

**"Save as template"** (opt-in, in a menu) — if the user likes a pour pattern, they can name it and save as a reusable template alongside V60/Orea defaults.

### Rating Flow (Not Yet Built)

1. Brew is saved via "Save & Brew"
2. ~1 hour later: local push notification — "How was your brew?"
3. User taps notification → quick rating screen (stars + optional taste profile + notes)
4. Unrated brews shown with an indicator in the library
5. User can also rate from brew detail anytime (not just via notification)

### Design Principles (Agreed)
1. **Speed over completeness** — 10 seconds to set up a brew, 5 seconds to rate
2. **Clone-and-tweak over create-from-scratch** — every new brew starts from a previous one
3. **Stages are the primary control** — they get top billing on the brew screen
4. **Everything on one screen** — no nested navigation for the core brewing flow
5. **No interaction during brewing** — the app is used before and after, never during
6. **No data migration needed** — app is in dev, never deployed to production. Clean slate is fine.
7. **Pre-fill database** — seed with sample data for development/preview (roasters, coffees, brews, built-in templates)

---

---

## Vision, Workflow & Design Decisions

### The User's Real Brewing Workflow

The owner brews pour-over coffee (V60, Orea V4) every morning while also preparing breakfast. The workflow is:

1. **Buy a new pack** (e.g., from MadHeads roaster)
2. **First brew with default recipe** — a recipe that barely changes between packs or even roasters. One default for V60, one for Orea V4.
3. **Taste it**, notice what's off (too sour, too bitter, etc.)
4. **Change 1-2 things** for the next brew — almost always the **pour pattern** (number of pours, fast vs slow, water amounts per pour). Rarely grind size. Rarely temperature. Grind size is treated as a "basement" — you change everything else first.
5. **Repeat** — iterate daily until the coffee tastes right for that pack
6. **New pack arrives** → back to step 2 with the default

**Key insight**: The pour pattern is the primary variable, not grind size. The user iterates by cloning the previous experiment and tweaking 1-2 pour parameters.

### What the User Does NOT Want
- **No timer in the app** — they have a timer on their coffee scale. The app should not be needed during actual brewing.
- **No "record live" feature** — tapping through stages while pouring is too tedious during a morning rush
- **No heavy forms** — entering lots of data while brewing is a non-starter
- **No wait stages** — the user watches the coffee bed visually and pours when it's about to go dry. Timing between pours is managed by feel/sight, not the app.
- **No auto water redistribution** (yet) — when changing one pour's amount, don't auto-adjust others. The user will manually tweak. This avoids surprising behavior. Can be added later.
- **No onboarding** — removed, was overengineered

### What the User DOES Want
- **Small, slick, beautiful app** — minimal, not feature-heavy
- **The app is a log, not a brewing guide** — set up experiment before brewing, rate after brewing, never interact during brewing
- **Clone from previous experiment** as the primary way to create a new brew — "last brew + tweak 1-2 things"
- **Delayed rating via push notification** — ~1 hour after brew is saved, send a local notification. User rates whenever convenient (could be hours later). The notification can hang around.
- **Quick access to what matters later** — pour pattern, grind, rating. The user wants to see "what did I do and what did I think about it" to decide what to change next.
- **TDS tracking** (future) — planning to buy a TDS meter, so the field exists but isn't priority UX

### The Quick Brew Screen (Core UX — Not Yet Built)

This is the most important screen in the app. One screen, no navigation, everything inline.

**Entry point**: Tap "Brew" → three quick-pick options:
```
┌──────────────────────────────────┐
│  [V60 Default]  [Orea Default]  │
│  [Last Brew: Ethiopian Natural]  │
│                                  │
│  Browse experiments...      [▼]  │  ← expands to full list
└──────────────────────────────────┘
```

**After picking a starting point**, params load and user can adjust:
```
┌─────────────────────────────────────┐
│  Ethiopian Natural · Mad Heads      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  Fast ▼         60ml  [▼]  │   │  ← row per stage
│  ├─────────────────────────────┤   │
│  │  Slow ▼        230ml  [▼]  │   │
│  └─────────────────────────────┘   │
│  [ + Add pour ]                     │
│                                     │
│  Grind  26 · Dose 18g · 1:15       │  ← compact params row
│  Temp 93°C · V60                    │
│                                     │
│  [ Save & Brew ]                    │
└─────────────────────────────────────┘
```

**Stage rows** (top, prominent — this is what changes most):
- One row per stage
- Tap type to toggle Fast ↔ Slow
- Tap amount to edit ml inline (no second screen)
- Swipe row left to delete
- `+` to add a new pour at the end
- Long-press drag to reorder (rare but available)

**Compact params row** (bottom, secondary — rarely changed):
- Grind, dose, ratio, temp, brew method shown in a compact row
- Tap any value to edit inline (one tap, no sub-screen)
- These are touched maybe once every 5-10 brews

**"Save & Brew"** saves the brew and returns. User goes and brews with their scale timer. No app interaction during brewing.

**"Save as template"** (opt-in, in a menu) — if the user likes a pour pattern, they can name it and save as a reusable template alongside V60/Orea defaults.

### Rating Flow (Not Yet Built)

1. Brew is saved via "Save & Brew"
2. ~1 hour later: local push notification — "How was your brew?"
3. User taps notification → quick rating screen (stars + optional taste profile + notes)
4. Unrated brews shown with an indicator in the library
5. User can also rate from brew detail anytime (not just via notification)

### Design Principles (Agreed)
1. **Speed over completeness** — 10 seconds to set up a brew, 5 seconds to rate
2. **Clone-and-tweak over create-from-scratch** — every new brew starts from a previous one
3. **Stages are the primary control** — they get top billing on the brew screen
4. **Everything on one screen** — no nested navigation for the core brewing flow
5. **No interaction during brewing** — the app is used before and after, never during
6. **No data migration needed** — app is in dev, never deployed to production. Clean slate is fine.
7. **Pre-fill database** — seed with sample data for development/preview (roasters, coffees, brews, built-in templates)

---

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

### Test Status: ✅ ALL 55 TESTS PASS
```
xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:"Coffee BrewerTests" test
```
- `Coffee_BrewerTests`: 2 tests (default)
- `BrewExtensionsTests`: 13 tests
- `CoffeeExtensionsTests`: 12 tests
- `BrewFormDataTests`: 9 tests
- `PourTemplateExtensionsTests`: 6 tests
- `StageFormDataTests`: 7 tests
- `CoffeeFormDataTests`: 6 tests

### Git Status: COMMITTED
All changes committed as `88da9ca Get rid of recipies. Prepare code for experiment-centric app`.

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

### Stages & Pour Templates (Design)

The app models pour-over brewing as a sequence of **stages** (individual pours). There are two levels:

#### 1. `Stage` (actual recorded stages on a Brew)
- Each `Stage` belongs to one `Brew` (to-many from Brew, cascade delete)
- Attributes: `id`, `orderIndex` (Int16, for sorting), `type` (String: `"fast"` or `"slow"`), `waterAmount` (Int16, in ml)
- **No "wait" stage type** — the user manages timing themselves visually (watching the coffee bed)
- **No duration/seconds field** — timing is not tracked per stage
- `Brew.stagesArray` returns stages sorted by `orderIndex`
- `Brew.totalStageWater` sums all stage water amounts
- `StageFormData` is the Swift struct used in forms: has `type: StageType` enum (`.fast`/`.slow`), `waterAmount: Int16`, `orderIndex: Int16`. Can init from a `Stage` entity.
- `StageType` is an enum with `.fast` and `.slow` cases, with `StageType.fromString()` parser

#### 2. `PourTemplate` + `TemplateStage` (reusable pour patterns)
- A `PourTemplate` is a reusable blueprint (e.g., "V60 Default", "Orea V4 Default")
- Attributes: `id`, `name`, `brewMethod` (String: `"V60"`, `"Orea V4"`), `isBuiltIn` (Bool)
- Each template has to-many `TemplateStage` children (cascade delete)
- `TemplateStage` uses **percentages** instead of absolute water: `waterPercentage` (Double, e.g. 20.0 = 20%)
- `TemplateStage` also has: `id`, `orderIndex`, `type` (same `"fast"`/`"slow"` strings)
- `PourTemplate.stagesArray` returns template stages sorted by `orderIndex`
- `PourTemplate.createStages(for:waterAmount:context:)` — **instantiates concrete `Stage` objects** on a Brew by converting percentages to absolute ml: `Int16(Double(waterAmount) * templateStage.waterPercentage / 100.0)`
- `PourTemplate.seedBuiltInTemplates(in:)` — idempotent seeder that creates 2 built-in templates if none exist:
  - **V60 Default**: Fast bloom (20%) → Slow pour (80%)
  - **Orea V4 Default**: Fast bloom (20%) → Slow pour (40%) → Fast pour (40%)

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

## What's Left (Implementation Plan)

The app builds but is now in a **stripped-down state**. Each phase leaves the app in a buildable state.

### Phase 3: Coffee Management UI
- `AddCoffee.swift` view + `AddCoffeeViewModel` (modeled after existing Roaster add flow)
- `CoffeeDetailSheet.swift` — view a coffee bag and its brews
- `CoffeeLibraryRow.swift` for the library list
- Wire into `NavigationCoordinator` + `AddChoice`
- Update `AllLibraryView` to show real Coffee rows

### Phase 4: Quick Brew Screen (Core Feature)
- Build the one-screen brew setup (see "The Quick Brew Screen" in Vision section above)
- Three quick-pick options: V60 Default, Orea Default, Last Brew
- "Browse experiments" expandable list
- Inline stage rows (tap to toggle type, tap to edit amount, swipe to delete, + to add, drag to reorder)
- Compact params row (grind, dose, ratio, temp — tap to edit inline)
- "Clone from previous brew" logic — clone all params + stages into new draft
- "Save & Brew" — saves brew and returns
- "Save as template" (opt-in menu option)

### Phase 5: Rating + Notifications
- Local push notification scheduled ~1hr after brew save
- Notification deep-links to rating screen
- Quick rating screen: stars + optional taste profile (acidity, bitterness, body, sweetness) + notes
- Unrated brews shown with indicator in library
- Can also rate from brew detail anytime

### Phase 6 (Future/Optional)
- Auto water redistribution when adding/removing pours
- TDS meter integration (field exists, needs UX prominence)
- Pour template management UI (create/edit/delete custom templates)
- Data export improvements
- Additional tests for new UI/VM code

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
4. **Latest commit**: `88da9ca Get rid of recipies. Prepare code for experiment-centric app`.
