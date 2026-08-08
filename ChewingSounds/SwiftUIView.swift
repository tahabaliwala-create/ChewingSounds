
import Combine
import AVFoundation
#if canImport(UIKit)
import UIKit // For haptic feedback
#endif
import AudioToolbox // For lightweight system sounds

// MARK: - MiniRecorder
// This class handles audio recording, including requesting permission, starting/stopping recording,
// saving files under Application Support, and updating a live meter level for UI visualization.
final class MiniRecorder: ObservableObject {
    
    // Indicates whether the recorder is currently recording.
    @Published var isRecording = false
    
    
    
    // Internal AVAudioRecorder instance controlling the recording session.
    private var recorder: AVAudioRecorder?
    

   
    
    // URL of the current recording file.
    private(set) var fileURL: URL?
    
    // Requests permission to access the microphone. Calls the completion handler with true/false.
    func requestPermission(_ done: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { ok in
                DispatchQueue.main.async { done(ok) }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { ok in
                DispatchQueue.main.async { done(ok) }
            }
        }
    }
    
    // Starts a new recording session.
    func start() {
        do {
            // 1) Activate and configure the audio session for recording + playback.
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            
            // 2) Determine the directory to save recordings. Use Application Support/Recordings.
            // This folder is suitable for persistent app data that is not user-visible.
            let dir = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("Recordings", isDirectory: true)
            
            
            // Create the directory if it doesn't exist yet.
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            
            // 3) Create a timestamped filename to avoid collisions.
            // Replace ":" with "-" since ":" is not allowed in filenames on some platforms.
            let stamp = ISO8601DateFormatter().string(from: .now).replacingOccurrences(of: ":", with: "-")
            let url = dir.appendingPathComponent("\(stamp).m4a")
            fileURL = url
            
            // 4) Recorder settings: use AAC format, 44.1kHz sample rate, mono channel, high quality encoding.
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
          
            
            // 5) Initialize AVAudioRecorder with the URL and settings.
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.isMeteringEnabled = true  // Enable metering to get live audio levels.
            recorder?.record()                  // Start recording.
            playStartFeedback()            // Haptics/sound when recording starts (see helpers below)
            isRecording = true                 // Update published state.
            
            // 6) Start a Combine timer that updates the meterLevel and meterHistory every 0.05 seconds.
            
        } catch {
            // If something fails (e.g., permission denied), print the error.
            print("Start failed:", error)
        }
    }
    
    // Stops the current recording session and cleans up.
    func stop() {
        recorder?.stop()    // Stop recording.
        playStopFeedback()     // Haptics/sound when recording stops
        isRecording = false // Update state.
        recorder = nil      // Release recorder resources.
    }
    
    // MARK: - Metering
    
    // Starts a Combine timer that periodically reads audio power levels for visualization.
    
    
    // Converts a decibel audio power value to a normalized 0...1 float for UI representation.
   
    // MARK: - UI Feedback (Haptics & Sounds)
    private func playStartFeedback() {
        // Light haptic + optional system sound to confirm start
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        // System sounds are optional; choose IDs that exist on iOS.
        // Comment out if you prefer silence.
        AudioServicesPlaySystemSound(1113) // Begin recording-like tone
    }
    
    private func playStopFeedback() {
        // Light haptic + optional system sound to confirm stop
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
        AudioServicesPlaySystemSound(1114) // End recording-like tone
    }
}
