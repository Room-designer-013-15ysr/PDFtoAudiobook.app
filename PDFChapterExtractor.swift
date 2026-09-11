import Foundation
import PDFKit

class PDFChapterExtractor {
    
    /// Parses a PDF file from a given local URL and attempts to split it into chapters.
    static func extractChapters(from pdfURL: URL) -> [Chapter] {
        guard let document = PDFDocument(url: pdfURL) else {
            return []
        }
        
        var fullTextByPage: [String] = []
        let pageCount = document.pageCount
        
        for i in 0..<pageCount {
            if let page = document.page(at: i), let pageText = page.string {
                fullTextByPage.append(pageText)
            }
        }
        
        let fullText = fullTextByPage.joined(separator: "\n\n")
        return parseChapters(from: fullText)
    }
    
    /// Heuristic parser searching for common chapter heading markers.
    private static func parseChapters(from text: String) -> [Chapter] {
        // Regex pattern to match headings like "Chapter 1", "CHAPTER IV", "Chapter One", etc.
        let chapterPattern = "(?i)(?:^|\\n\\s*)\\b(chapter|prologue|epilogue)\\b\\s+([0-9]+|[ivxlcdm]+|[a-z]+)?.*"
        
        guard let regex = try? NSRegularExpression(pattern: chapterPattern, options: []) else {
            return [Chapter(number: 1, title: "Full Book", text: text)]
        }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: range)
        
        if matches.isEmpty {
            // Fallback if no explicit chapter headings are detected
            return [Chapter(number: 1, title: "Full Book", text: text)]
        }
        
        var chapters: [Chapter] = []
        
        for index in 0..<matches.count {
            let match = matches[index]
            let currentRange = Range(match.range, in: text)!
            
            // Extract title heading line
            let rawTitle = String(text[currentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Calculate text body bounds
            let startIndex = currentRange.lowerBound
            let endIndex: String.Index
            
            if index + 1 < matches.count {
                let nextMatch = matches[index + 1]
                endIndex = Range(nextMatch.range, in: text)!.lowerBound
            } else {
                endIndex = text.endIndex
            }
            
            let chapterText = String(text[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            chapters.append(
                Chapter(
                    number: index + 1,
                    title: rawTitle.isEmpty ? "Chapter \(index + 1)" : rawTitle,
                    text: chapterText
                )
            )
        }
        
        return chapters
    }
}
