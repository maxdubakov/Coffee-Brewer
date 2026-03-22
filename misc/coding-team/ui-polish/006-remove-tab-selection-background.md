# Task 006: Remove Tab Selection Background Highlight

## Context

The selected tab item shows a background highlight/indicator behind the icon. The user wants only the icon's visual change (bolder weight) to indicate selection — no background shape.

## Objective

Remove the background highlight behind the selected tab bar icon.

## Scope

### `Main.swift`

In the `UITabBarAppearance` configuration (both in `init()` and `.onAppear`), add:

```swift
appearance.selectionIndicatorImage = UIImage()
appearance.selectionIndicatorTintColor = .clear
```

This sets the selection indicator to an empty image with clear tint, effectively removing the background highlight while preserving the icon's selected state appearance (bolder rendering).

If the above doesn't fully remove it, also try setting the `stackedLayoutAppearance.selected` background to clear:
```swift
appearance.stackedLayoutAppearance.selected.iconColor = UIColor(BrewerColors.cream)
```

The accent color (`.accentColor(BrewerColors.cream)`) already controls the selected icon tint — that should stay.

## Non-goals
- Don't change tab icons or remove any tabs
- Don't change the accent color

## Constraints
- Build + tests must pass
- Verify: selected tab shows only the icon change (tint/weight), no background highlight
