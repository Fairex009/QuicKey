#!/usr/bin/env python3
"""Linux-executable structural checks; not an iOS build."""
from pathlib import Path
import plistlib
import yaml

root = Path(__file__).resolve().parents[1]
project = yaml.safe_load((root / "project.yml").read_text())
app = plistlib.loads((root / "QuicKeyApp/Info.plist").read_bytes())
ext = plistlib.loads((root / "QuicKeyKeyboard/Info.plist").read_bytes())
workflow = (root / ".github/workflows/ios-build.yml").read_text()
swift = (root / "QuicKeyKeyboard/KeyboardViewController.swift").read_text()

assert project["targets"]["QuicKey"]["type"] == "application"
assert project["targets"]["QuicKeyKeyboard"]["type"] == "app-extension"
assert project["targets"]["QuicKey"]["dependencies"][0] == {
    "target": "QuicKeyKeyboard", "embed": True
}
assert project["targets"]["QuicKey"]["settings"]["base"]["PRODUCT_BUNDLE_IDENTIFIER"] == "org.quickey.prototype"
assert project["targets"]["QuicKeyKeyboard"]["settings"]["base"]["PRODUCT_BUNDLE_IDENTIFIER"] == "org.quickey.prototype.keyboard"
assert ext["NSExtension"]["NSExtensionPointIdentifier"] == "com.apple.keyboard-service"
assert ext["NSExtension"]["NSExtensionAttributes"]["RequestsOpenAccess"] is False
assert ext["NSExtension"]["NSExtensionPrincipalClass"].endswith("KeyboardViewController")
assert app["CFBundlePackageType"] == "APPL"
assert ext["CFBundlePackageType"] == "XPC!"
assert swift.count("Snippet(title:") == 6
assert "textDocumentProxy.insertText(" in swift
assert "textDocumentProxy.deleteBackward()" in swift
assert "handleInputModeList(from:with:)" in swift
assert "runs-on: macos-15" in workflow
assert "CODE_SIGNING_ALLOWED=NO" in workflow
print("PASS: config and six-snippet keyboard source checks.")
print("NOT TESTED: Xcode compilation, signing, IPAForge, physical iPhone.")
