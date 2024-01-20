//
//  VimeoPlayer.swift
//  VimeoPlayer
//
//  Created by Denis Dmitriev on 18.01.2024.
//

import SwiftUI
import AVKit

struct VimeoPlayer: View {
    
    @State var player: AVPlayer?
    @StateObject var viewModel: VimeoPlayerViewModel
    @State var vimeoVideoURL: URL? = URL(string: "https://vimeo.com/676247342")
    @State var videoURL: URL?
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .onReceive(viewModel.$vimeoVideo) { vimeoVideo in
                    videoURL = vimeoVideo?.url
                }
                .onChange(of: videoURL) { newVideoURL in
                    if let newVideoURL {
                        viewModel.removeObservers()
                        player = AVPlayer(url: newVideoURL)
                        viewModel.createObservers(for: player)
                    }
                }
            
            HStack {
                Label("Vimeo link", systemImage: "link")
                
                TextField("Paste a link to a Vimeo video", value: $vimeoVideoURL, format: .url)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .frame(maxWidth: 300)
                    .onAppear {
                        Task {
                            await viewModel.fetchVimeoVideo(by: vimeoVideoURL)
                        }
                    }
                    .onChange(of: vimeoVideoURL) { newVimeoVideoURL in
                        Task {
                            await viewModel.fetchVimeoVideo(by: newVimeoVideoURL)
                        }
                    }
                
                Spacer()
                
                HStack {
                    Text(viewModel.statusTimeControl.description.capitalized)
                    Text(viewModel.statusVideo.description.capitalized)
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
        .alert(isPresented: $viewModel.hasError, error: viewModel.error, actions: { error in
            Button(action: {}) {
                Text("Ok")
            }
        }, message: { error in
            Text(error.failureReason ?? "Reason unknown")
        })
    }
}

#Preview {
    VimeoPlayer(viewModel: VimeoPlayerViewModel())
}
