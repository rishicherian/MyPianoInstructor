import Foundation

struct Song: Identifiable, Equatable {
    let id: UUID
    var title: String
    var gameMode: String
    var difficulty: Int
    var score: Int
    var createdAt: Date
    var durationSeconds: Int
    
    static func mock(title: String) -> Song {
        Song(id: UUID(),
             title: title,
             gameMode: "Practice",
             difficulty: 1,
             score: 0,
             createdAt: Date(),
             durationSeconds: Int.random(in: 60...360))
    }
}
