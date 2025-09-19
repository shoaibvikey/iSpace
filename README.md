
# iSpace

iSpace is a secure, offline-first password and credit card manager for iOS, built entirely with SwiftUI. It leverages on-device security features like Face ID and the Keychain to ensure your sensitive data remains private and is never stored in the cloud.





## About The Project

 This project was created to provide a simple yet highly secure solution for managing personal credentials without relying on third-party servers. The core principle is privacy by design: all data is encrypted and stored locally on the user's device, accessible only through biometric authentication or the device passcode.

The app is built using modern iOS development practices, featuring a clean, reactive architecture and a user-friendly interface.


## Features


- **Biometric Security:** Unlocks using Face ID or the device passcode, leveraging Apple's LocalAuthentication framework.

- **100% Offline Storage:** All sensitive data is encrypted and stored securely in the device's Keychain. No data ever leaves the device.

- **Onboarding Flow:** A welcoming, multi-page onboarding screen for first-time users that explains the app's features and security.

- **Tab-Based Navigation:** A clean TabView separates credit cards and passwords for easy organization.

- **Custom UI:** A visually appealing, custom-designed credit card view that masks sensitive information.

- **Full CRUD Functionality:** Users can add, view, and delete their saved items.

- **Live Search:** A search bar with context-aware placeholders ("Search cards" vs. "Search passwords") to filter items in real-time.

- **Form Validation:** The "Add Item" form provides real-time validation to ensure data integrity (e.g., correct card number length, valid expiry date).

- **Draft Saving:** The "Add Item" form automatically saves a draft as you type, which is restored if the app is closed unexpectedly during a session.

- **Copy to Clipboard:** Easily copy usernames, passwords, card numbers, and other details with a single tap.

- **Open in Safari:** A convenient button to open a saved website directly in the browser.



## Technology Stack & Architecture

- **UI Framework:** SwiftUI

- **Architecture:** Model-View-ViewModel (MVVM)

- **Asynchronous Programming:** Combine for reactive form validation.

- **Security:** LocalAuthentication for Face ID/Passcode and Keychain for encrypted storage.
## How To Run

- Clone the repository to your local machine.

- Open the .xcodeproj file in Xcode.

- Sign the app with your own Apple Developer account in the "Signing & Capabilities" tab.

- Select a simulator or a physical device and press Run.
