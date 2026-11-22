import Foundation

/// FAIREX-compatible text generation only. No commands are executed.
enum CommandRole: String, CaseIterable {
    case custodian, primary, eng, cm1, cockpit

    var label: String {
        switch self {
        case .custodian: return "Cust."
        case .primary: return "Primary"
        case .eng: return "ENG"
        case .cm1: return "CM1"
        case .cockpit: return "Cockpit"
        }
    }

    var command: String { "res.\(rawValue)" }
}

enum HandleKind: String, CaseIterable {
    case pr, issue

    var command: String { self == .pr ? "PR" : "Issue" }
}

enum HandleStyle: String, CaseIterable {
    case direct, deep, fastDeep

    var label: String {
        switch self {
        case .direct: return "Direct"
        case .deep: return "Deep"
        case .fastDeep: return "Fast+Deep"
        }
    }
}

struct CommandTemplates {
    // This intentionally ends with a space. The operator must finish git.handle.
    static let fastDeepPrefix = "all.in.one ON\ncmd.nonstop ON\n\ncmd.deep:\ngit.handle "
    static let batchOn = "all.in.one ON\ncmd.nonstop ON\n\n"

    /// Returns nil rather than inserting a malformed/unfinished GitHub handle.
    static func compose(role: CommandRole, kind: HandleKind,
                        number: String, style: HandleStyle) -> String? {
        guard !number.isEmpty, number.count <= 8,
              number.first != "0",
              number.allSatisfy({ $0 >= "0" && $0 <= "9" }) else { return nil }

        let handle = "git.handle \(kind.command) #\(number)"
        switch style {
        case .direct:
            return "\(role.command)\n\(handle)"
        case .deep:
            return "\(role.command)\n\ncmd.deep:\n\(handle)"
        case .fastDeep:
            return "\(role.command)\n\nall.in.one ON\ncmd.nonstop ON\n\ncmd.deep:\n\(handle)"
        }
    }
}
