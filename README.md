# QuicKey

**A fast, private keyboard for repeatable commands and text.**

QuicKey helps you compose and insert structured text without repeatedly typing the same setup, commands or references. The current application is an offline iPhone/iPad keyboard for FAIREX workflows. The project is intended to grow into a more broadly customizable command keyboard, with **Android planned for future development**.

QuicKey **inserts text only**. It does not read conversations, send messages, execute commands or grant authority to anything it inserts.

## Platform status

| Platform | Status |
| --- | --- |
| iOS / iPadOS | Implemented as a native app with a custom keyboard extension |
| Android | Planned; no Android build or release yet |

The product direction is cross-platform, but implementation and installation are platform-specific. An Android implementation should be designed and tested on its own merits rather than assuming iOS-specific APIs, storage or signing models.

## What the current keyboard does

- **Start:** compose a role-specific FAIREX new-chat setup.
- **Handle:** build one command referring to multiple pull requests and issues, with selectable role and execution-text prefixes.
- **Quick / More:** insert frequently used text snippets and commands.
- **Recent:** reuse the latest QuicKey-generated insertions without relying on the device clipboard.
- **Edit and preview:** inspect generated text before insertion; use bounded deletion controls that avoid clearing unfamiliar host text.
- **Personalization:** develop adjustable appearance, layout and defaults while keeping the core command-output behavior predictable.

FAIREX is the first supported command vocabulary, **not a restriction on the future product**. Additional command sets or platforms require explicit requirements and tests before they are considered supported.

## Principles

- **User stays in control.** Every inserted string is visible and must be submitted manually in the destination app.
- **Private by default.** No clipboard scraping, background conversation reading, account login, network dependency or automatic submit is needed for the current keyboard.
- **Lean and maintainable.** Prefer local settings and existing build tools over hosted services, duplicate coordination systems or added infrastructure.
- **Safe upgrades.** Preserve existing installation identity, local data and recovery paths; test migrations before replacing working behavior.
- **Verifiable changes.** Track feature scope, decisions, CI evidence and device acceptance in GitHub Issues and pull requests. A successful build is not the same as device acceptance.

## Getting started and development

For the current iOS/iPadOS implementation, see **[iOS setup, unsigned builds and safe updates](docs/ios.md)**. The iOS source lives in `QuicKeyApp/` and `QuicKeyKeyboard/`; `.github/workflows/ios-build.yml` builds and tests an **unsigned** IPA. Signing and installation are separate, user-controlled steps.

Useful references:

- [Development handover and verified baseline](https://github.com/Fairex009/QuicKey/issues/4)
- [Feature and maintenance issues](https://github.com/Fairex009/QuicKey/issues)
- [Historical PRs and test evidence](https://github.com/Fairex009/QuicKey/pulls)
- [iOS keyboard history contract](docs/v0.2.2-history.md) and [visual semantics](docs/v0.2.3-color-design.md)
- [Free signing and refresh investigation](https://github.com/Fairex009/QuicKey/issues/3), kept separate from app feature work

For a change: describe the desired behavior and acceptance criteria in a bounded Issue, implement in a focused branch/PR, run existing regression/build checks, review the diff, and record any human device test before declaring the change fully accepted. GitHub is the durable record; chats are temporary workers.

**Security:** This is a public repository. Never post Apple-account details, device identifiers, provisioning or pairing files, passwords, certificates, private keys, tokens or unredacted personal logs.
