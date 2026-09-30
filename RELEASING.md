# Releasing to the App Store

Status and checklist for the first App Store release. Tick items off as they are done.

## Done

- [x] App works against the trigger (tested as "My Mac (Designed for iPhone)" on an Apple silicon Mac)
- [x] Export compliance answered in `Info.plist` (`ITSAppUsesNonExemptEncryption = NO`)
- [x] Privacy policy: https://openrz67.github.io/privacy.html
- [x] Support page: https://openrz67.github.io/support.html
- [x] Project site, org profile and trigger README link this repo as working, build from source

## Once

- [ ] Enroll in the Apple Developer Program as an **individual** (99 USD/year). An ENK does not qualify for an organization account; Apple only accepts legal entities (AS, forening). An individual account can be migrated to an organization later.
- [ ] Get an iPhone on iOS 17 or later (XR/XS or newer) for testing and the review demo video
- [ ] Replace the placeholder app icon (`OpenRZ67/Assets.xcassets/AppIcon.appiconset/icon.png`, upscaled from the 512 px Play icon, text close to the edge) with a proper 1024 px one
- [ ] Create the app in App Store Connect: iOS, name `OpenRZ67` (fallback `OpenRZ67 Remote`), English, bundle ID `dev.hellevang.openrz67`, SKU `openrz67-ios`

## App Store Connect

- [ ] App Information: category Photo & Video, age rating questionnaire all "no" (4+), EU DSA status **non-trader**
- [ ] Pricing: Free, all territories
- [ ] App Privacy: privacy policy URL above, **Data Not Collected**
- [ ] Version 1.0: support URL above, description, keywords, copyright `2026 Mathias Hellevang`
- [ ] Screenshots: 6.9" (1320 × 2868), from the largest iPhone simulator or a real phone
- [ ] Keep "Mamiya" out of the app name and icon; "for the Mamiya RZ67" in the description is fine (guideline 5.2)

## Build and submit

- [ ] Bump `CURRENT_PROJECT_VERSION` in `project.yml` for every upload (`MARKETING_VERSION` is the user-facing version), then `xcodegen generate`
- [ ] Xcode: destination "Any iOS Device", Product → Archive, Distribute App → App Store Connect
- [ ] TestFlight: test on the iPhone, optionally with others who have built a trigger (external testers need a short beta review first)
- [ ] Record a demo video showing the phone and the camera firing in the same shot; upload it unlisted
- [ ] Submit for review with the notes below and the video link

Review notes:

> This app controls the openrz67 trigger, an open-source Bluetooth LE remote release that plugs into the Mamiya RZ67 camera's remote port (https://github.com/openrz67). The app requires this hardware to do anything; without it, it stays on "Scanning for devices". Demo video of the app firing the camera: <link>. No account or login is needed, and the app collects no data.

## After release

- [ ] Change the iOS status on the project site, org profile and trigger README from "in progress" to released, with an App Store link
