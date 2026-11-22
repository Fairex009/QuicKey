import Foundation

/// Pure text heuristics for safe, predictable deletion from a host text field.
/// One unit is a FAIREX command line, otherwise the last whitespace-delimited word.
enum DeletePlanner {
    static func previousUnitLength(in context: String) -> Int {
        let chars = Array(context)
        guard !chars.isEmpty else { return 0 }
        var significantEnd = chars.count
        while significantEnd > 0 && chars[significantEnd - 1].isWhitespace {
            significantEnd -= 1
        }
        if significantEnd == 0 { return chars.count }

        let meaningful = String(chars[..<significantEnd])
        let lineStart = meaningful.lastIndex(of: "\n")
            .map { meaningful.distance(from: meaningful.startIndex, to: meaningful.index(after: $0)) } ?? 0
        let currentLine = String(chars[lineStart..<significantEnd])
            .trimmingCharacters(in: .whitespaces)
        let knownCommand = ["res.", "cmd.", "pref.", "git.handle", "all.in.one"]
            .contains(where: { currentLine.hasPrefix($0) })

        if knownCommand {
            // Remove the command line, its trailing line breaks and the
            // preceding delimiter, without touching any earlier line contents.
            return chars.count - lineStart + (lineStart > 0 ? 1 : 0)
        }

        var start = significantEnd
        while start > 0 && !chars[start - 1].isWhitespace {
            start -= 1
        }
        return chars.count - start
    }

    /// iOS may provide only a truncated prefix context, so match the
    /// overlap of our generated suffix with the available text.
    static func matchesGeneratedSuffix(generated: String, beforeCursor: String?) -> Bool {
        guard !generated.isEmpty, let context = beforeCursor, !context.isEmpty else {
            return false
        }
        let overlap = min(Array(generated).count, Array(context).count)
        guard overlap >= min(8, Array(generated).count) else { return false }
        return Array(generated).suffix(overlap).elementsEqual(Array(context).suffix(overlap))
    }

    /// Only the verified overlap may be deleted. Limit each pass to 64
    /// characters, then re-check iOS context before deleting any more.
    static func safeClearLength(generated: String, beforeCursor: String?) -> Int {
        guard let context = beforeCursor,
              matchesGeneratedSuffix(generated: generated, beforeCursor: context) else {
            return 0
        }
        return min(Array(generated).count, Array(context).count, 64)
    }
}

/// Include the preceding generated Start template when the current host
/// cursor still follows that same text; otherwise show only the Handle command.
enum HandlePreviewText {
    static func composed(handle: String?, generated: String,
                         sameDocument: Bool, beforeCursor: String?) -> String? {
        guard let handle else { return nil }
        if sameDocument && DeletePlanner.matchesGeneratedSuffix(
            generated: generated, beforeCursor: beforeCursor) {
            return generated + handle
        }
        return handle
    }
}
