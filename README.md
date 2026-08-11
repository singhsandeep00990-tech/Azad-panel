# Smart Panel Flutter App

This is the first demo version for an 8-relay smart panel.

## Current features
- Demo customer login
- 8 relay ON/OFF switches
- 8 feedback status indicators
- 8 current displays
- Android/iOS compatible Flutter UI
- Demo mode only; no Firebase/ESP32 connection yet

## Open in Android Studio
1. Install Flutter and Android Studio.
2. Extract this project.
3. In Android Studio choose **Open** and select this folder.
4. Run `flutter pub get`.
5. Start an Android emulator or connect an Android phone with USB debugging.
6. Press Run.

## Important
The current login and relay feedback are local demo behavior. The next version should add Firebase Authentication/Realtime Database or a custom secure backend, then connect the ESP32 to the same backend.

For a market product, do not store customer passwords or device credentials directly in the app source code.
