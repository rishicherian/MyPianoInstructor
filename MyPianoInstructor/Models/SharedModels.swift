import Foundation
import FirebaseFirestore

enum GameMode: String, CaseIterable, Identifiable {
    case listen = "Listen & Identify"
    case accuracy = "Test Your Accuracy"
    var id: String { rawValue }
}

enum Difficulty: Int, CaseIterable, Identifiable {
    case easy = 1
    case medium = 5
    case hard = 10
    
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

struct QuizQuestion {
    let notesToPlay: [NoteEvent]
    let correctAnswer: String
    let options: [String]
}

struct FallingChordRound {
    let notes: [NoteEvent]
    let chordName: String
    let timeUntilImpact: Double
}

struct LeaderboardEntry: Identifiable, Codable {
    @DocumentID var id: String?
    let username: String
    let score: Int
    let mode: String
    let difficulty: String
    let date: Date
}

class ScoreManager {
    static let shared = ScoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func saveScore(score: Int, mode: GameMode, difficulty: Difficulty) {
        let key = keyFor(mode: mode, difficulty: difficulty)
        let currentHigh = UserDefaults.standard.integer(forKey: key)
        
        if score > currentHigh {
            UserDefaults.standard.set(score, forKey: key)
            
            let storedName = UserDefaults.standard.string(forKey: "username") ?? "Player 1"

            let newEntry = LeaderboardEntry(
                username: storedName,
                score: score,
                mode: mode.rawValue,
                difficulty: difficulty.label,
                date: Date()
            )
            
            do {
                try db.collection("leaderboard").addDocument(from: newEntry)
                print("✅ Score uploaded for \(storedName): \(score)")
            } catch {
                print("Error saving to cloud: \(error)")
            }
        }
    }
    
    func getHighScore(mode: GameMode, difficulty: Difficulty) -> Int {
        return UserDefaults.standard.integer(forKey: keyFor(mode: mode, difficulty: difficulty))
    }
    
    func fetchTopScores(mode: GameMode, difficulty: Difficulty, completion: @escaping ([LeaderboardEntry]) -> Void) {
        db.collection("leaderboard")
            .whereField("mode", isEqualTo: mode.rawValue)
            .whereField("difficulty", isEqualTo: difficulty.label)
            .order(by: "score", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ FIRESTORE ERROR: \(error.localizedDescription)")
                }

                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async { completion([]) }
                    return
                }
                
                DispatchQueue.main.async {
                    let leaders = documents.compactMap { try? $0.data(as: LeaderboardEntry.self) }
                    completion(leaders)
                }
            }
    }
    
    private func keyFor(mode: GameMode, difficulty: Difficulty) -> String {
        return "Score_\(mode.rawValue)_\(difficulty.rawValue)"
    }
}
