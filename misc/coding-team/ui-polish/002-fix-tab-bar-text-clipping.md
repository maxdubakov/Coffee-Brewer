# Task 002: Fix Tab Bar Text Clipping

## Context

Tab bar labels (Brew, Add, History) are too close to the bottom edge on iPhone 16 Pro Max. The app uses a custom `TabIcon` struct with `VStack(spacing: 4) { SVGIcon + Text }` inside `.tabItem`. SwiftUI's `.tabItem` only officially supports `Label`, `Image`, or `Text` — custom VStacks get unpredictable layout.

After Task 001, the Home tab is removed. There are now 3 tabs: Brew, Add, History.

## Objective

Fix tab label positioning so text has comfortable spacing from the bottom edge.

## Scope

### `Main.swift`
- Replace the custom `TabIcon` VStack inside each `.tabItem` with standard SwiftUI content: `Label("Brew", image: "brew")` or `Image("brew") + Text("Brew")` pattern.
- The tab icons are custom SVG assets (not SF Symbols). They're referenced by name: `"brew"`, `"add.recipe"`, `"history"`. These are image assets in the asset catalog. Use `Image("name")` to reference them — NOT `SVGIcon` (which is a custom component not supported inside `.tabItem`).
- Remove the `TabIcon` struct entirely — it will no longer be needed.
- Keep the existing `UITabBarAppearance` configuration (opaque background, no shadow, BrewerColors.background).

## Non-goals
- Don't change tab bar colors or appearance beyond fixing the layout
- Don't touch keyboard handling (Task 003)
- Don't modify any other views

## Constraints
- Must build successfully
- All tests must pass
- Verify in simulator (iPhone 16 Pro Max) that tab labels have proper spacing
