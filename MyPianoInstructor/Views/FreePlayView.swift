import SwiftUI

struct FreePlayView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showLabels: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Quit")
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                }
                
                Spacer()
                
                HStack {
                    Text("Note Labels")
                        .font(.subheadline)
                    Toggle("", isOn: $showLabels)
                        .labelsHidden()
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            PianoKeyboardView(
                startPitch: 48,
                endPitch: 72,
                highlightedPitches: [],
                onKeyPress: { pitch in
                    let note = NoteEvent(pitch: pitch, startTime: 0, duration: 0.5)
                    AudioService.shared.play(note: note)
                },
                showLabels: showLabels
            )
            .background(Color.black)
        }
    }
}
