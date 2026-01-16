import Foundation
import AVFoundation

class AudioService {
    static let shared = AudioService()
    
    private let engine = AVAudioEngine()
    private let mixer: AVAudioMixerNode
    
    init() {
        mixer = engine.mainMixerNode
        setupAudioSession()
        startEngine()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session Error: \(error)")
        }
    }
    
    private func startEngine() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
            print("Audio Engine started.")
        } catch {
            print("Engine Start Error: \(error)")
        }
    }
    
    func play(note: NoteEvent) {
        if !engine.isRunning { startEngine() }
        
        let player = AVAudioPlayerNode()
        engine.attach(player)
        engine.connect(player, to: mixer, format: nil)
        
        let frequency = 440.0 * pow(2.0, Double(note.pitch - 69) / 12.0)
        let sampleRate = mixer.outputFormat(forBus: 0).sampleRate
        let duration = max(1.0, note.duration)
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: mixer.outputFormat(forBus: 0), frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        if let channelData = buffer.floatChannelData {
            for frame in 0..<Int(frameCount) {
                let time = Double(frame) / sampleRate
                

                var signal = sin(2.0 * .pi * frequency * time)
                
                signal += 0.5 * sin(2.0 * .pi * (frequency * 2.0) * time)
                
                signal += 0.25 * sin(2.0 * .pi * (frequency * 3.0) * time)
                
                signal *= 0.5
                
                let attackTime = 0.05
                let attack = min(1.0, time / attackTime)
                
                let decayRate = 2.0 + (Double(note.pitch) / 100.0)
                let decay = exp(-decayRate * (time - attackTime))
                
                let envelope = Float(attack * decay)
                
                for channel in 0..<Int(buffer.format.channelCount) {
                    channelData[channel][frame] = Float(signal) * envelope * 0.5
                }
            }
        }
        
        player.scheduleBuffer(buffer) {
            DispatchQueue.main.async {
                self.engine.detach(player)
            }
        }
        
        player.play()
    }
}
