import Foundation

@main
struct DeleteChecks {
    static func reduced(_ context: String) -> String {
        let drop = DeletePlanner.previousUnitLength(in: context)
        return String(context.dropLast(drop))
    }
    static func main() {
        precondition(reduced("hello world") == "hello ")
        precondition(reduced("hello world   ") == "hello ")
        precondition(reduced("Hello") == "")
        precondition(reduced("res.cm1") == "")
        precondition(reduced("res.cm1\n\ncmd.boot AGENTS.md") == "res.cm1\n")
        precondition(reduced("git.handle PR #160, Issue #159, Issue #6") == "")
        precondition(reduced("normal text\ncmd.refresh system\n") == "normal text")
        precondition(reduced("one 👩‍💻") == "one ")
        precondition(DeletePlanner.previousUnitLength(in: "") == 0)
        let a = "res.cm1\n\ncmd.deep:\ngit.handle PR #160"
        precondition(DeletePlanner.safeClearLength(generated: a, beforeCursor: "unrelated "+a) == a.count)
        precondition(DeletePlanner.matchesGeneratedSuffix(generated: a, beforeCursor: String(a.suffix(25))))
        precondition(!DeletePlanner.matchesGeneratedSuffix(generated: a, beforeCursor: "different text"))
        precondition(DeletePlanner.safeClearLength(generated: a, beforeCursor: nil) == 0)
        print("PASS: word/command deletion, grapheme-safe counts, clear-text guard")
    }
}
