# QuicKey on iOS and iPadOS

This guide covers the **currently implemented Apple-platform keyboard**. See the [project README](../README.md) for platform-neutral goals. Android is not implemented yet.

## What runs on-device

The `QuicKey` host app helps users activate and test the custom keyboard. The `QuicKeyKeyboard` extension inserts offline text into ordinary host fields. It does not send or execute commands, read other apps' conversations or require Full Access.

The current known-working, human-reported baseline is **v0.2.4 on iPhone 13**. Its core behavior and CI checks are recorded in [PR #1](https://github.com/Fairex009/QuicKey/pull/1), [PR #2](https://github.com/Fairex009/QuicKey/pull/2) and [Issue #4](https://github.com/Fairex009/QuicKey/issues/4). PR #2 CI passed, and the user reported the in-place-installed application working. That is **not** a claim that every on-device regression case was formally executed.

## Build an unsigned IPA

1. Open [GitHub Actions](https://github.com/Fairex009/QuicKey/actions) and choose **Build unsigned QuicKey IPA**.
2. Use a successful run for the reviewed source revision. Under **Artifacts**, download the unsigned IPA archive. Artifact and IPA filenames may change with releases.
3. Keep build and signing separate. The existing macOS GitHub workflow compiles Swift template/history/deletion checks, checks source structure, generates the icon, builds the iOS app and embedded keyboard extension, verifies the app identifiers and Full Access policy, and packages an **unsigned** IPA.
4. No Apple account, provisioning file, signing identity or pairing record should be stored in GitHub Actions.

## Safe device installation or update

For the existing installation, use the **same Apple developer account/team and effective signed bundle IDs** as the current app. The development repo's unsigned identifiers are `org.quickey.prototype` (host) and `org.quickey.prototype.keyboard` (extension). Signing tools may transform identifiers; the effective existing signed identity must remain the same for a safe in-place upgrade.

1. Keep QuicKey and any other currently working sideloaded apps installed. **Do not uninstall QuicKey** to update or troubleshoot.
2. On the existing Ubuntu laptop, use the already-working local signing/install tool (currently [IPAForge](https://github.com/IPAForge/ipaforge/releases)) and a functioning USB data connection. Unlock the device and accept only expected trust prompts.
3. Inspect the installer plan **before approving**: it must show an in-place upgrade of QuicKey with its existing keyboard extension, not a new app slot, removed app, revoked certificate or changed signing team. Stop if this condition is not met.
4. Sign and install the selected reviewed unsigned IPA. Verify version and keyboard availability after updating.
5. In iOS Settings, enable QuicKey under **General → Keyboard → Keyboards** and keep **Allow Full Access OFF**. Switch with the globe/next-keyboard key in a normal text field.

A free Apple signing account may require re-signing before its provisioning expires. Phone-only automatic refresh is **not a verified part of this build route**; keep that investigation and the known USB fallback in [Issue #3](https://github.com/Fairex009/QuicKey/issues/3).

## Regression checks on a physical iPhone/iPad

Before calling an update accepted, test the actual changed behavior as well as these safeguards:

- **Start:** all supported roles insert the exact intended startup text, including `cmd.boot AGENTS.md`, mode and refresh lines, without automatic send.
- **Handle:** add mixed PR/Issue numbers, choose Direct/Deep/Fast+Deep, inspect the full scrollable preview, and confirm Start→Handle does not duplicate startup prefixes.
- **Recent:** Start-only and composed insertions appear; saved text is unchanged by unrelated clipboard contents, sending text elsewhere or deleting from the host field; remove and confirmed clear work.
- **Editing:** one-grapheme delete, word/command-line delete, hold-to-repeat and two-step generated-text clear work conservatively. If the host withholds context, unrelated text must not be erased.
- **Visual/accessibility:** icon, light/dark appearance, labels, navigation/globe key and keyboard height remain usable on the target device.
- **Upgrade:** existing app and extension remain in place with the same signed identities; existing history survives and Full Access remains OFF.

Additional acceptance criteria belong in the scoped feature Issue and PR. Preserve regression results and unresolved device limitations there rather than adding a dated release diary to the root README.

## Recovery and privacy

The original v0.1 source checkpoint is commit `3795cf62c8944d37c986c865360acd6c37652f8d`, but do not reinstall older versions casually: removing an app can erase extension-local history. Use reviewed source and in-place updates, and preserve a working installation until the replacement is validated.

Do not upload Apple login information, pairing files, device IDs, signing profiles, certificates, keys or private logs to this **public** repository.
