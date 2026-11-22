# QuicKey v0.2.3

An **offline FAIREX command keyboard for iPhone and iPad**. It inserts reusable commands into text fields, without a Mac, paid Apple Developer membership, Full Access, or an extra iPhone sideloading app.

> Status: v0.2.3 source, unsigned IPA, keyboard extension and command/history tests pass in GitHub Actions. Actual in-place upgrade and every control still require acceptance testing on the iPhone. Do not upload Apple passwords, profiles, private keys, pairing files or personal credentials to this public repo.

## Features

- **Start:** pick one of the five FAIREX roles and insert the exact new-chat template, including `cmd.boot AGENTS.md`, `pref.mode GOD`, session toggles, both refresh commands and `cmd.deep:`.
- **Handle:** compose `git.handle PR #160, Issue #159, Issue #6` with any number of mixed PR and Issue targets. Choose Direct, Deep, or Fast+Deep; optionally include the role.
- **Quick:** FAST+DEEP, Deep task, Batch ON, Git Handle prefixes and Refresh.
- **Recent:** up to ten complete QuicKey-generated prompts, independent of copied clipboard text, with one-tap Paste, delete-one, and clear-all confirmation. Recent history is stored within the keyboard extension's private sandbox. It cannot capture manually edited or submitted text from another app.
- **More:** direct role entry and additional documented controls.
- **Visual semantics:** roles blue, PR teal, Issues amber, workflows violet, primary actions green, Recent lavender, delete red. Supports iOS light and dark appearance.
- **Safety:** no network access in the keyboard, no automatic submit, no Full Access, and no operation or permission execution. Commands are text only.

## Build and install the unsigned IPA

Repo: https://github.com/Fairex009/QuicKey

1. Open **Actions → Build unsigned QuicKey IPA**, and select the successful **main** build with version `0.2.3`.
2. Under **Artifacts**, download `QuicKey-v0.2.3-unsigned-IPA`; unzip that artifact on Ubuntu to obtain `QuicKey-v0.2.3-unsigned.ipa`.
3. The IPA is **unsigned** by design; it must be signed for your iPhone using your existing free Apple developer account, such as through IPAForge. GitHub Actions does not store or handle Apple credentials.

IPAForge: https://github.com/IPAForge/ipaforge/releases . See its official [Install documentation](https://github.com/IPAForge/ipaforge/blob/main/docs/installing.md) and [install/update flow details](https://github.com/IPAForge/ipaforge/blob/main/docs/install-flows.md).

On Ubuntu with IPAForge already installed:

1. Keep the current QuicKey and SideStore installed on the iPhone; **do not uninstall them**.
2. Plug in the iPhone via a working USB data cable, unlock it, and confirm Developer Mode and Trust if prompted.
3. Start IPAForge, choose the same Apple ID and team that signed the currently installed QuicKey. Use **Install / Preload / your own IPA** to select the unsigned v0.2.3 IPA.
4. Before confirming, inspect IPAForge's plan. It must identify QuicKey as an **upgrade of the existing app** and preserve its **single keyboard extension**, without asking to remove another app or revoke an existing certificate. If it proposes a separate app, stop.
5. Confirm sign/install and wait for IPAForge to report success. On the iPhone, open QuicKey and verify version `0.2.3` in the host/keyboard UI.
6. Open an ordinary text field in Notes or ChatGPT, switch to QuicKey, and test Start, Handle, Recent, Delete, and globe switching. Keep **Allow Full Access** disabled.

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

See `docs/v0.2.2-history.md` and `docs/v0.2.3-color-design.md` for the storage and palette rules.
