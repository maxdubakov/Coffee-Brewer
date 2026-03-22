# Task 004: Notification service + deep-link to rating sheet

## Context
Rating sheet and entry points are wired (Tasks 001-003). Now we need local notifications that remind users to rate their brew ~1 hour after saving, and deep-link from notification tap to the rating sheet.

## Objective
1. Create a notification service that requests permission and schedules notifications
2. Schedule a notification after each brew save
3. Handle notification tap → navigate to rating sheet for that brew

## What to build

### 1. NotificationService (`Coffee Brewer/Utils/NotificationService.swift`)
- A simple class/struct (not a view model) with static methods:
  - `requestPermission()` — calls `UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])`. Fire-and-forget, no UI feedback needed.
  - `scheduleBrewRatingReminder(brewID: UUID)` — schedules a local notification:
    - Trigger: `UNTimeIntervalNotificationTrigger` with 3600 seconds (1 hour), repeats: false
    - Content: title "How was your brew?", body "Tap to rate your latest brew", sound: default
    - Identifier: `"brew-rating-\(brewID.uuidString)"` (so it can be cancelled if needed)
    - Store `brewID` in `userInfo`: `["brewID": brewID.uuidString]`
  - `cancelBrewRatingReminder(brewID: UUID)` — cancels pending notification for a brew (useful if brew is deleted or already rated)

### 2. Request permission on app launch
- **File:** `Coffee Brewer/Coffee_BrewerApp.swift` (or whatever the @main App struct is)
- Call `NotificationService.requestPermission()` in the app's `init()` or an `.onAppear` on the root view
- Find the actual app entry point file first

### 3. Schedule notification after brew save
- **File:** `Coffee Brewer/ViewModels/BrewEditorViewModel.swift`
- In `saveBrew()`, after successful `viewContext.save()`, call `NotificationService.scheduleBrewRatingReminder(brewID: brew.id!)`
- Import the notification service as needed

### 4. Handle notification tap → open rating sheet
- **File:** App entry point (the @main struct) — set up `UNUserNotificationCenter.current().delegate`
- Create a notification delegate (can be a simple class conforming to `UNUserNotificationCenterDelegate`)
- In `userNotificationCenter(_:didReceive:withCompletionHandler:)`:
  - Extract `brewID` from `response.notification.request.content.userInfo`
  - Use `NavigationCoordinator` to navigate to the rating sheet
- **File:** `Coffee Brewer/Coordinators/NavigationCoordinator.swift`
  - Add a published property like `@Published var brewToRate: NSManagedObjectID? = nil` (or use UUID and fetch)
  - Add a method `openRatingSheet(brewID: UUID)` that fetches the Brew by UUID and sets `brewToRate`
- **File:** `Coffee Brewer/Views/Main.swift` (or root view)
  - Observe `navigationCoordinator.brewToRate` and present `RatingSheet` when set
  - Use `.sheet(item:)` pattern

## Non-goals
- No notification settings UI
- No cancel-on-rate (can be added later)
- No rich notification content

## Caveats
- `UNUserNotificationCenter.current().delegate` must be set early (before app finishes launching) to catch notification taps that cold-launch the app
- The brew's `id` is a UUID optional on Core Data — use `brew.id!` after save (it's always set)
- To fetch a Brew by UUID for deep-link: use `NSFetchRequest<Brew>` with `NSPredicate(format: "id == %@", brewUUID as CVarArg)`

## Build command
```
cd "/Users/max/Documents/Programming/fun/swift-apps/coffee-brewer/Coffee Brewer" && xcodebuild -project "Coffee Brewer.xcodeproj" -scheme "Coffee Brewer" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | tail -50
```
