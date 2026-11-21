# QuicKey v0.1

An experimental **offline six-command keyboard extension for iPhone and iPad**. Developed with no Mac and no paid Apple account.

**Current verification:** source checks on Linux only; compile/build, signing and installation require separate gates. **Never upload Apple credentials, keys, or profiles to this public repository.**

## Feature test

Inside a compatible text field, switch to QuicKey, then tap **Hello** to insert "Hello from QuicKey!" or **Search** to insert "warehouse automation". The keyboard includes Translate, Review, Summarize, Sign-off, Delete and Next Keyboard buttons. It does not float over other apps, submit searches automatically, or work in protected password fields. Full Access is **OFF** by design.

## Build on GitHub (free, unsigned)

Repository: https://github.com/Fairex009/QuicKey

1. On the Actions page, open **Build unsigned QuicKey IPA**, select the successful build from main. Pushes to main touching source also start a build.
2. Download **QuicKey-v0.1-unsigned-IPA** from the run's Artifacts.
3. Unzip the downloaded artifact to get "QuicKey-v0.1-unsigned.ipa".
4. Do not mistake the unsigned IPA for an installable app: it still must be signed by your own Apple account. The CI workflow never asks for signing credentials.

The workflow compiles with XcodeGen and Xcode on GitHub's public macOS runner and checks that the keyboard .appex is present.

## Linux installation, experimental

IPAForge: https://github.com/IPAForge/ipaforge/releases

Ubuntu prerequisites:

    sudo apt update
    sudo apt install -y usbmuxd libimobiledevice-utils usbutils
    sudo systemctl restart usbmuxd
    idevice_id -l

Unlock iPhone, connect USB data cable and trust the computer. Download the official IPAForge Linux build from its release page, inspect its provenance and install it. IPAForge is a **third-party, alpha-stage** installer that needs sensitive Apple authentication. Assess its security before signing in. Never share Apple password, 2FA code, private keys, pairing information or provisioning profiles in chat or on GitHub.

In IPAForge, sign and install the unsigned IPA with your own **free Apple account**. The host app and keyboard extension must each be signed appropriately. Enable Developer Mode if iOS requires it. This route is not yet verified on our device.

## iPhone acceptance test

1. Open QuicKey once.
2. Settings > General > Keyboard > Keyboards > Add New Keyboard > QuicKey.
3. Leave **Allow Full Access** disabled.
4. Open QuicKey test field, switch to QuicKey via globe, tap Hello. Expect exact insertion "Hello from QuicKey!".
5. Tap Delete and use Next to change keyboards.
6. In Safari, open google.com, tap search field, switch to QuicKey and tap Search. Expect "warehouse automation" to be inserted, **not** automatically submitted.
7. Only after the iPhone test passes should we add snippet editing and persistent shared storage.

**Free Apple provisioning is valid for only 7 days**; re-sign/refresh before expiration. Free accounts have device and App ID limits. The source and build cost are zero for GitHub's standard public-repository runners, but a long-lived keyboard with no maintenance is **not** possible through ordinary free Apple provisioning.
