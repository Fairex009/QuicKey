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
        let fresh = CommandTemplates.newChat(role: .custodian)
        precondition(StartHandleContinuation.isValid(expectedStart: fresh, generated: fresh,
                   sameDocument: true, beforeCursor: fresh))
        precondition(StartHandleContinuation.isValid(expectedStart: fresh, generated: fresh,
                   sameDocument: true, beforeCursor: String(fresh.suffix(35))))
        let chained = fresh + "git.handle PR #160" + "git.handle Issue #159"
        precondition(StartHandleContinuation.isValid(expectedStart: chained, generated: chained,
                   sameDocument: true, beforeCursor: String(chained.suffix(35))))
        precondition(!StartHandleContinuation.isValid(expectedStart: fresh,
                    generated: fresh + "extra", sameDocument: true, beforeCursor: fresh + "extra"))
        precondition(!StartHandleContinuation.isValid(expectedStart: fresh,
                    generated: fresh, sameDocument: false, beforeCursor: fresh))
        precondition(!StartHandleContinuation.isValid(expectedStart: fresh,
                    generated: fresh, sameDocument: true, beforeCursor: "Unrelated text"))
        precondition(!StartHandleContinuation.isValid(expectedStart: nil,
                    generated: fresh, sameDocument: true, beforeCursor: fresh))
        let quick = "cmd.refresh system"
        let continued = StartHandleContinuation.nextExpected(
            expectedStart: fresh, generated: fresh, sameDocument: true,
            beforeCursor: fresh, inserted: quick)
        precondition(continued == fresh + quick)
        let second = StartHandleContinuation.nextExpected(
            expectedStart: continued, generated: continued ?? "",
            sameDocument: true, beforeCursor: String((fresh + quick).suffix(38)),
            inserted: "git.handle Issue #6")
        precondition(second == fresh + quick + "git.handle Issue #6")
        precondition(StartHandleContinuation.nextExpected(
            expectedStart: fresh, generated: fresh, sameDocument: false,
            beforeCursor: fresh, inserted: quick) == nil)
        precondition(StartHandleContinuation.nextExpected(
            expectedStart: fresh, generated: fresh, sameDocument: true,
            beforeCursor: "Unrelated context", inserted: quick) == nil)
        print("PASS: Start→Handle continuation and intervening Quick/Recent insertion")
        print("PASS: Start→Handle continuation guard and standalone-default fallback")
        print("PASS: full multiline Handle preview, combined Start+Handle, safe fallback")

        print("PASS: word/command deletion, grapheme-safe counts, clear-text guard")
    }
}
