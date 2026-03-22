# Task 001: Add top padding to "Done" keyboard toolbar row

## Context
`FixedBottomLayout.swift` renders a "Done" button row via `.safeAreaInset(edge: .bottom)` when the keyboard is visible (lines 41-47). Currently the content sits flush against the top of this row — zero gap.

## Objective
Add ~20pt of top padding to the "Done" row so there's visible breathing room between the focused input field and the toolbar.

## Scope
- **File:** `Coffee Brewer/Views/Components/FixedBottomLayout.swift`
- Add `.padding(.top, 20)` (or equivalent) to the HStack inside the `if isKeyboardVisible` block within the `.safeAreaInset(edge: .bottom)` modifier.

## Non-goals
- Do not change input fields, keyboard behavior, or scroll logic.
- Do not restructure the layout.

## Build command
```
cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -50
```
