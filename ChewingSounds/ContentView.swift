
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
            if let url = rec.fileURL {
                Text("File: \(url.lastPathComponent)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle) // Show start and end of filename for readability.
                
                // Alternative: show human-friendly date/time from file metadata
                // Text("Recorded: \(friendlyDate(for: url))")
                //     .font(.footnote)
                //     .foregroundStyle(.secondary)
                //     .lineLimit(1)
            }
            
            
            
        }
        .padding()
        // --- UI Theme examples ---
        // Background gradient for the whole screen:
        // .background(
        //     LinearGradient(colors: [Color.blue.opacity(0.25), Color.purple.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing)
        // )
        // Rounded card style around content:
        // .background(.ultraThinMaterial)
        // .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        // .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
        // Dark mode polish:
        // .preferredColorScheme(.dark)
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
    
    // Returns sorted list of recording files in the app's Recordings directory.
    
    // MARK: - Helpers
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
