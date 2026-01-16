import SwiftUI

struct AccuracyGameView: View {
    @Environment(\.dismiss) var dismiss
    
    let difficulty: Int
    
    @State private var rounds: [FallingChordRound] = []
    @State private var currentRoundIndex = 0
    @State private var score = 0
    @State private var gameStartTime: Date = Date()
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var currentOptions: [String] = []
    
    @State private var selectedOption: String? = nil
    @State private var isRoundOver: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Text("Score: \(score)")
                    .font(.title)
                    .bold()
                    .padding(.top, 50)
                
                Spacer()
                
                if !currentOptions.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(currentOptions, id: \.self) { option in
                            Button {
                                checkAnswer(option)
                            } label: {
                                Text(option)
                                    .font(.title3)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(getButtonColor(for: option))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .animation(.easeInOut(duration: 0.2), value: isRoundOver)
                            }
                            .disabled(isRoundOver)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                Button(action: { quitGame() }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("Quit")
                    }
                    .font(.subheadline)
                    .padding(.vertical, 10)
                    .frame(maxWidth: 120)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
                .padding(.bottom, 50)
            }
            .frame(width: 230)
            .background(Color(UIColor.secondarySystemBackground))
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                FallingNotesView(
                    notes: getAllNotes(),
                    currentTime: currentTime,
                    lookahead: 4.0,
                    startPitch: 48,
                    endPitch: 72
                )
                .clipped()
                
                PianoKeyboardView(
                    startPitch: 48,
                    endPitch: 72,
                    highlightedPitches: [],
                    onKeyPress: { pitch in
                        AudioService.shared.play(note: NoteEvent(pitch: pitch, startTime: 0, duration: 0.3))
                    },
                    showLabels: difficulty == 1
                )
                .frame(height: 160)
            }
            .padding(.trailing, 40)
            .background(Color.black)
            .ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .onAppear {
            startGame()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
        
    private func getButtonColor(for option: String) -> Color {
        guard isRoundOver, currentRoundIndex < rounds.count else {
            return Color.blue
        }
        
        let correct = rounds[currentRoundIndex].chordName
        
        if option == correct {
            return Color.green
        }
        
        if option == selectedOption {
            return Color.red
        }
        
        return Color.gray.opacity(0.5)
    }
    
    private func startGame() {
        let rawRounds = GameEngine.shared.generateAccuracyLevel(difficulty: difficulty)
        rounds = rawRounds.map { processRound($0) }
        
        currentRoundIndex = 0
        score = 0
        gameStartTime = Date()
        setupRound(index: 0)
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in updateGameLoop() }
    }
    
    private func processRound(_ round: FallingChordRound) -> FallingChordRound {
        let fixedNotes = round.notes.map { note in
            NoteEvent(pitch: note.pitch, startTime: round.timeUntilImpact, duration: note.duration)
        }
        return FallingChordRound(notes: fixedNotes, chordName: round.chordName, timeUntilImpact: round.timeUntilImpact)
    }
    
    private func setupRound(index: Int) {
        guard index < rounds.count else { return }
        let round = rounds[index]
        
        isRoundOver = false
        selectedOption = nil
        
        var options = Set<String>()
        options.insert(round.chordName)
        let roots = ["C", "F", "G", "A", "D", "E"]
        let types = ["Maj", "Min", "7"]
        while options.count < 4 {
            let r = roots.randomElement()!
            let t = types.randomElement()!
            options.insert("\(r) \(t)")
        }
        currentOptions = Array(options).sorted()
    }
    
    private func updateGameLoop() {
        currentTime = Date().timeIntervalSince(gameStartTime)
        if !isRoundOver && currentRoundIndex < rounds.count {
            let round = rounds[currentRoundIndex]
            if currentTime > round.timeUntilImpact + 0.1 { handleMiss() }
        }
    }
    
    private func handleMiss() {
        isRoundOver = true
        let round = rounds[currentRoundIndex]
        
        playChord(round.notes)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            advanceRound()
        }
    }
    
    private func checkAnswer(_ answer: String) {
        guard !isRoundOver, currentRoundIndex < rounds.count else { return }
        let round = rounds[currentRoundIndex]
        
        isRoundOver = true
        selectedOption = answer
        
        if answer == round.chordName {
            score += 10
        }
        
        playChord(round.notes)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            advanceRound()
        }
    }
    
    private func playChord(_ notes: [NoteEvent]) {
        for note in notes {
            let instantNote = NoteEvent(pitch: note.pitch, startTime: 0, duration: 0.5)
            AudioService.shared.play(note: instantNote)
        }
    }
    
    private func advanceRound() {
        currentRoundIndex += 1
        
        if let lastRound = rounds.last {
            let nextRawRound = GameEngine.shared.generateNextAccuracyRound(difficulty: difficulty, previousImpactTime: lastRound.timeUntilImpact)
            rounds.append(processRound(nextRawRound))
        }
        
        setupRound(index: currentRoundIndex)
    }
    
    private func endGame() {
        timer?.invalidate()
        currentOptions = []
        if let diffEnum = Difficulty(rawValue: difficulty) {
            ScoreManager.shared.saveScore(score: score, mode: .accuracy, difficulty: diffEnum)
        }
    }
    
    private func quitGame() {
        if let diffEnum = Difficulty(rawValue: difficulty) {
            ScoreManager.shared.saveScore(score: score, mode: .accuracy, difficulty: diffEnum)
        }
        timer?.invalidate()
        dismiss()
    }
    
    private func getAllNotes() -> [NoteEvent] {
        let activeRounds = rounds.dropFirst(currentRoundIndex)
        return activeRounds.flatMap { $0.notes }
    }
}
