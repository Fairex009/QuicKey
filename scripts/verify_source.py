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
assert app["CFBundleShortVersionString"] == ext["CFBundleShortVersionString"]
assert app["CFBundleVersion"] == ext["CFBundleVersion"]
assert "fastDeepPrefix" in commands and "cmd.deep:" in commands
assert "func newChat(" in commands and "func composeMulti(" in commands and "func handle(" in commands
for key in ["quickey-page-", "quickey-role-", "quickey-digit-", "quickey-target-insert", "quickey-start-chat", "quickey-recent-paste-", "quickey-recent-remove-"]:
    assert key in keyboard, key
assert (root / "QuicKeyKeyboard/KeyboardPreferences.swift").is_file()
assert (root / "scripts/preferences_checks.swift").is_file()
assert 'preferences.tabOrder.map' in keyboard
assert 'quickey-settings-open' in keyboard and 'quickey-settings-done' in keyboard
assert 'case .settings: buildSettingsPage()' in keyboard
assert 'preferences.includeRoleByDefault' in keyboard
assert 'preferences.fontSize.multiplier' in keyboard
assert 'isPendingStartContinuation()' in keyboard
assert "QuicKeyKeyboard/KeyboardPreferences.swift scripts/preferences_checks.swift" in workflow
assert "promptHistory.saveReplacing(" in keyboard
assert "insertTracked(" in keyboard
assert "quickey-delete-unit" in keyboard and "quickey-clear-generated" in keyboard
assert "UITextView()" in keyboard and "isScrollEnabled = true" in keyboard
assert "quickey-preview-toggle" in keyboard and "scrollRangeToVisible" in keyboard
assert "HandlePreviewText.composed(" in keyboard
assert "preview.numberOfLines = 5" not in keyboard
assert "ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon" in config
theme = (root / "QuicKeyKeyboard/KeyboardTheme.swift").read_text()
for tone in [".role", ".pr", ".issue", ".workflow", ".action", ".history", ".danger"]:
    assert tone in keyboard, tone
assert "traitCollectionDidChange" in keyboard
assert "userInterfaceStyle" in theme
assert (root / "QuicKeyApp/Assets.xcassets/AppIcon.appiconset/Contents.json").is_file()
assert (root / "scripts/generate_app_icon.swift").is_file()
assert (root / "scripts/delete_checks.swift").is_file()
assert "proxy.insertText(text)" in keyboard
assert "while !remaining.isEmpty" in keyboard
assert "handleInputModeList(from:with:)" in keyboard
assert "QuicKey-unsigned.ipa" in workflow
assert "swiftc QuicKeyKeyboard/CommandTemplates.swift QuicKeyKeyboard/PromptHistory.swift scripts/template_checks.swift" in workflow
assert "malformed and incomplete targets fail closed" in tests
print("PASS: iOS source structure, preserved bundle IDs, privacy and test wiring")
print("PENDING: actual CI Swift verification and device testing")
