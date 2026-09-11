import Foundation
import AVFoundation

class ChapterSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var completionHandler: ((URL?) -> Void)?
    private var outputFileURL: URL?
    
    /// Renders a given chapter text to an uncompressed audio file (.caf) on disk.
    func renderChapterToAudio(
        chapter: Chapter,
        voice: AVSpeechSynthesisVoice,
        completion: @escaping (URL?) -> Void
    ) {
        self.completionHandler = completion
        
        let utterance = AVSpeechUtterance(string: chapter.text)
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("Chapter_\(chapter.id.uuidString).caf")
        self.outputFileURL = fileURL
        
        // Remove existing file if present
        try? FileManager.default.removeItem(at: fileURL)
        
        var audioFile: AVAudioFile?
        
        synthesizer.write(utterance) { [weak self] buffer in
            guard let self = self else { return }
            
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else { return }
            
            if pcmBuffer.frameLength == 0 {
                // End of speech synthesis stream
                DispatchQueue.main.async {
                    self.completionHandler?(self.outputFileURL)
                }
            } else {
                // Create or append to PCM audio file
                do {
                    if audioFile == nil {
                        audioFile = try AVAudioFile(
                            forWriting: fileURL,
                            settings: pcmBuffer.format.settings,
                            commonFormat: pcmBuffer.format.commonFormat,
                            interleaved: pcmBuffer.format.isInterleaved
                        )
                    }
                    try audioFile?.write(from: pcmBuffer)
                } catch {
                    print("Error writing audio buffer: \(error.localizedDescription)")
                }
            }
        }
    }
}
