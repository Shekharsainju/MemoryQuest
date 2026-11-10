# MemoryQuest

An offline native SwiftUI iPhone app for learning five memory strategies, practising ten challenges in Computer Science or Biology, and constructing a ten-building city.

Open `MemoryQuestfinal.xcodeproj` in Xcode and run the `MemoryQuestfinal` scheme on an iPhone simulator. The project deployment target is iOS 26.6.

## Structure

- `MemoryQuestfinal/App`: shared navigation and root view.
- `Models`: educational content and Codable progress records.
- `Data`: bundled subject content, lesson content, and atomic local JSON persistence.
- `Features`: Home, lessons, challenge activities, city, progress/history, and settings.
- `Shared`: styling, reusable controls, and Canvas illustrations derived from the prototype geometry.
- `MemoryQuestTests`: seven focused Swift Testing checks.
- `ReferencePrototype/index 2.html`: original interactive design reference.

Lesson completion is shared across subjects. Attempts and concept reviews are subject-specific. Buildings are awarded on challenge completion, once per challenge across both subjects. Progress is stored locally in Application Support.

## Verification status

The app built successfully for the iPhone 18 Pro simulator. An initial smoke check exercised onboarding, Home, tabs, lesson reading, and challenge gating. It found lesson formatting and bottom-navigation layout issues; fixes were applied and the app rebuilt successfully. The final smoke recheck and focused test execution are pending. Tests should not yet be considered verified passing.
