import SwiftUI

struct GameSetupView: View {
    @AppStorage("username") private var username: String = "Player 1"
    
    @EnvironmentObject var libraryVM: GameViewModel
    
    @Binding var selectedSong: Song?
    @Binding var tabSelection: Int
    @Binding var isGameActive: Bool
    
    @AppStorage("lastMode") private var savedModeRaw: String = GameMode.accuracy.rawValue
    @State private var selectedMode: GameMode = .accuracy
    @State private var selectedDifficulty: Difficulty = .easy
    
    @State private var showRotationMessage = false
    
    @State private var showFreePlay = false
    
    @State private var refreshID = UUID()
    
    @State private var showLeaderboard = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("MyPianoInstructor")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 50)
                    
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        TextField("Enter Name", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 200)
                            .submitLabel(.done)
                    }
                    .padding(.bottom, 10)
                    
                    HStack(spacing: 20) {
                        ModeCard(mode: .listen, selected: selectedMode == .listen) {
                            selectedMode = .listen
                        }
                        
                        ModeCard(mode: .accuracy, selected: selectedMode == .accuracy) {
                            selectedMode = .accuracy
                        }
                    }
                    .frame(height: 150)
                    .padding(.horizontal)
                    
                    VStack(alignment: .center, spacing: 16) {
                        Text("Select Difficulty")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            ForEach(Difficulty.allCases) { diff in
                                Button {
                                    selectedDifficulty = diff
                                } label: {
                                    Text(diff.label)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedDifficulty == diff ? Color.blue : Color.gray.opacity(0.15))
                                        .foregroundColor(selectedDifficulty == diff ? .white : .primary)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Text(descriptionFor(selectedDifficulty))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .fixedSize(horizontal: false, vertical: true)
                            .animation(.easeInOut, value: selectedDifficulty)
                    }
                    

                    Color.clear.frame(height: 1)
                    
                    VStack(spacing: 12) {
                        Text("Your Best Scores")
                            .font(.caption)
                            .textCase(.uppercase)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 40) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack { Image(systemName: "ear"); Text("Listen") }.font(.caption).bold()
                                scoreRow(mode: .listen, diff: .easy)
                                scoreRow(mode: .listen, diff: .medium)
                                scoreRow(mode: .listen, diff: .hard)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                HStack { Image(systemName: "gamecontroller.fill"); Text("Accuracy") }.font(.caption).bold()
                                scoreRow(mode: .accuracy, diff: .easy)
                                scoreRow(mode: .accuracy, diff: .medium)
                                scoreRow(mode: .accuracy, diff: .hard)
                            }
                        }
                        .font(.caption)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        Button {
                            showLeaderboard = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "globe")
                                Text("View the Global Top 10 for this Mode")
                            }
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.blue)
                        }
                        .padding(.top, 5)
                    }
                    .id(refreshID)

                    Color.clear.frame(height: 1)
                    
                    Button {
                        handleStartTap()
                    } label: {
                        Text("Start")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        handleFreePlayTap()
                    } label: {
                        HStack {
                            Image(systemName: "music.note.list")
                            Text("Free Play / Practice")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.bottom, 50)
            }
            .scrollIndicators(.hidden)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            
            if showRotationMessage {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: 15) {
                    Image(systemName: "iphone.landscape")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    Text("Please rotate your phone\nto landscape.")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(30)
                .background(Color.black.opacity(0.8))
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showFreePlay) {
            FreePlayView()
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(mode: selectedMode, difficulty: selectedDifficulty)
        }
        .onAppear {
            if let saved = GameMode(rawValue: savedModeRaw) {
                selectedMode = saved
            }
            refreshID = UUID()
        }
        .onChange(of: isGameActive) { oldValue, newValue in
            if !newValue {
                refreshID = UUID()
            }
        }
    }
        
    private func scoreRow(mode: GameMode, diff: Difficulty) -> some View {
        HStack {
            Text(diff.label + ":")
                .foregroundColor(.secondary)
            Text("\(ScoreManager.shared.getHighScore(mode: mode, difficulty: diff))")
                .bold()
        }
    }
    
    private func handleStartTap() {
        if selectedMode == .accuracy {
            withAnimation { showRotationMessage = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation { showRotationMessage = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    launchGame()
                }
            }
        } else {
            launchGame()
        }
    }
    
    private func handleFreePlayTap() {
        withAnimation { showRotationMessage = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { showRotationMessage = false }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showFreePlay = true
            }
        }
    }
    
    private func launchGame() {
        let newLevel = libraryVM.createGameLevel(mode: selectedMode, difficulty: selectedDifficulty.rawValue)
        selectedSong = newLevel
        savedModeRaw = selectedMode.rawValue
        isGameActive = true
    }
    
    func descriptionFor(_ diff: Difficulty) -> String {
        if selectedMode == .listen {
            switch diff {
            case .easy: return "Identify single notes. Good for beginners."
            case .medium: return "A mix of single notes and basic chords to test your skills."
            case .hard: return "Identify complex Major and Minor chords by ear. For advanced players."
            }
        } else {
            switch diff {
            case .easy: return "Notes fall slowly. Key labels are shown to help you."
            case .medium: return "Notes fall faster. Key labels are hidden."
            case .hard: return "Fastest speed! No key labels. Pure reflex test."
            }
        }
    }
}

struct ModeCard: View {
    let mode: GameMode
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: mode == .listen ? "ear" : "gamecontroller.fill")
                    .font(.largeTitle)
                    .padding(.bottom, 8)
                Text(mode.rawValue)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(selected ? Color.blue.opacity(0.2) : Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? Color.blue : Color.gray.opacity(0.3), lineWidth: selected ? 3 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
