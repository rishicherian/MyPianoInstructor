import SwiftUI
import UIKit

struct PianoKeyboardView: View {
    var startPitch: Int = 48
    var endPitch: Int = 72
    var highlightedPitches: Set<Int>
    var onKeyPress: ((Int) -> Void)?
    var showLabels: Bool = false
    
    @State private var lastDragPitch: Int? = nil
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            let whiteKeys = (startPitch...endPitch).filter { isWhiteKey($0) }
            let keyWidth = width / CGFloat(whiteKeys.count)
            let blackKeyWidth = keyWidth * 0.65
            let blackKeyHeight = height * 0.6
            
            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    ForEach(whiteKeys, id: \.self) { pitch in
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(highlightedPitches.contains(pitch) ? Color.green : Color.white)
                                .border(Color.black, width: 1)
                                .cornerRadius(4, corners: [.bottomLeft, .bottomRight])
                            
                            if showLabels {
                                Text(noteName(for: pitch))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.bottom, 20)
                            }
                        }
                        .frame(width: keyWidth, height: height)
                    }
                }
                
                ForEach(startPitch...endPitch, id: \.self) { pitch in
                    if !isWhiteKey(pitch) {
                        if let whiteIndex = whiteKeys.firstIndex(where: { $0 == pitch - 1 }) {
                            let xPosition = (CGFloat(whiteIndex + 1) * keyWidth) - (blackKeyWidth / 2)
                            
                            ZStack(alignment: .bottom) {
                                Rectangle()
                                    .fill(highlightedPitches.contains(pitch) ? Color.green : Color.black)
                                    .cornerRadius(2, corners: [.bottomLeft, .bottomRight])
                                
                                if showLabels {
                                    Text(noteName(for: pitch))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 8)
                                }
                            }
                            .frame(width: blackKeyWidth, height: blackKeyHeight)
                            .position(x: xPosition + (blackKeyWidth / 2), y: blackKeyHeight / 2)
                            .zIndex(1)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleTouch(at: value.location, width: width, height: height, whiteKeys: whiteKeys, keyWidth: keyWidth, blackKeyWidth: blackKeyWidth, blackKeyHeight: blackKeyHeight)
                    }
                    .onEnded { _ in
                        lastDragPitch = nil
                    }
            )
        }
        .background(Color.black)
    }
    
    private func handleTouch(at location: CGPoint, width: CGFloat, height: CGFloat, whiteKeys: [Int], keyWidth: CGFloat, blackKeyWidth: CGFloat, blackKeyHeight: CGFloat) {
        
        var detectedPitch: Int? = nil
        
        if location.y <= blackKeyHeight {
            for pitch in startPitch...endPitch {
                if !isWhiteKey(pitch) {
                    if let whiteIndex = whiteKeys.firstIndex(where: { $0 == pitch - 1 }) {
                        let center = (CGFloat(whiteIndex + 1) * keyWidth)
                        let left = center - (blackKeyWidth / 2)
                        let right = center + (blackKeyWidth / 2)
                        
                        if location.x >= left && location.x <= right {
                            detectedPitch = pitch
                            break
                        }
                    }
                }
            }
        }
        
        if detectedPitch == nil {
            let index = Int(location.x / keyWidth)
            if index >= 0 && index < whiteKeys.count {
                detectedPitch = whiteKeys[index]
            }
        }
        
        if let p = detectedPitch, p != lastDragPitch {
            onKeyPress?(p)
            lastDragPitch = p
        }
    }
    
    private func isWhiteKey(_ pitch: Int) -> Bool {
        let note = pitch % 12
        return [0, 2, 4, 5, 7, 9, 11].contains(note)
    }
    
    private func noteName(for pitch: Int) -> String {
        let names = ["C", "", "D", "", "E", "F", "", "G", "", "A", "", "B"]
        let blackNames = ["", "C#", "", "D#", "", "", "F#", "", "G#", "", "A#", ""]
        let noteIndex = pitch % 12
        return isWhiteKey(pitch) ? names[noteIndex] : blackNames[noteIndex]
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
