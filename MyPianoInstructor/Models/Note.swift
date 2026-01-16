import Foundation

struct NoteEvent: Identifiable, Decodable {
    let id = UUID()
    
    let pitch: Int
    let startTime: Double
    let duration: Double
    
    private enum CodingKeys: String, CodingKey {
        case pitch, startTime, duration
    }
}
