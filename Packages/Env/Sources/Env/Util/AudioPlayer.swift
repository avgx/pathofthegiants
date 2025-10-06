import Foundation
import AVFoundation

@MainActor
public class AudioPlayer {
    
    public static let shared = AudioPlayer()
    private init() { }
    
    public var audioPlayer: AVAudioPlayer?
    
    public func setup(mp3Data: Data) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Create an AVAudioPlayer instance from the Data
            audioPlayer = try AVAudioPlayer(data: mp3Data)
            
            // Prepare and play the audio
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error creating audio player: \(error.localizedDescription)")
        }
    }
    
    public func play() {
        audioPlayer?.play()
    }
    
    public func pause() {
        audioPlayer?.pause()
    }
    
    public func stop() {
        audioPlayer?.stop()
    }
    
    public var currentTime: TimeInterval? {
        return audioPlayer?.currentTime
    }
    
    public var duration: TimeInterval? {
        return audioPlayer?.duration
    }
}
