
import SwiftUI
import AVFoundation
#if canImport(UIKit)
import UIKit
#endif


struct ContentView: View {
    // State object to manage recording and audio levels.
    @StateObject private var rec = MiniRecorder()
    
    // State object to manage audio playback.
    @StateObject private var player = MiniPlayer()
    
    
    // Tracks whether microphone permission is denied to show an alert.
    @State private var micDenied = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: Title
            Text("Voice Recorder")
                .font(.title3).bold()
            
            
            
            // MARK: Buttons - Record/Stop and Play current recording.
            HStack(spacing: 12) {
                
                // Record button toggles recording state.
                Button(rec.isRecording ? "Stop" : "Record") {
                    playTapHaptic()
                    if rec.isRecording {
                        // Stop recording; recordings list will refresh via onChange.
                        rec.stop()
                    } else {
                        // Stop playback if active, then start recording.
                        player.stop()
                        rec.start()
                    }
                }
                .buttonStyle(.borderedProminent)
                // Icon alternative:
                // .labelStyle(.iconOnly)
                // .font(.system(size: 22, weight: .bold))
                // .buttonStyle(.borderedProminent)
                // .overlay(Image(systemName: rec.isRecording ? "stop.fill" : "mic.fill").font(.system(size: 22)).foregroundStyle(.white))
                
                // Play button plays the current recording if available.
                Button("Play") {
                    playTapHaptic()
                    player.play(rec.fileURL)
                }
                .buttonStyle(.bordered)
                .disabled(rec.isRecording || rec.fileURL == nil) // Disable while recording or if no file.
                // Icon alternative:
                // .labelStyle(.iconOnly)
                // .font(.system(size: 20, weight: .semibold))
                // .overlay(Image(systemName: "play.fill").font(.system(size: 20)))
                // .disabled(rec.isRecording || rec.fileURL == nil)
            }
            
            // MARK: Current recording file info
           
            
            
        }
        .padding()
       
        .task {
            // Request permission to record when view appears.
            rec.requestPermission { ok in
                // Show an alert if permission is denied.
                micDenied = (ok == false)
            }
            
        }
        
        .alert("Microphone Access Needed", isPresented: $micDenied) {
            Button("OK", role: .cancel) {}
#if canImport(UIKit)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
#endif
        } message: {
            Text("Please allow microphone access in Settings to record audio.")
        }
    }
    
   
   
    private func playTapHaptic() {
#if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
#endif
    }
    
    
}
#Preview {
    ContentView()
}
