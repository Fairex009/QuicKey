# QuicKey development instructions

This file is the durable workflow contract for contributors and temporary AI development chats. Read the live GitHub repository, relevant open Issue/PR and this file before app work. GitHub Issues/PRs and code are the source of truth; chats are temporary workers. Keep the project lean, offline and extendable beyond iOS to future Android.

## Every UI/feature version: preview before phone installation

**Always include a working, interactive preview of the latest version being proposed or built, directly in the ChatGPT conversation, before suggesting installation on a physical device.** This is a required deliverable, not an optional screenshot.

- Match the latest reviewed branch/commit and version in the preview's title and describe exactly which user actions can be tried. Include the changed UI plus enough surrounding screens to test navigation and key interactions. For Settings this includes text scaling, tab order, role defaults and the Start→Handle flow.
- Prefer a responsive, clickable in-chat prototype. Where the native app cannot run inside ChatGPT, clearly label it **interactive simulation**, not the compiled app. Never claim that its success proves Swift behavior, OS permissions, installation, signing, actual screen metrics or native iPhone acceptance.
- Keep the preview honest: distinguish simulated UI, validated pure logic, macOS compile/CI, and human device testing. Don't invent a passed test. A static image alone is insufficient when interactive controls can be represented.
- Before delivery, audit the actual code for bugs and regressions. Fix bounded defects in the feature PR, add regression tests, and run available checks. Present the preview **after** those fixes so it reflects the proposed version; link the exact source ref/PR.
- The human should be able to try the preview and request changes before deciding whether to install. Record actionable preview feedback and decisions back to the feature Issue/PR so they survive new chats.
- Keep the preview as a conversation deliverable; do **not** add a second permanent web app, hosting service, build platform, or large mockup framework merely to satisfy this rule. Only version-control preview code if it becomes necessary for real tests and is explicitly scoped.

## Engineering and release boundaries

- Current implementation: native iOS/iPadOS app and offline keyboard. Android is planned, not implemented. Avoid platform-specific claims in the root README; use focused docs for platform procedures.
- Never change working app identity, host/extension IDs, history keys/data, signing team or Full Access OFF without explicit approved requirements. No automatic submit or command execution; text insertion only.
- Preserve working installations. Build unsigned IPAs via existing GitHub Actions; Apple signing/refresh is managed separately in [Issue #3](https://github.com/Fairex009/QuicKey/issues/3). Do not require an Apple account or signing credentials in GitHub or ChatGPT.
- For bounded feature work: Issue → branch/PR → source review and automated tests → **interactive in-chat preview and feedback** → reviewed unsigned build → human-controlled same-identity in-place device acceptance → merge/release decision recorded in GitHub.
- CI PASS is not a substitute for physical-device acceptance. Record PR SHA, artifact and explicit limitations at checkpoints. [Issue #4](https://github.com/Fairex009/QuicKey/issues/4) is the long-running development handover; use dedicated Issues for features.
