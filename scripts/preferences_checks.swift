import Foundation

@main
struct PreferencesChecks {
    static func main() {
        let suite = "QuicKeyPreferencesTests." + UUID().uuidString
        guard let isolated = UserDefaults(suiteName: suite) else {
            fatalError("Missing isolated preferences suite")
        }
        defer { isolated.removePersistentDomain(forName: suite) }

        var pref = KeyboardPreferences.load(defaults: isolated)
        precondition(pref.fontSize == .normal)
        precondition(pref.tabOrder == [.start, .handle, .quick, .recent, .more])
        precondition(pref.includeRoleByDefault)
        precondition(KeyboardFontSize.small.multiplier < KeyboardFontSize.normal.multiplier)
        precondition(KeyboardFontSize.normal.multiplier < KeyboardFontSize.large.multiplier)

        precondition(!pref.move(.start, by: -1))
        precondition(!pref.move(.more, by: 1))
        precondition(pref.move(.more, by: -1))
        precondition(pref.move(.handle, by: -1))
        precondition(pref.tabOrder == [.handle, .start, .quick, .more, .recent])
        precondition(Set(pref.tabOrder) == Set(KeyboardTab.allCases))
        precondition(!pref.move(.start, by: 2))

        pref.fontSize = .large
        pref.includeRoleByDefault = false
        pref.save(defaults: isolated)
        let restored = KeyboardPreferences.load(defaults: isolated)
        precondition(restored == pref)

        var invalid = restored
        invalid.tabOrder = [.start, .start, .handle, .recent, .more]
        invalid.save(defaults: isolated)
        precondition(KeyboardPreferences.load(defaults: isolated).tabOrder == KeyboardTab.allCases)

        isolated.set(Data("{\"tabOrder\":[\"start\"],\"includeRoleByDefault\":false}".utf8),
                     forKey: KeyboardPreferences.storageKey)
        let partiallyValid = KeyboardPreferences.load(defaults: isolated)
        precondition(partiallyValid.tabOrder == KeyboardTab.allCases)
        precondition(partiallyValid.fontSize == .normal)
        precondition(!partiallyValid.includeRoleByDefault)

        isolated.set(Data("{broken json".utf8), forKey: KeyboardPreferences.storageKey)
        precondition(KeyboardPreferences.load(defaults: isolated) == KeyboardPreferences())

        // Existing Recent data and legacy last-role selection must be untouched.
        isolated.set("cm1", forKey: "QuicKeyLastRole")
        isolated.set(Data("old history".utf8), forKey: "QuicKeyPrivatePromptHistoryV1")
        pref.save(defaults: isolated)
        precondition(isolated.string(forKey: "QuicKeyLastRole") == "cm1")
        precondition(isolated.data(forKey: "QuicKeyPrivatePromptHistoryV1") ==
                     Data("old history".utf8))
        print("PASS: settings defaults, font choices, reorder, persistence, corruption fallback and history isolation")
    }
}
