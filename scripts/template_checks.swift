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
        // Persist exact generated prompts in a keyboard-private UserDefaults suite.
        let suiteName = "QuicKeyHistoryTests." + UUID().uuidString
        guard let isolated = UserDefaults(suiteName: suiteName) else {
            fatalError("Unable to create history test sandbox")
        }
        defer { isolated.removePersistentDomain(forName: suiteName) }
        let recent = PromptHistory(defaults: isolated)
        let whole = CommandTemplates.newChat(role: .cm1) + CommandTemplates.handle(mix)!
        precondition(recent.all().isEmpty)
        recent.save(whole)
        precondition(recent.all()[0].text == whole)
        precondition(PromptHistory(defaults: isolated).all()[0].text == whole)

        // Simulate unrelated clipboard data: saved history must not depend on it.
        isolated.set("Other copied text", forKey: "UnrelatedClipboardSimulation")
        precondition(recent.all()[0].text == whole)
        recent.save("git.handle PR #160")
        recent.save(whole)
        precondition(recent.all().count == 2)
        precondition(recent.all()[0].text == whole)
        for i in 1...12 { recent.save("git.handle Issue #\(i)") }
        precondition(recent.all().count == 10)
        precondition(recent.all()[0].text == "git.handle Issue #12")
        precondition(recent.all().last!.text == "git.handle Issue #3")
        let removed = recent.all().last!.id
        recent.remove(id: removed)
        precondition(recent.all().count == 9)
        precondition(!recent.all().contains(where: { $0.id == removed }))
        recent.save("")
        precondition(recent.all().count == 9)
        recent.clear()
        precondition(recent.all().isEmpty)
        print("PASS: private history persistence, deduplication, deletion, limit, clipboard independence")

        print("PASS: malformed and incomplete targets fail closed")
    }
}
