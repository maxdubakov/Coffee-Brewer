# Task 002: Fix Done button positioning in keyboard toolbar

## Context
Task 001 added `.padding(.top, 20)` to the "Done" HStack inside `.safeAreaInset(edge: .bottom)`. This created the desired spacing above the toolbar, but pushed the button itself down and to the right edge — it's nearly off screen.

## Objective
Make the "Done" row look like a proper toolbar: right-aligned button with sensible padding on all sides, background color, and the extra top spacing preserved so the input field doesn't sit flush against the toolbar.

## Scope
- **File:** `Coffee Brewer/Views/Components/FixedBottomLayout.swift`, lines 41-51 (the `.safeAreaInset` block)

## What to do
Restyle the "Done" HStack so it has:
1. Horizontal padding (e.g. `.padding(.horizontal, 16)`) so the button isn't at the screen edge
2. Vertical padding (e.g. `.padding(.vertical, 8)`) so the button has breathing room within the bar
3. A background (`BrewerColors.background`) so it looks like a solid toolbar
4. Keep the extra top spacing (~12-20pt) above the toolbar background so scroll content doesn't touch it. One clean way: wrap in a VStack with a `Spacer().frame(height: 20)` above the styled HStack, or use `.padding(.top, 20)` on an outer container while keeping the inner HStack padded normally.

The key: the 20pt gap should be *transparent space above* the toolbar, not padding that pushes the button down inside the toolbar.

## Non-goals
- Do not change anything outside the `.safeAreaInset` block.

## Build command
```
cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -50
```
