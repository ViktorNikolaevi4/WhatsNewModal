
import Foundation
import MarkdownUI

enum MarkdownLoader {
    static func load(named: String) -> String {
        guard let url = Bundle.main.url(forResource: named, withExtension: "md") else {
            return "*(Файл `\(named).md` не найден в бандле приложения.)*"
        }
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            return "*(Не удалось прочитать `\(named).md`: \(error.localizedDescription))*"
        }
    }
    static func extractH1AndBody(from markdown: String) -> (title: String?, body: String) {
        var title: String? = nil
        var bodyLines: [String] = []
        let lines = markdown.components(separatedBy: .newlines)

        var skippedHeading = false
        for line in lines {
            if !skippedHeading {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("# ") {
                    var rawTitle = String(trimmed.dropFirst(2))
                    while rawTitle.hasSuffix("#") {
                        rawTitle.removeLast()
                    }
                    title = rawTitle.trimmingCharacters(in: .whitespaces)
                    skippedHeading = true
                }
            }
            bodyLines.append(line)
        }
        return (title, bodyLines.joined(separator: "\n"))
    }
}
