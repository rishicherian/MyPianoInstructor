import Foundation

class GameEngine {
    static let shared = GameEngine()
    
    func generateLevel(mode: GameMode, difficulty: Int) -> PlaybackData {
        let tempo: Double = 120.0
        var notes: [NoteEvent] = []
        var totalDuration: TimeInterval = 0
        
        if mode == .accuracy {
            let rounds = generateAccuracyLevel(difficulty: difficulty)
            notes = rounds.flatMap { $0.notes }
            totalDuration = (rounds.last?.timeUntilImpact ?? 0) + 2.0
        } else {
            let quiz = generateQuiz(difficulty: difficulty)
            notes = quiz.notesToPlay
            totalDuration = 5.0
        }
        
        return PlaybackData(tempo: tempo, totalDuration: totalDuration, notes: notes)
    }
    
    func generateAccuracyLevel(difficulty: Int) -> [FallingChordRound] {
        var rounds: [FallingChordRound] = []
        let count = 5
        
        var lastImpactTime = 0.0
        
        for _ in 0..<count {
            let round = generateNextAccuracyRound(difficulty: difficulty, previousImpactTime: lastImpactTime)
            rounds.append(round)
            lastImpactTime = round.timeUntilImpact
        }
        return rounds
    }
    
    func generateNextAccuracyRound(difficulty: Int, previousImpactTime: Double) -> FallingChordRound {
        let spacing = max(2.5, 6.5 - (Double(difficulty) * 0.4))
        let impactTime = previousImpactTime + spacing
        
        let fallDuration = max(2.5, 5.3 - (Double(difficulty) * 0.28))
        
        let chord = generateRandomChord(difficulty: difficulty)
        
        let notes = chord.notesToPlay.map { note in
            NoteEvent(
                pitch: note.pitch,
                startTime: impactTime - fallDuration,
                duration: 0.5
            )
        }
        
        return FallingChordRound(
            notes: notes,
            chordName: chord.correctAnswer,
            timeUntilImpact: impactTime
        )
    }
    
    func generateQuiz(difficulty: Int) -> QuizQuestion {
        if difficulty <= 3 { return generateSingleNoteQuiz() }
        else if difficulty >= 8 { return generateChordQuiz() }
        else { return Bool.random() ? generateSingleNoteQuiz() : generateChordQuiz() }
    }
    private func generateSingleNoteQuiz() -> QuizQuestion {
        let pitch = Int.random(in: 48...72); let correctName = pitchToName(pitch)
        var options = Set<String>(); options.insert(correctName)
        while options.count < 4 { options.insert(pitchToName(Int.random(in: 48...72))) }
        return QuizQuestion(notesToPlay: [NoteEvent(pitch: pitch, startTime: 0, duration: 1.0)], correctAnswer: correctName, options: Array(options).sorted())
    }
    private func generateChordQuiz() -> QuizQuestion { return generateRandomChord(difficulty: 5) }
    
     func generateRandomChord(difficulty: Int) -> QuizQuestion {
        let root = Int.random(in: 48...60); let rootName = pitchToName(root)
        let types = (difficulty > 5) ? ["Maj", "Min", "7"] : ["Maj", "Min"]
        let type = types.randomElement() ?? "Maj"; let chordName = "\(rootName) \(type)"
        let t = 0.0; let d = 2.0; var notes: [NoteEvent] = []
        if type == "Maj" { notes = [NoteEvent(pitch: root, startTime: t, duration: d), NoteEvent(pitch: root + 4, startTime: t, duration: d), NoteEvent(pitch: root + 7, startTime: t, duration: d)] }
        else if type == "Min" { notes = [NoteEvent(pitch: root, startTime: t, duration: d), NoteEvent(pitch: root + 3, startTime: t, duration: d), NoteEvent(pitch: root + 7, startTime: t, duration: d)] }
        else { notes = [NoteEvent(pitch: root, startTime: t, duration: d), NoteEvent(pitch: root + 4, startTime: t, duration: d), NoteEvent(pitch: root + 7, startTime: t, duration: d), NoteEvent(pitch: root + 10, startTime: t, duration: d)] }
        var options = Set<String>(); options.insert(chordName)
        while options.count < 4 {
            let r = Int.random(in: 48...60); let t = types.randomElement() ?? "Maj"
            options.insert("\(pitchToName(r)) \(t)")
        }
        return QuizQuestion(notesToPlay: notes, correctAnswer: chordName, options: Array(options).sorted())
    }
    private func pitchToName(_ pitch: Int) -> String {
        let names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        return names[pitch % 12]
    }
}
