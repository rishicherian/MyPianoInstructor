import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var currentLevelData: PlaybackData?
    @Published var recentSessions: [Song] = []
    
    private let gameEngine = GameEngine.shared

    func createGameLevel(mode: GameMode, difficulty: Int) -> Song {
        let levelData = gameEngine.generateLevel(mode: mode, difficulty: difficulty)
        
        let title = "\(mode.rawValue) (Lvl \(difficulty))"
        let newSession = Song(
            id: UUID(),
            title: title,
            gameMode: mode.rawValue,
            difficulty: difficulty,
            score: 0,
            createdAt: Date(),
            durationSeconds: Int(levelData.totalDuration)
        )
        
        self.currentLevelData = levelData
        self.recentSessions.insert(newSession, at: 0)
        
        return newSession
    }
    
    func playbackData(for song: Song?) -> PlaybackData? {
        return currentLevelData
    }
}
