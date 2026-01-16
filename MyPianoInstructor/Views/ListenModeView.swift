import SwiftUI

struct ListenModeView: View {
    @EnvironmentObject var libraryVM: GameViewModel
    
    let difficulty: Difficulty
    
    @Environment(\.dismiss) var dismiss
    
    @State private var currentQuestion: QuizQuestion?
    @State private var score: Int = 0
    @State private var message: String = "Listen carefully..."
    @State private var messageColor: Color = .primary
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text("Ear Training")
                    .font(.headline)
                Spacer()
                Text("Score: \(score)")
                    .bold()
            }
            .padding()
            
            Spacer()
            
            Button {
                playCurrentSound()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 150, height: 150)
                    
                    Image(systemName: "ear.and.waveform")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                        .foregroundColor(.blue)
                }
            }
            
            Text(message)
                .font(.headline)
                .foregroundColor(messageColor)
                .padding()
            
            Spacer()
            
            if let question = currentQuestion {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(question.options, id: \.self) { option in
                        Button {
                            checkAnswer(option)
                        } label: {
                            Text(option)
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                        .disabled(isProcessing)
                    }
                }
                .padding()
            }
            
            Button(action: {
                ScoreManager.shared.saveScore(score: score, mode: .listen, difficulty: difficulty)
                dismiss()
            }) {
                Text("Quit")
                    .foregroundColor(.red)
            }
            .padding(.bottom)
        }
        .onAppear {
            nextQuestion()
        }
    }
    
    private func nextQuestion() {
        currentQuestion = GameEngine.shared.generateQuiz(difficulty: difficulty.rawValue)
        
        message = "Tap the ear to listen again."
        messageColor = .primary
        isProcessing = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            playCurrentSound()
        }
    }
    
    private func playCurrentSound() {
        guard let notes = currentQuestion?.notesToPlay else { return }
        for note in notes {
            if note.startTime > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + note.startTime) {
                    AudioService.shared.play(note: note)
                }
            } else {
                AudioService.shared.play(note: note)
            }
        }
    }
    
    private func checkAnswer(_ selected: String) {
        guard let question = currentQuestion, !isProcessing else { return }
        isProcessing = true
        
        if selected == question.correctAnswer {
            score += 10
            message = "Correct! +10"
            messageColor = .green
        } else {
            message = "Wrong! It was \(question.correctAnswer)"
            messageColor = .red
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            nextQuestion()
        }
    }
}
