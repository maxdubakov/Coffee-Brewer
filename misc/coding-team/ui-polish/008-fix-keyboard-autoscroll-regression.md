# Task 008: Fix Keyboard Auto-Scroll Regression

## Context

Task 005 added `.ignoresSafeArea(.keyboard)` to `FixedBottomLayout` to hide the save button behind the keyboard. But this also disabled SwiftUI's auto-scroll-to-focused-field, so bottom fields are hidden behind the keyboard again.

We need both behaviors:
1. Save button hidden behind keyboard (not floating above it)
2. ScrollView auto-scrolls to the focused field

## Objective

Remove `.ignoresSafeArea(.keyboard)` and instead hide the actions bar when the keyboard is visible.

## Scope

### `FixedBottomLayout.swift`

1. **Remove** `.ignoresSafeArea(.keyboard)` from the outer VStack (line 64).

2. **Add keyboard visibility state** using `NotificationCenter`:
   ```swift
   @State private var isKeyboardVisible = false
   ```

3. **Conditionally hide the actions bar** when keyboard is visible. Wrap the bottom actions VStack:
   ```swift
   if !isKeyboardVisible {
       VStack {
           Divider()
               .background(BrewerColors.divider)
           actions
               .padding(actionPadding)
       }
       .background(BrewerColors.background)
   }
   ```

4. **Observe keyboard notifications** on the outer VStack:
   ```swift
   .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
       isKeyboardVisible = true
   }
   .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
       isKeyboardVisible = false
   }
   ```

5. **You can remove `.padding(.bottom, 120)`** from the content VStack — it was a workaround for the broken keyboard avoidance. With proper keyboard avoidance restored, the ScrollView will auto-scroll to focused fields. Test whether removing it causes issues; if the bottom field is still cut off with keyboard open, keep a smaller padding (e.g., 20).

6. **Add `import Combine`** if needed for `.onReceive`.

## Non-goals
- Don't animate the actions bar show/hide (instant is fine — the keyboard animation covers the transition)
- Don't change any other files

## Constraints
- Build + tests must pass
- Verify in simulator:
  - Open Add Grinder → tap Burr Size → keyboard opens, save button disappears, field auto-scrolls into view
  - Dismiss keyboard → save button reappears
  - Same behavior in Add Coffee, Add Roaster, BrewEditor
