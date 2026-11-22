# QuicKey v0.2.4

An **offline FAIREX command keyboard for iPhone and iPad**. It inserts reusable commands into text fields, without a Mac, paid Apple Developer membership, Full Access, or an extra iPhone sideloading app.

> Status: v0.2.4 is a release candidate, pending CI and physical-device acceptance. Actual in-place upgrade and every control still require acceptance testing on the iPhone. Do not upload Apple passwords, profiles, private keys, pairing files or personal credentials to this public repo.

## Features

- **Start:** pick one of the five FAIREX roles and insert the exact new-chat template, including `cmd.boot AGENTS.md`, `pref.mode GOD`, session toggles, both refresh commands and `cmd.deep:`.
- **Handle:** compose `git.handle PR #160, Issue #159, Issue #6` with any number of mixed PR and Issue targets. Choose Direct, Deep, or Fast+Deep; optionally include the role.
- **Quick:** FAST+DEEP, Deep task, Batch ON, Git Handle prefixes and Refresh.
- **Recent:** automatically save each QuicKey-generated insertion at insertion time, including Start Chat alone. Incrementally generated Start + Handle content replaces the earlier partial entry with the combined prompt. Last ten entries stored inside the extension sandbox, entirely independent of the clipboard. Paste, delete-one and two-tap clear-history available. Clearing the current text field never erases the Recent archive. QuicKey cannot capture text the user manually types later or detect pressing Send in ChatGPT.
- **Three compact top-right delete controls:** character ⌫, word/FAIREX-command-line ⌫⇤, and clear-generated-text trash icon. Hold either delete icon to repeat sequentially. Clear generated text requires two taps and only proceeds when the currently visible iOS text context matches the keyboard's tracked insertion; no unrestricted host-field wipe.
- **More:** direct role entry and additional documented controls.
- **App icon:** native opaque 1024 × 1024 AppIcon asset created deterministically by the GitHub macOS build step and embedded in the host app.
- **Visual semantics:** roles blue, PR teal, Issues amber, workflows violet, primary actions green, Recent lavender, delete red. Supports iOS light and dark appearance.
- **Safety:** no network access in the keyboard, no automatic submit, no Full Access, and no operation or permission execution. Commands are text only.

## Build and install the unsigned IPA

Repo: https://github.com/Fairex009/QuicKey

1. Open **Actions → Build unsigned QuicKey IPA**, and select the successful **main** build with version `0.2.4`.
2. Under **Artifacts**, download `QuicKey-v0.2.4-unsigned-IPA`; unzip that artifact on Ubuntu to obtain `QuicKey-v0.2.4-unsigned.ipa`.
3. The IPA is **unsigned** by design; it must be signed for your iPhone using your existing free Apple developer account, such as through IPAForge. GitHub Actions does not store or handle Apple credentials.

IPAForge: https://github.com/IPAForge/ipaforge/releases . See its official [Install documentation](https://github.com/IPAForge/ipaforge/blob/main/docs/installing.md) and [install/update flow details](https://github.com/IPAForge/ipaforge/blob/main/docs/install-flows.md).

On Ubuntu with IPAForge already installed:

1. Keep the current QuicKey and SideStore installed on the iPhone; **do not uninstall them**.
2. Plug in the iPhone via a working USB data cable, unlock it, and confirm Developer Mode and Trust if prompted.
3. Start IPAForge, choose the same Apple ID and team that signed the currently installed QuicKey. Use **Install / Preload / your own IPA** to select the unsigned v0.2.4 IPA.
4. Before confirming, inspect IPAForge's plan. It must identify QuicKey as an **upgrade of the existing app** and preserve its **single keyboard extension**, without asking to remove another app or revoke an existing certificate. If it proposes a separate app, stop.
5. Confirm sign/install and wait for IPAForge to report success. On the iPhone, open QuicKey and verify version `0.2.4` in the host/keyboard UI.
6. Open an ordinary text field in Notes or ChatGPT, switch to QuicKey, and test Start, Handle, Recent, all three top-right delete controls, long press and globe switching. Keep **Allow Full Access** disabled.

IPAForge's documented free-account logic counts a same-identity update as a replacement that keeps its existing active-app slot, not an additional app. Different signing team / transformed bundle ID can change that. A free account still requires re-signing / refreshing approximately every **7 days**. Do not assume SideStore can refresh QuicKey while its Remote Pairing issue remains unfixed.

## Acceptance test

1. **Start → CM1 → Start new chat**: exactly `res.cm1`, blank line, `cmd.boot AGENTS.md`, blank line, `pref.mode GOD`, `all.in.one ON`, `cmd.nonstop ON`, blank line, `cmd.refresh system`, `cmd.refresh role`, blank line, `cmd.deep:`.
2. **Handle:** after Start, choose Direct / No role, add PR #160, Issue #159, Issue #6, and Insert. The final message ends with `git.handle PR #160, Issue #159, Issue #6` without duplicating the startup prefix.
3. **Recent:** open, Paste the saved generated prompt into an empty text field, copy an unrelated sentence in another app, and Paste the saved prompt again. Both inserts must match. Clear one entry and verify others remain.
4. Switch Light/Dark Appearance to inspect contrast and selection feedback. Test Delete and Next Keyboard.
5. Confirm QuicKey is the existing updated app, not a second icon, and SideStore remains usable.

## Boundaries and recovery

This repository contains a public, reusable command-entry engine, not the private FAIREX repository's operational data, secrets, or authority. The commands only take effect after the human submits them in the appropriate ChatGPT session.

The previously working v0.1 source remains at commit `3795cf62c8944d37c986c865360acd6c37652f8d`. Do not delete a working installation as a troubleshooting step: deletion can erase local keyboard history and sideloading data. A normal in-place update should preserve sandbox data but that is an on-device acceptance test, not a guarantee.

See `docs/v0.2.2-history.md` and `docs/v0.2.4-color-design.md` for the storage and palette rules.

## v0.2.4 additional acceptance

1. Verify Home Screen QuicKey icon is no longer the generic placeholder. The built app Info.plist must point to `AppIcon` and include a compiled `Assets.car`.
2. Insert Start Chat only, then open Recent immediately: it must contain that generated text. Open another app and copy arbitrary text, return to Recent, and Paste: it must still match.
3. Insert Start Chat, then use Handle with PR/Issue targets. Recent must hold the combined prompt, not only the Handle part. Keep the previous entry after sending the message or clearing the current text field.
4. Tap top-right character delete to erase one grapheme. Hold to repeat. Tap word/command icon to erase a full recognized FAIREX command line or last ordinary word; hold to repeat.
5. Tap trash icon once to arm, twice to clear only the QuicKey-generated text currently at the cursor. It must not delete unrelated surrounding text. Note that iOS may withhold text context: in that case QuicKey conservatively does nothing.
6. Confirm app identity, keyboard extension, no new App ID, no Full Access, and two installed active apps in IPAForge after updating the current QuicKey.
