//
//  ContentView.swift
//  ChewingSounds
//
//  Created by Taha Baliwala on 8/8/26.
//

import SwiftUI
import CoreML
func playMusic(){
        AudioManager.shared.playSound(named: "your_added_music_string_name")
    }
    
func pauseMusic(){
        AudioManager.shared.stopSound()
    }

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
