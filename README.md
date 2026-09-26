# OpenRZ67 for iOS

An iPhone app for controlling the [openrz67-trigger](https://github.com/openrz67/openrz67-trigger) Bluetooth remote trigger for the Mamiya RZ67 camera. It is the iOS counterpart of [openrz67-android](https://github.com/openrz67/openrz67-android).

## Features

- Scans for the trigger, connects, and reconnects when the connection drops
- Direct shutter release
- Countdown with a selectable delay (the trigger runs the countdown, the app shows it)
- Bulb mode with elapsed time. The trigger only holds the release; the camera must be set to B, or it just takes one normal picture at the dialed speed
- Keeps the screen on during a countdown or bulb exposure
- Follows the system light/dark setting

## Building

Requires Xcode 26 and iOS 17 or later on the phone. The simulator has no Bluetooth, so test on a real iPhone.

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen). After changing `project.yml` or adding files, regenerate it:

```bash
brew install xcodegen
xcodegen generate
```

Open `OpenRZ67.xcodeproj`, pick your team under Signing & Capabilities, and run on your phone.

## License

[MIT](LICENSE)
