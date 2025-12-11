//
//  Utilities.swift
//  SimpleVideoPlayer
//
//  Created by Abraham Rubio on 11/12/25.
//

class Utilities {
    
    func format(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
