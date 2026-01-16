import SwiftUI

struct FallingNotesView: View {
    let notes: [NoteEvent]
    let currentTime: TimeInterval
    let lookahead: TimeInterval
    
    let startPitch: Int
    let endPitch: Int
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            let whiteKeys = (startPitch...endPitch).filter { isWhiteKey($0) }
            let keyWidth = width / CGFloat(whiteKeys.count)
            
            ZStack {
                ForEach(notes) { note in
                    if let frame = frameFor(note: note, in: width, height: height, keyWidth: keyWidth, whiteKeys: whiteKeys) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isWhiteKey(note.pitch) ? Color.cyan : Color.purple)
                            .frame(width: frame.width, height: frame.height)
                            .position(x: frame.midX, y: frame.midY)
                            .shadow(color: .white.opacity(0.3), radius: 3)
                    }
                }
            }
        }
    }
    
    private func frameFor(note: NoteEvent, in width: CGFloat, height: CGFloat, keyWidth: CGFloat, whiteKeys: [Int]) -> CGRect? {
        let timeUntilHit = note.startTime - currentTime
        
        guard timeUntilHit <= lookahead,
              timeUntilHit >= -note.duration - 1.0 else {
            return nil
        }
        
        let headProgress = 1.0 - (timeUntilHit / lookahead)
        let headY = height * CGFloat(headProgress)
        let speedPixelsPerSec = height / CGFloat(lookahead)
        let noteHeight = max(20, CGFloat(note.duration) * speedPixelsPerSec)
        let midY = headY - (noteHeight / 2)
        
        var x: CGFloat = 0
        var noteWidth: CGFloat = 0
        
        if isWhiteKey(note.pitch) {
            if let index = whiteKeys.firstIndex(of: note.pitch) {
                noteWidth = keyWidth * 0.9
                x = (CGFloat(index) * keyWidth) + (keyWidth / 2)
            }
        } else {
            if let whiteIndex = whiteKeys.firstIndex(of: note.pitch - 1) {
                let blackKeyWidth = keyWidth * 0.65
                noteWidth = blackKeyWidth
                x = CGFloat(whiteIndex + 1) * keyWidth
            }
        }
        
        if noteWidth == 0 { return nil }
        
        return CGRect(x: x - noteWidth/2, y: midY - noteHeight/2, width: noteWidth, height: noteHeight)
    }
    
    private func isWhiteKey(_ pitch: Int) -> Bool {
        let note = pitch % 12
        return [0, 2, 4, 5, 7, 9, 11].contains(note)
    }
}
