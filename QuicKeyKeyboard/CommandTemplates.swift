import Foundation

/// Text only: inserting a FAIREX message is never executing or submitting it.
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

struct HandleTarget: Equatable {
    let kind: HandleKind
    let number: String
}

enum CommandTemplates {
    static let fastDeepPrefix = "all.in.one ON\ncmd.nonstop ON\n\ncmd.deep:\ngit.handle "
    static let batchOn = "all.in.one ON\ncmd.nonstop ON\n\n"

    /// Exact operator-provided fresh-chat template; role is substituted locally.
    static func newChat(role: CommandRole) -> String {
        "\(role.command)\n\ncmd.boot AGENTS.md\n\npref.mode GOD\nall.in.one ON\ncmd.nonstop ON\n\ncmd.refresh system\ncmd.refresh role\n\ncmd.deep:\n"
    }

    static func isValidNumber(_ value: String) -> Bool {
        !value.isEmpty && value.first != "0" &&
        value.unicodeScalars.allSatisfy({ $0.value >= 48 && $0.value <= 57 })
    }

    /// Handles any positive integer text without an arbitrary eight-digit cap.
    /// The grammar is "git.handle PR #160, Issue #159, Issue #6".
    static func handle(_ targets: [HandleTarget]) -> String? {
        guard !targets.isEmpty && targets.allSatisfy({ isValidNumber($0.number) }) else { return nil }
        let arguments = targets.map { "\($0.kind.command) #\($0.number)" }.joined(separator: ", ")
        return "git.handle \(arguments)"
    }

    /// Composes a role-aware, optionally role-free, multi-target command.
    static func composeMulti(role: CommandRole, targets: [HandleTarget],
                             style: HandleStyle, includeRole: Bool) -> String? {
        guard let handleText = handle(targets) else { return nil }
        let rolePrefix = includeRole ? "\(role.command)\n\n" : ""
        switch style {
        case .direct: return rolePrefix + handleText
        case .deep: return rolePrefix + "cmd.deep:\n" + handleText
        case .fastDeep:
            return rolePrefix + "all.in.one ON\ncmd.nonstop ON\n\ncmd.deep:\n" + handleText
        }
    }

    /// Backwards-compatible single-target composer.
    static func compose(role: CommandRole, kind: HandleKind,
                        number: String, style: HandleStyle) -> String? {
        composeMulti(role: role, targets: [HandleTarget(kind: kind, number: number)],
                     style: style, includeRole: true)
    }
}
