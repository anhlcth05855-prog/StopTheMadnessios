//
//  StopTheMadnessProApp.swift
//  StopTheMadnessPro
//
//  Created for StopTheMadness Pro iOS.
//

import SwiftUI
import AVFoundation

@main
struct StopTheMadnessProApp: App {

    init() {
        // Configure background audio session category
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[StopTheMadness] AudioSession setup error: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
