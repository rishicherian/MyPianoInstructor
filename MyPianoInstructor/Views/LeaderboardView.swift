import SwiftUI

struct LeaderboardView: View {
    @State private var leaders: [LeaderboardEntry] = []
    let mode: GameMode
    let difficulty: Difficulty
    
    var body: some View {
        VStack {
            Text("Global Top 10")
                .font(.headline)
                .padding()
            
            List(leaders) { entry in
                HStack {
                    Text(entry.username)
                    Spacer()
                    Text("\(entry.score)")
                        .bold()
                }
            }
        }
        .onAppear {
            ScoreManager.shared.fetchTopScores(mode: mode, difficulty: difficulty) { fetchedLeaders in
                self.leaders = fetchedLeaders
            }
        }
    }
}
