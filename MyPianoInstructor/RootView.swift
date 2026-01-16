import SwiftUI

struct RootView: View {
    @State private var selectedSong: Song? = nil
    @State private var tabSelection: Int = 0
    @State private var isGameActive: Bool = false
    
    @StateObject private var libraryVM = GameViewModel()

    var body: some View {
        NavigationStack {
            GameSetupView(selectedSong: $selectedSong,
                          tabSelection: $tabSelection,
                          isGameActive: $isGameActive)
                .environmentObject(libraryVM)
        }
        .fullScreenCover(isPresented: $isGameActive) {
            if let song = selectedSong {
                if song.gameMode == GameMode.listen.rawValue {
                    ListenModeView(difficulty: Difficulty(rawValue: song.difficulty) ?? .easy)
                        .environmentObject(libraryVM)
                } else {
                    AccuracyGameView(difficulty: song.difficulty)
                }
            } else {
                Text("Error: No level data")
            }
        }
    }
}
