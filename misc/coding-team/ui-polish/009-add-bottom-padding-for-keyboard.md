# Task 009: Add Bottom Padding for Keyboard Scrollability

## Context

Task 008 removed `.padding(.bottom, 120)` from FixedBottomLayout. The auto-scroll-to-focused-field works for persistent TextFields (like Notes in CoffeeForm), but NOT for dynamically-created TextFields like `BrewParamCell` in BrewEditor (the TextField only exists when `isEditing = true`). The horizontal ScrollView wrapping the params also prevents SwiftUI from auto-scrolling vertically.

Without bottom padding, the params section at the bottom of BrewEditor can't be scrolled above the keyboard.

## Objective

Add back bottom content padding so bottom-of-form fields can be scrolled above the keyboard manually.

## Scope

### `FixedBottomLayout.swift`

Add `.padding(.bottom, 80)` to the content VStack inside the ScrollView (after `.padding(contentPadding)`, before `.onTapGesture`). 80pt is enough to allow the params row to scroll into view above the keyboard without adding excessive empty space when keyboard is hidden.

## Non-goals
- Don't try to fix the dynamic TextField auto-scroll issue in BrewParamCell (that would require ScrollViewReader + significant refactor)
- Don't change BrewEditor or any form files

## Constraints
- Build + tests must pass
- Verify: Open BrewEditor → tap Temp → manually scroll up → field should be visible above keyboard
