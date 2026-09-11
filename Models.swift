import Foundation

struct Chapter: Identifiable, Codable {
    let id: UUID
    let number: Int
    let title: String
    let text: String
    var audioFileURL: URL?
    
    init(id: UUID = UUID(), number: Int, title: String, text: String, audioFileURL: URL? = nil) {
        self.id = id
        self.number = number
        self.title = title
        self.text = text
        self.audioFileURL = audioFileURL
    }
}

struct Book: Identifiable, Codable {
    let id: UUID
    let title: String
    let author: String
    var chapters: [Chapter]
    
    init(id: UUID = UUID(), title: String, author: String = "Unknown Author", chapters: [Chapter]) {
        self.id = id
        self.title = title
        self.author = author
        self.chapters = chapters
    }
}
