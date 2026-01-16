import Foundation

struct PlaybackData: Decodable {
    let tempo: Double
    let totalDuration: TimeInterval
    let notes: [NoteEvent]
}
