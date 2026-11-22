import Foundation

/// Keyboard-private settings. No App Group, Full Access or shared container.
enum KeyboardTab: String, CaseIterable, Codable {
    case start, handle, quick, recent, more

    var title: String {
        switch self {
        case .start: return "Start"
        case .handle: return "Handle"
        case .quick: return "Quick"
        case .recent: return "Recent"
        case .more: return "More"
        }
    }
}

enum KeyboardFontSize: String, CaseIterable, Codable {
    case small, normal, large

    var title: String { rawValue.capitalized }

    var multiplier: Double {
        switch self {
        case .small: return 0.88
        case .normal: return 1.0
        case .large: return 1.16
        }
    }
}

/// Versioned storage isolated from the pre-existing Recent history schema.
struct KeyboardPreferences: Codable, Equatable {
    static let storageKey = "QuicKeyKeyboardPreferencesV1"

    var fontSize: KeyboardFontSize = .normal
    var tabOrder: [KeyboardTab] = KeyboardTab.allCases
    var includeRoleByDefault = true

    init() {}

    private enum CodingKeys: String, CodingKey {
        case fontSize, tabOrder, includeRoleByDefault
    }

    // Missing fields in a future/older settings payload use safe defaults.
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fontSize = (try? values.decode(KeyboardFontSize.self, forKey: .fontSize)) ?? .normal
        let proposed = (try? values.decode([KeyboardTab].self, forKey: .tabOrder)) ?? KeyboardTab.allCases
        tabOrder = Self.validatedOrder(proposed)
        includeRoleByDefault =
            (try? values.decode(Bool.self, forKey: .includeRoleByDefault)) ?? true
    }

    static func validatedOrder(_ order: [KeyboardTab]) -> [KeyboardTab] {
        let canonical = KeyboardTab.allCases
        return order.count == canonical.count && Set(order).count == canonical.count
            ? order : canonical
    }

    static func load(defaults: UserDefaults = .standard) -> KeyboardPreferences {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(KeyboardPreferences.self, from: data)
        else { return KeyboardPreferences() }
        return decoded
    }

    func save(defaults: UserDefaults = .standard) {
        var normalized = self
        normalized.tabOrder = Self.validatedOrder(tabOrder)
        if let data = try? JSONEncoder().encode(normalized) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }

    /// Move the tab by one slot; edge taps are harmless.
    @discardableResult
    mutating func move(_ tab: KeyboardTab, by offset: Int) -> Bool {
        guard abs(offset) == 1,
              let start = tabOrder.firstIndex(of: tab),
              tabOrder.indices.contains(start + offset) else { return false }
        tabOrder.swapAt(start, start + offset)
        return true
    }
}
