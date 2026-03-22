# Task 003: Fix Keyboard — Double ScrollView + Done Button

## Context

Two related keyboard issues:
1. **Keyboard covers bottom fields** (e.g., Burr Size in Add Grinder). Root cause: forms have their own `ScrollView` nested inside `FixedBottomLayout`'s `ScrollView`. Double-nested ScrollViews break SwiftUI's automatic keyboard avoidance.
2. **No easy way to dismiss number pad keyboard**. `.numberPad` and `.decimalPad` keyboards have no Return key. The existing `.onTapGesture` dismiss on inner forms is unreliable due to the nesting.

## Objective

1. Eliminate double-nested ScrollViews so keyboard avoidance works.
2. Add a "Done" toolbar button above the keyboard for easy dismissal.

## Scope

### Remove inner ScrollViews from form components

These three files each wrap their content in a `ScrollView` that sits inside `FixedBottomLayout`'s `ScrollView`:

**`GrinderForm.swift`:**
- Remove the `ScrollView { }` wrapper (keep the inner VStack content)
- Remove `.scrollDismissesKeyboard(.interactively)`
- Remove `.onTapGesture { focusedField = nil }` (will be handled centrally)
- Remove `.padding(.bottom, 100)` (no longer needed without inner scroll)

**`CoffeeForm.swift`:**
- Same changes as GrinderForm
- Keep `.onAppear { initializeProcessState() }` — move it to the outermost VStack

**`RoasterForm.swift`:**
- Same changes as GrinderForm
- Remove the commented-out `.padding(.horizontal, 16)` line while you're at it

### Add keyboard dismiss to `FixedBottomLayout.swift`

Add a `.toolbar` with `ToolbarItemGroup(placement: .keyboard)` containing a "Done" button on the `ScrollView` inside `FixedBottomLayout`. The Done button should call `UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)`. This approach doesn't need any `@FocusState` — it universally dismisses whatever keyboard is active.

Also add `.onTapGesture` on the ScrollView content area to dismiss keyboard on tap (replacing what was removed from individual forms). Use the same `resignFirstResponder` approach.

### BrewEditor — no ScrollView changes needed

`BrewEditor` does NOT have the double ScrollView problem (it puts content directly in `FixedBottomLayout`). It will automatically get the Done button from the `FixedBottomLayout` change. No changes needed to `BrewEditor.swift`.

## Non-goals
- Don't restructure `FixedBottomLayout` beyond adding the toolbar and tap gesture
- Don't change `FormKeyboardInputField`, `StageRowView`, or `BrewParamCell`
- Don't touch tab bar (Tasks 001/002)

## Constraints
- Must build successfully
- All existing tests must pass
- Verify in simulator (iPhone 16 Pro Max):
  - Open Add Grinder → tap Burr Size → keyboard should NOT cover the field
  - Number pad keyboard shows "Done" button in toolbar above keyboard
  - Tapping Done dismisses the keyboard
  - Same behavior works in Add Coffee, Add Roaster, and BrewEditor
