#!/usr/bin/env python3
"""Ubuntu structural smoke check. Xcode and Swift checks run in GitHub Actions."""
from pathlib import Path
import plistlib

root = Path(__file__).resolve().parents[1]
app = plistlib.loads((root / "QuicKeyApp/Info.plist").read_bytes())
ext = plistlib.loads((root / "QuicKeyKeyboard/Info.plist").read_bytes())
config = (root / "project.yml").read_text()
workflow = (root / ".github/workflows/ios-build.yml").read_text()
keyboard = (root / "QuicKeyKeyboard/KeyboardViewController.swift").read_text()
commands = (root / "QuicKeyKeyboard/CommandTemplates.swift").read_text()
tests = (root / "scripts/template_checks.swift").read_text()

assert "PRODUCT_BUNDLE_IDENTIFIER: org.quickey.prototype\n" in config
assert "PRODUCT_BUNDLE_IDENTIFIER: org.quickey.prototype.keyboard\n" in config
assert ext["NSExtension"]["NSExtensionPointIdentifier"] == "com.apple.keyboard-service"
assert ext["NSExtension"]["NSExtensionAttributes"]["RequestsOpenAccess"] is False
assert app["CFBundleShortVersionString"] == ext["CFBundleShortVersionString"] == "0.2.3"
assert app["CFBundleVersion"] == ext["CFBundleVersion"] == "5"
assert "fastDeepPrefix" in commands and "cmd.deep:" in commands
assert "func newChat(" in commands and "func composeMulti(" in commands and "func handle(" in commands
for key in ["quickey-page-", "quickey-role-", "quickey-digit-", "quickey-target-insert", "quickey-start-chat", "quickey-recent-paste-", "quickey-recent-remove-"]:
    assert key in keyboard, key
assert "promptHistory.save(" in keyboard
theme = (root / "QuicKeyKeyboard/KeyboardTheme.swift").read_text()
for tone in [".role", ".pr", ".issue", ".workflow", ".action", ".history", ".danger"]:
    assert tone in keyboard, tone
assert "traitCollectionDidChange" in keyboard
assert "userInterfaceStyle" in theme
assert "textDocumentProxy.insertText" in keyboard
assert "handleInputModeList(from:with:)" in keyboard
assert "QuicKey-v0.2.3-unsigned.ipa" in workflow
assert "swiftc QuicKeyKeyboard/CommandTemplates.swift QuicKeyKeyboard/PromptHistory.swift scripts/template_checks.swift" in workflow
assert "malformed and incomplete targets fail closed" in tests
print("PASS: v0.2.3 source structure, preserved bundle IDs, privacy and test wiring")
print("PENDING: actual CI Swift verification and device testing")
