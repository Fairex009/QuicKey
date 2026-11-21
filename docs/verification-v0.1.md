# QuicKey v0.1: verification record

Date: 2026-11-21
Repository: https://github.com/Fairex009/QuicKey
Source commit: 0662726b32110b83e82cb72c24c0466194f02a32
Build run: https://github.com/Fairex009/QuicKey/actions/runs/44852898461
Build status: SUCCESS (GitHub-hosted macos-15 / Xcode)
Artifact name: QuicKey-v0.1-unsigned-IPA
Artifact ID: 14685509345
Unsigned IPA SHA-256: 4fa11146ef71304fa29b7c59adcbe9502817cd11ee074c8c4e3aa43606d85801

## Proven by automated build and downloaded artifact inspection
- Generated Xcode project using XcodeGen.
- Native iOS app compiled successfully for arm64.
- Keyboard app extension compiled successfully for arm64.
- IPA contains Payload/QuicKey.app/QuicKey and embedded PlugIns/QuicKeyKeyboard.appex/QuicKeyKeyboard.
- Host bundle identifier: org.quickey.prototype.
- Extension bundle identifier: org.quickey.prototype.keyboard.
- NSExtensionPointIdentifier: com.apple.keyboard-service.
- Principal class: QuicKeyKeyboard.KeyboardViewController.
- RequestsOpenAccess: false.
- Both files were identified as Mach-O 64-bit arm64 executables.

## Not yet verified
- Free Apple account provisioning and correct signing of both app and extension.
- IPAForge installing onto iPhone 13 from Ubuntu.
- Keyboard appearing under iOS Settings > General > Keyboard > Keyboards.
- Six buttons inserting text as designed in host app and Safari.
- Globe / Next Keyboard behavior on physical device.
- Seven-day resign / refresh procedure.

## Next test (requires physical iPhone and private credentials on user's Ubuntu machine)
1. Download the unsigned IPA from the successful GitHub Actions run, or use the verified artifact downloaded from ChatGPT.
2. On Ubuntu, connect and trust the unlocked iPhone via USB; run `idevice_id -l`.
3. Use IPAForge's current official Linux release to sign and install the IPA with a free Apple account. IPAForge is third-party alpha-stage software; evaluate risks before entering credentials. Never upload credentials or signing material to this repo.
4. Enable QuicKey under Settings > General > Keyboard > Keyboards > Add New Keyboard. Leave Full Access OFF.
5. Tap Hello in the host app's test field, then Search on Google in Safari. Expected insertion: "warehouse automation".
6. Validate re-signing within seven days.

An unsigned IPA is NOT installable by itself. A successful CI run does not imply the keyboard is usable until on-device acceptance passes.
