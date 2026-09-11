import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var books: [Book] = []
    @State private var selectedBook: Book?
    @State private var selectedVoice: AVSpeechSynthesisVoice = AVSpeechSynthesisVoice(language: "en-US") ?? AVSpeechSynthesisVoice.speechVoices().first!
    @State private var isImporting = false
    @State private var isSynthesizing = false

    let availableVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en") }

    var body: some View {
        NavigationView {
            VStack {
                if books.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.accentColor)
                        Text("No Audiobooks Yet")
                            .font(.title2)
                            .bold()
                        Text("Import a PDF ebook to convert it into a chapter-by-chapter audiobook.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    List {
                        Section(header: Text("Select Narrator")) {
                            Picker("Voice", selection: $selectedVoice) {
                                ForEach(availableVoices, id: \.identifier) { voice in
                                    Text("\(voice.name) (\(voice.language))")
                                        .tag(voice)
                                }
                            }
                        }

                        Section(header: Text("Your Audiobooks")) {
                            ForEach(books) { book in
                                NavigationLink(destination: BookDetailView(book: book, voice: selectedVoice)) {
                                    VStack(alignment: .leading) {
                                        Text(book.title)
                                            .font(.headline)
                                        Text("\(book.chapters.count) chapters")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }

                Button(action: { isImporting = true }) {
                    Label("Import PDF Ebook", systemImage: "doc.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("PDF Audiobook")
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                handlePDFImport(result: result)
            }
        }
    }

    private func handlePDFImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            let title = url.deletingPathExtension().lastPathComponent
            let chapters = PDFChapterExtractor.extractChapters(from: url)
            let newBook = Book(title: title, chapters: chapters)
            books.append(newBook)

        case .failure(let error):
            print("Import failed: \(error.localizedDescription)")
        }
    }
}

struct BookDetailView: View {
    let book: Book
    let voice: AVSpeechSynthesisVoice

    var body: some View {
        List {
            Section(header: Text("Chapters")) {
                ForEach(book.chapters) { chapter in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(chapter.title)
                                .font(.headline)
                            Text("Chapter \(chapter.number)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "play.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle(book.title)
    }
}
