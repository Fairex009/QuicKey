import Foundation

/// Exactly what QuicKey generated and inserted; never captured from another app.
struct RecentPrompt: Codable, Equatable {
    let id: UUID
    let text: String
    let createdAt: Date
}

/// Independent of the iPhone clipboard, with no network or Full Access requirement.
struct PromptHistory {
    static let maximumEntries = 10
    private static let key = "QuicKeyPrivatePromptHistoryV1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func all() -> [RecentPrompt] {
        guard let data = defaults.data(forKey: Self.key),
              let stored = try? JSONDecoder().decode([RecentPrompt].self, from: data) else {
            return []
        }
        return Array(stored.prefix(Self.maximumEntries))
    }

    @discardableResult
    func save(_ exactText: String) -> [RecentPrompt] {
        guard !exactText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              exactText.utf8.count <= 16_384 else { return all() }
        var entries = all().filter { $0.text != exactText }
        entries.insert(RecentPrompt(id: UUID(), text: exactText, createdAt: Date()), at: 0)
        entries = Array(entries.prefix(Self.maximumEntries))
        persist(entries)
        return entries
    }

    /// Atomic history replacement while the user composes one prompt.
    /// Retains the original v0.2.3 UserDefaults key for in-place upgrades.
    @discardableResult
    func saveReplacing(previous: String?, with current: String) -> [RecentPrompt] {
        guard !current.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              current.utf8.count <= 16_384 else { return all() }
        var entries = all().filter { $0.text != current && $0.text != previous }
        entries.insert(RecentPrompt(id: UUID(), text: current, createdAt: Date()), at: 0)
        entries = Array(entries.prefix(Self.maximumEntries))
        persist(entries)
        return entries
    }

    func removeText(_ text: String) {
        persist(all().filter { $0.text != text })
    }

    func remove(id: UUID) {
        persist(all().filter { $0.id != id })
    }

    func clear() {
        defaults.removeObject(forKey: Self.key)
    }

    private func persist(_ entries: [RecentPrompt]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        defaults.set(data, forKey: Self.key)
    }
}
