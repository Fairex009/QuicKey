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
        expect(CommandTemplates.compose(role: .eng, kind: .pr, number: "160", style: .fastDeep),
               "res.eng\n\nall.in.one ON\ncmd.nonstop ON\n\ncmd.deep:\ngit.handle PR #160", "eng fast deep")
        expect(CommandTemplates.compose(role: .custodian, kind: .issue, number: "159", style: .direct),
               "res.custodian\ngit.handle Issue #159", "custodian direct issue")
        expect(CommandTemplates.compose(role: .cm1, kind: .pr, number: "10", style: .deep),
               "res.cm1\n\ncmd.deep:\ngit.handle PR #10", "cm1 deep")
        precondition(CommandTemplates.compose(role: .eng, kind: .pr, number: "", style: .direct) == nil)
        precondition(CommandTemplates.compose(role: .eng, kind: .pr, number: "0", style: .direct) == nil)
        precondition(CommandTemplates.compose(role: .eng, kind: .pr, number: "12a", style: .direct) == nil)
        precondition(CommandTemplates.compose(role: .eng, kind: .pr, number: "012", style: .direct) == nil)
        precondition(CommandTemplates.compose(role: .eng, kind: .pr, number: "123456789", style: .direct) == nil)
        print("PASS: reject malformed/incomplete targets")
    }
}
