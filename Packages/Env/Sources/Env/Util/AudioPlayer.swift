import Foundation
import AVFoundation
import MediaPlayer
import Combine
import SwiftUI

@MainActor
public class AudioPlayer: NSObject, ObservableObject {
    
    // MARK: - Singleton
    public static let shared = AudioPlayer()
    
    // MARK: - Published Properties
    @Published public private(set) var isPlaying = false
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var duration: TimeInterval = 0
    @Published public private(set) var playbackState: PlaybackState = .stopped {
        didSet {
            print("AudioPlayer playbackState \(playbackState)")
        }
    }
    
    // MARK: - Private Properties
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    private let remoteCommandCenter = MPRemoteCommandCenter.shared()
    
    // Для безопасного обновления NowPlayingInfo
    private let nowPlayingQueue = DispatchQueue(label: "pathofthegiants.audioplayer.nowplaying", qos: .userInitiated)
    
    // MARK: - Enums
    public enum PlaybackState {
        case stopped, playing, paused, loading
    }
    
    // MARK: - Initialization
    private override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommandCenter()
        setupNotifications()
    }
    
    deinit {
        //cleanup()
    }
    
    // MARK: - Public Methods
    public func setup(mp3Data: Data) {
        cleanupCurrentPlayback()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(data: mp3Data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
            
            updateNowPlayingInfo()
            playbackState = .stopped
            
        } catch {
            print("Error setting up audio player: \(error.localizedDescription)")
        }
    }
    
    public func play() {
        guard let player = audioPlayer else { return }
        
        if !player.isPlaying {
            player.play()
            isPlaying = true
            playbackState = .playing
            startProgressTimer()
            updateNowPlayingInfo()
        }
    }
    
    public func pause() {
        guard let player = audioPlayer, player.isPlaying else { return }
        
        player.pause()
        isPlaying = false
        playbackState = .paused
        stopProgressTimer()
        updateNowPlayingInfo()
    }
    
    public func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        currentTime = 0
        playbackState = .stopped
        stopProgressTimer()
        updateNowPlayingInfo()
    }
    
    public func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        
        player.currentTime = min(max(time, 0), duration)
        currentTime = player.currentTime
        updateNowPlayingInfo()
    }
    
    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    // MARK: - Private Methods
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupRemoteCommandCenter() {
        // Play command
        remoteCommandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.play()
            }
            return .success
        }
        
        // Pause command
        remoteCommandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.pause()
            }
            return .success
        }
        
        // Toggle play/pause command
        remoteCommandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.togglePlayPause()
            }
            return .success
        }
        
        // Change playback position command
        remoteCommandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            Task { @MainActor [weak self] in
                self?.seek(to: event.positionTime)
            }
            return .success
        }
        
        // Skip forward command (15 seconds)
        remoteCommandCenter.skipForwardCommand.preferredIntervals = [NSNumber(15)]
        remoteCommandCenter.skipForwardCommand.addTarget { [weak self] event in
            guard let event = event as? MPSkipIntervalCommandEvent else {
                return .commandFailed
            }
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.seek(to: self.currentTime + event.interval)
            }
            return .success
        }
        
        // Skip backward command (15 seconds)
        remoteCommandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(15)]
        remoteCommandCenter.skipBackwardCommand.addTarget { [weak self] event in
            guard let event = event as? MPSkipIntervalCommandEvent else {
                return .commandFailed
            }
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.seek(to: self.currentTime - event.interval)
            }
            return .success
        }
        
        // Enable commands
        remoteCommandCenter.playCommand.isEnabled = true
        remoteCommandCenter.pauseCommand.isEnabled = true
        remoteCommandCenter.togglePlayPauseCommand.isEnabled = true
        remoteCommandCenter.changePlaybackPositionCommand.isEnabled = true
        remoteCommandCenter.skipForwardCommand.isEnabled = true
        remoteCommandCenter.skipBackwardCommand.isEnabled = true
    }
    
    private func setupNotifications() {
        NotificationCenter.default
            .publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                Task { @MainActor [weak self] in
                    self?.handleAudioSessionInterruption(notification: notification)
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: AVAudioSession.routeChangeNotification)
            .sink { [weak self] notification in
                Task { @MainActor [weak self] in
                    self?.handleRouteChange(notification: notification)
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Interruption began, pause playback
            if isPlaying {
                pause()
            }
            
        case .ended:
            // Interruption ended, check if we should resume
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Resume playback if appropriate
                    play()
                }
            }
            
        @unknown default:
            break
        }
    }
    
    private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            // Audio device was disconnected, pause playback
            if isPlaying {
                pause()
            }
        default:
            break
        }
    }
    
    private func startProgressTimer() {
        stopProgressTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let player = self.audioPlayer else { return }
                self.currentTime = player.currentTime
                // Обновляем только прогресс для уменьшения нагрузки
                self.updateNowPlayingProgress()
            }
        }
    }
    
    private func stopProgressTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateNowPlayingInfo() {
        nowPlayingQueue.async { [weak self] in
            guard let self = self else { return }
            
            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
            
            // Basic track information
//            nowPlayingInfo[MPMediaItemPropertyTitle] = "Audio Track"
//            nowPlayingInfo[MPMediaItemPropertyArtist] = "Путь великанов"
            
            // Playback information
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.isPlaying ? 1.0 : 0.0
            nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
            
            // Add default artwork if needed
//            if let defaultImage = UIImage(systemName: "music.note") {
//                let artwork = MPMediaItemArtwork(boundsSize: defaultImage.size) { size in
//                    // Этот блок выполняется в фоновом потоке MPNowPlayingInfoCenter
//                    return defaultImage
//                }
//                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
//            }
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    private func updateNowPlayingProgress() {
        nowPlayingQueue.async {
            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
            
            // Обновляем только прогресс воспроизведения для производительности
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.isPlaying ? 1.0 : 0.0
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    public func cleanupCurrentPlayback() {
        stop()
        audioPlayer = nil
        
        // Очищаем NowPlayingInfo в фоновой очереди
        nowPlayingQueue.async {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        }
    }
    
    public func cleanup() {
        stopProgressTimer()
        cancellables.removeAll()
        
        // Disable remote commands
        remoteCommandCenter.playCommand.isEnabled = false
        remoteCommandCenter.pauseCommand.isEnabled = false
        remoteCommandCenter.togglePlayPauseCommand.isEnabled = false
        remoteCommandCenter.changePlaybackPositionCommand.isEnabled = false
        remoteCommandCenter.skipForwardCommand.isEnabled = false
        remoteCommandCenter.skipBackwardCommand.isEnabled = false
        
        // Clear now playing info
        nowPlayingQueue.async {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        }
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayer: AVAudioPlayerDelegate {
    nonisolated public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
            currentTime = 0
            playbackState = .stopped
            stopProgressTimer()
            updateNowPlayingInfo()
        }
    }
    
    nonisolated public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            if let error = error {
                print("Audio player decode error: \(error.localizedDescription)")
            }
            playbackState = .stopped
        }
    }
}

// MARK: - Enhanced AudioPlayer with Metadata Support
extension AudioPlayer {
    public func setupWithMetadata(
        mp3Data: Data,
        title: String? = nil,
        artist: String? = nil,
        album: String? = nil,
        artwork: UIImage? = nil
    ) {
        setup(mp3Data: mp3Data)
        updateNowPlayingInfoWithMetadata(
            title: title,
            artist: artist,
            album: album,
            artwork: artwork
        )
    }
    
    public func updateNowPlayingInfoWithMetadata(
        title: String? = nil,
        artist: String? = nil,
        album: String? = nil,
        artwork: UIImage? = nil
    ) {
        nowPlayingQueue.async { [weak self] in
            guard let self = self else { return }
            
            var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
            
            if let title = title {
                nowPlayingInfo[MPMediaItemPropertyTitle] = title
            }
            
            if let artist = artist {
                nowPlayingInfo[MPMediaItemPropertyArtist] = artist
            }
            
            if let album = album {
                nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
            }
            
            if let artwork = artwork {
                let mediaArtwork = MPMediaItemArtwork(boundsSize: artwork.size) { size in
                    // Этот блок выполняется в фоновом потоке MPNowPlayingInfoCenter
                    return artwork
                }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = mediaArtwork
            }
            
            // Обновляем остальную информацию
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.isPlaying ? 1.0 : 0.0
            nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
}

// MARK: - SwiftUI View for Testing/Demo

