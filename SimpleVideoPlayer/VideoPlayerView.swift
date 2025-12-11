//
//  VideoPlayerView.swift
//  SimpleVideoPlayer
//
//  Created by Abraham Rubio on 11/12/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var isMutated = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 1
    @State private var isScrubbing = false
    @State private var playbackRating: Float = 1.0
    @State private var isFullscreen: Bool = false
    private var utilities = Utilities()
    
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            
            VideoPlayer(player: player)
                .frame(height: isFullscreen ? UIScreen.main.bounds.height : UIScreen.main.bounds.width * 9/16)
                .animation(.easeInOut, value:  isFullscreen)
                .allowsHitTesting(false)
            
            VStack {
                Spacer()
                
                Slider(value: Binding(get: { currentTime }, set: { value in
                    isScrubbing = true
                    currentTime = value
                }), in: 0...duration) { isEditing in
                    if !isEditing {
                        seek(to: currentTime)
                        isScrubbing = false
                    }
                }
                
                HStack {
                    Text(utilities.format(currentTime))
                    Spacer()
                    Text(utilities.format(duration))
                }
                .font(.caption)
                .foregroundStyle(isFullscreen ? .white : .black)
                
                HStack {
                    Button {
                        tooglePlay()
                    } label: {
                        Image(isPlaying ? "pause" : "play")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(height: 20)
                    }

                    Spacer()
                    
                    Button {
                        seek(to: currentTime - 10)
                    } label: {
                        Image("rewind_10")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(height: 25)
                    }

                    Spacer()
                    
                    Button {
                        isMutated.toggle()
                        player?.isMuted = isMutated
                    } label: {
                        Image(isMutated ? "sound_on" : "sound_off")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(height: 25)
                    }

                    Spacer()
                    
                    Menu {
                        Button("0.5x") { changeRate(0.5) }
                        Button("1x") { changeRate(1.0) }
                        Button("2x") { changeRate(2.0) }
                    } label: {
                        Image("speed")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(height: 40)
                    }

                    Spacer()
                    
                    Button {
                        seek(to: currentTime + 10)
                    } label: {
                        Image("forward_10")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(height: 25)
                    }

                    Spacer()
                    
                    Button {
                        isFullscreen.toggle()
                    } label: {
                        Image(isFullscreen ? "minimize" : "full_screen")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(height: 25)
                    }
                }
                .padding(.bottom)
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .background(Color.blue.opacity(0.5))
        }
        .task {
            let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
            
            player = AVPlayer(url: url!)
            
            observePlayer()
        }
    }
    
    func seek(to time: Double) {
        let target = CMTime(seconds: time, preferredTimescale: 600)
        
        player?.seek(to: target)
    }
    
    func tooglePlay() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        
        isPlaying.toggle()
    }
    
    func changeRate(_ rate: Float) {
        playbackRating = rate
        
        if isPlaying {
            player?.rate = rate
        }
    }
    
    func observePlayer() {
        if let item = player?.currentItem {
            Task {
                let duration = try await item.asset.load(.duration)
                
                self.duration = CMTimeGetSeconds(duration)
            }
        }
        
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.3, preferredTimescale: 600), queue: .main, using: { time in
            if !isScrubbing {
                currentTime = CMTimeGetSeconds(time)
            }
        })
    }
}

#Preview {
    VideoPlayerView()
}
