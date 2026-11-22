import Foundation

@main
struct TemplateChecks {
    static func main() {
        func expect(_ actual: String?, _ expected: String, _ name: String) {
            guard actual == expected else {
                fatalError("FAIL \(name)\nactual: \(actual ?? "nil")\nexpected: \(expected)")
            }
            print("PASS: \(name)")
        }

        precondition(CommandRole.allCases.count == 5)
        precondition(CommandTemplates.fastDeepPrefix == "all.in.one ON\ncmd.nonstop ON\n\ncmd.deep:\ngit.handle ")
        expect(CommandTemplates.newChat(role: .cm1),
               "res.cm1\n\ncmd.boot AGENTS.md\n\npref.mode GOD\nall.in.one ON\ncmd.nonstop ON\n\ncmd.refresh system\ncmd.refresh role\n\ncmd.deep:\n",
               "exact CM1 new-chat operator template")
        expect(CommandTemplates.newChat(role: .eng).replacingOccurrences(of: "res.eng", with: "res.cm1"),
               CommandTemplates.newChat(role: .cm1), "role substitution")
        let mix = [
            HandleTarget(kind: .pr, number: "160"),
            HandleTarget(kind: .issue, number: "159"),
            HandleTarget(kind: .issue, number: "6")
        ]
        expect(CommandTemplates.handle(mix),
               "git.handle PR #160, Issue #159, Issue #6", "mixed targets canonical punctuation")
        expect(CommandTemplates.composeMulti(role: .cm1, targets: mix, style: .direct, includeRole: false),
               "git.handle PR #160, Issue #159, Issue #6", "handle-only")
        expect(CommandTemplates.composeMulti(role: .eng, targets: mix, style: .fastDeep, includeRole: true),
               "res.eng\n\nall.in.one ON\ncmd.nonstop ON\n\ncmd.deep:\ngit.handle PR #160, Issue #159, Issue #6",
               "eng fast deep mixed targets")
        expect(CommandTemplates.compose(role: .custodian, kind: .issue, number: "159", style: .direct),
               "res.custodian\n\ngit.handle Issue #159", "backward compatible single issue")
        expect(CommandTemplates.composeMulti(role: .cm1, targets: [HandleTarget(kind: .pr, number: "10")],
                                             style: .deep, includeRole: true),
               "res.cm1\n\ncmd.deep:\ngit.handle PR #10", "deep PR")
        precondition(CommandTemplates.handle([]) == nil)
        for invalid in ["", "0", "01", "12a", "-3", "1 2", "۳"] {
            precondition(CommandTemplates.handle([HandleTarget(kind: .pr, number: invalid)]) == nil)
        }
        expect(CommandTemplates.handle([HandleTarget(kind: .pr, number: "1234567890")]),
               "git.handle PR #1234567890", "no arbitrary 8-digit limit")
        print("PASS: malformed and incomplete targets fail closed")
    }
}
