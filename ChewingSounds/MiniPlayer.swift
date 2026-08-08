

import Combine
import SwiftUI
import AVFoundation


// MARK: - MiniPlayer
// This class handles audio playback of recorded files, including play, pause, stop,
// playback progress tracking, and seeking.
final class MiniPlayer: ObservableObject {
    // Indicates if audio is currently playing.
    @Published var isPlaying = false
    

    
    // Internal AVAudioPlayer instance for audio playback.
    private var player: AVAudioPlayer?
    

    
    // The current URL of the audio file being played.
    private var currentURL: URL?
    
    // Plays the audio at the given URL, toggling pause if already playing this URL.
    func play(_ url: URL?) {
        guard let url else { return }
        
        // If already playing this file, toggle pause.
        if isPlaying, currentURL == url {
            pause()
            return
        }
        
        stop() // Stop any existing playback before starting new one.
        
        do {
            // Create AVAudioPlayer with the file URL.
            player = try AVAudioPlayer(contentsOf: url)
            currentURL = url
            
            player?.prepareToPlay() // Prepare hardware buffers for smooth playback.
            player?.play()           // Start playing.
            isPlaying = true        // Update playback status.
            
            
        } catch {
            print("Playback failed:", error)
            isPlaying = false
        }
    }
    
    // Pauses current playback.
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    // Stops playback and resets progress.
    func stop() {
        player?.stop()
        isPlaying = false
        player = nil
        currentURL = nil
    }
    
    // Seeks playback to a specific normalized progress position (0...1).
    func seek(to prog: Double) {
        guard let player, player.duration > 0 else { return }
        player.currentTime = prog * player.duration
    }
    
    
    // Returns URL of the currently playing audio file, if any.
    var playingURL: URL? { currentURL }
}
