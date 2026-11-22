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
        let longText = String(repeating: "cmd.refresh system\n", count: 30)
        precondition(DeletePlanner.safeClearLength(generated: longText,
                           beforeCursor: String(longText.suffix(40))) == 40)
        precondition(DeletePlanner.safeClearLength(generated: longText,
                           beforeCursor: "unrelated") == 0)
        precondition(DeletePlanner.safeClearLength(generated: longText,
                           beforeCursor: longText) == 64)
        let startup = "res.cm1\n\ncmd.boot AGENTS.md\n\ncmd.deep:\n"
        let mixed = "git.handle PR #160, Issue #159, Issue #6"
        precondition(HandlePreviewText.composed(handle: mixed, generated: startup,
                                               sameDocument: true, beforeCursor: startup) ==
                     startup + mixed)
        precondition(HandlePreviewText.composed(handle: mixed, generated: startup,
                                               sameDocument: false, beforeCursor: startup) == mixed)
        precondition(HandlePreviewText.composed(handle: mixed, generated: startup,
                                               sameDocument: true, beforeCursor: "Unrelated host text") == mixed)
        precondition(HandlePreviewText.composed(handle: nil, generated: startup,
                                               sameDocument: true, beforeCursor: startup) == nil)
        precondition(!DeletePlanner.matchesGeneratedSuffix(generated: startup, beforeCursor: "\n"))
        print("PASS: full multiline Handle preview, combined Start+Handle, safe fallback")

        print("PASS: word/command deletion, grapheme-safe counts, clear-text guard")
    }
}
