# Task 007: Fix Tab Selection Background (Corrective)

## Context

Task 006 tried `selectionIndicatorImage = UIImage()` and `selectionIndicatorTintColor = .clear` but this didn't remove the background highlight on newer iOS. The highlight is likely from `UITabBarItemAppearance`'s selected state, not the selection indicator.

## Objective

Remove the background color/highlight change when a tab is selected. Only the icon tint should change.

## Scope

### `Main.swift`

In both `init()` and `.onAppear`, after creating the `UITabBarAppearance`, configure the item appearance states explicitly:

```swift
let itemAppearance = UITabBarItemAppearance()
itemAppearance.selected.iconColor = UIColor(BrewerColors.cream)
itemAppearance.normal.iconColor = UIColor(BrewerColors.cream.opacity(0.5))

appearance.stackedLayoutAppearance = itemAppearance
appearance.inlineLayoutAppearance = itemAppearance
appearance.compactInlineLayoutAppearance = itemAppearance
```

Remove the `selectionIndicatorImage` and `selectionIndicatorTintColor` lines (they didn't work).

This explicitly controls what changes between normal and selected states — only the icon color, no background.

## Constraints
- Build + tests must pass
- Verify: no background highlight on selected tab, only icon tint changes
