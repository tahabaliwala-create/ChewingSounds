
import SwiftUI
import AVFoundation
#if canImport(UIKit)
import UIKit
import CoreML
#endif
import SoundAnalysis

/// An observer that receives results from a classify sound request.
class ResultsObserver: NSObject, SNResultsObserving {
    /// Notifies the observer when a request generates a prediction.
    func request(_ request: SNRequest, didProduce result: SNResult) {
        // Downcast the result to a classification result.
        guard let result = result as? SNClassificationResult else  { return }


        // Get the prediction with the highest confidence.
        guard let classification = result.classifications.first else { return }


        // Get the starting time.
        let timeInSeconds = result.timeRange.start.seconds


        // Convert the time to a human-readable string.
        let formattedTime = String(format: "%.2f", timeInSeconds)
        print("Analysis result for audio at time: \(formattedTime)")


        // Convert the confidence to a percentage string.
        let percent = classification.confidence * 100.0
        let percentString = String(format: "%.2f%%", percent)


        // Print the classification's name (label) with its confidence.
        print("\(classification.identifier): \(percentString) confidence.\n")
    }




    /// Notifies the observer when a request generates an error.
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The analysis failed: \(error.localizedDescription)")
    }


    /// Notifies the observer when a request is complete.
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}
struct ContentView: View {
    // State object to manage recording and audio levels.
    @StateObject private var rec = MiniRecorder()
    
    // State object to manage audio playback.
    @StateObject private var player = MiniPlayer()
    
    
    // Tracks whether microphone permission is denied to show an alert.
    @State private var micDenied = false
    
    @State private var resultsObserver: ResultsObserver?
    
    
    func runModel() async {
        guard let audioFileURL = rec.fileURL else  {
            print("No recording to analyze")
            return
        }
        do {
            // Use a default model configuration.
            let defaultConfig = MLModelConfiguration()
            
            // Create an instance of the sound classifier's wrapper class.
            let soundClassifier = try ChewingSoundClassifier(configuration: MLModelConfiguration())
            
            // Create a classify sound request that uses the custom sound classifier.
            let classifySoundRequest = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            let resultsObserver = ResultsObserver()
            
            func createAnalyzer(audioFileURL: URL) -> SNAudioFileAnalyzer? {
                return try? SNAudioFileAnalyzer(url: audioFileURL)
            }
            let audioFileAnalyzer = createAnalyzer(audioFileURL: audioFileURL)
            // Add a request to analyze.
            try audioFileAnalyzer?.add(classifySoundRequest, withObserver: resultsObserver)
            
           
            await audioFileAnalyzer?.analyze()
            
            
            
        }
        catch {
            print("something went wrong")
        }
        
    }
   

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
