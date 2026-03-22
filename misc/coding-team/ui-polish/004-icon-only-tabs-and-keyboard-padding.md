# Task 004: Icon-Only Tabs + Fix Keyboard Content Padding

Two corrective fixes from user testing.

## Fix A: Icon-only tabs (no text labels)

Tab labels are still too close to the bottom edge even with standard `Label`. User wants icon-only tabs — no text.

### `Main.swift`
- Replace `Label("Brew", image: "brew")` with `Image("brew")` (same for Add and History)
- That's it. No text in tab items.

## Fix B: Keyboard still covers bottom fields

Removing the inner ScrollViews in Task 003 also removed `.padding(.bottom, 100)` that gave the scroll content extra space. Without it, fields at the bottom of forms (like Burr Size) can't scroll above the keyboard.

### `FixedBottomLayout.swift`
- Add `.padding(.bottom, 120)` to the content VStack inside the ScrollView (the one with `alignment: .leading, spacing: 30`). This provides enough scrollable space for the bottom-most field to scroll above the keyboard + fixed actions bar.

The content VStack currently looks like:
```swift
VStack(alignment: .leading, spacing: 30) {
    content
}
.padding(contentPadding)
.onTapGesture { ... }
```

Add the bottom padding:
```swift
VStack(alignment: .leading, spacing: 30) {
    content
}
.padding(contentPadding)
.padding(.bottom, 120)
.onTapGesture { ... }
```

## Non-goals
- Don't change form files (GrinderForm, CoffeeForm, RoasterForm)
- Don't change keyboard toolbar or dismiss behavior

## Constraints
- Build + tests must pass
- Verify: Open Add Grinder → tap Burr Size → field should be visible above keyboard
- Verify: Tab bar shows only icons, no text
