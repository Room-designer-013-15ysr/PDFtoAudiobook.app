// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PDFToAudiobook",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "PDFToAudiobook",
            targets: ["PDFToAudiobook"]
        )
    ],
    targets: [
        .target(
            name: "PDFToAudiobook",
            path: "Sources"
        )
    ]
)
