//
//  VimeoPlayerViewModel.swift
//  VimeoPlayer
//
//  Created by Denis Dmitriev on 18.01.2024.
//

import Foundation
import AVKit

class VimeoPlayerViewModel: ObservableObject {
    @Published var vimeoVideo: VimeoVideo?
    @Published var error: VimeoPLayerError?
    @Published var hasError: Bool = false
    @Published var statusPlayer: AVPlayer.Status = .unknown
    @Published var statusTimeControl: AVPlayer.TimeControlStatus = .waitingToPlayAtSpecifiedRate
    @Published var statusVideo: AVPlayerItem.Status = .unknown
    private var playerObservers = Set<NSKeyValueObservation>()
    
    
    func fetchVimeoVideo(by url: URL?) async {
        guard let url else { return }
        let videoId = url.lastPathComponent
        do {
            guard videoId != "" else { throw VimeoPLayerError.invalidVideoId }
            
            let configURL = "https://player.vimeo.com/video/{id}/config"
            let dataURL = configURL.replacingOccurrences(of: "{id}", with: videoId)
            
            guard let url = URL(string: dataURL) else { throw VimeoPLayerError.invalidURL }
            
            let request = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: request)
            let vimeoResponse = try JSONDecoder().decode(VimeoResponse.self, from: data)
            
            guard let vimeoVideo = VimeoVideo.build(response: vimeoResponse) else { throw VimeoPLayerError.videoNotFound }
            
            DispatchQueue.main.async {
                self.vimeoVideo = vimeoVideo
            }
        } catch {
            let error = VimeoPLayerError.map(error: error)
            presentError(error)
        }
            
    }
      
    func presentError(_ error: VimeoPLayerError) {
        DispatchQueue.main.async {
            self.error = error
            self.hasError = true
        }
    }
}

/// PLayer observers
extension VimeoPlayerViewModel {
    /// Создание наблюдателей для работы плеера
    func createObservers(for player: AVPlayer?) {
        guard let player else { return }
        if let itemStatusObserver = buildPlayerItemStatusObserver(for: player) {
            playerObservers.insert(itemStatusObserver)
        }
        addPlayerStatusObserver(for: player)
        addPlayerTimeControlStatusObserver(for: player)
    }
    
    /// Отключение наблюдателей
    func removeObservers() {
        playerObservers.forEach({ $0.invalidate() })
    }
    
    /// Наблюдатель статуса видео файла в плеере
    private func buildPlayerItemStatusObserver(for player: AVPlayer?) -> NSKeyValueObservation? {
        return player?.currentItem?.observe(\.status, options: .new) { [weak self] item, status in
            DispatchQueue.main.async {
                self?.statusVideo = item.status
            }
        }
    }
    
    /// Наблюдатель над ответственным за контролем  изменением текущего времени
    private func addPlayerStatusObserver(for player: AVPlayer?) {
        if let observer = player?.observe(\.status, changeHandler: { player, status in
            DispatchQueue.main.async {
                self.statusPlayer = player.status
            }
        }) {
            playerObservers.insert(observer)
        }
    }
    
    /// Наблюдатель над ответственным за контролем  изменением текущего времени
    private func addPlayerTimeControlStatusObserver(for player: AVPlayer?) {
        if let observer = player?.observe(\.timeControlStatus, changeHandler: { player, status in
            DispatchQueue.main.async {
                self.statusTimeControl = player.timeControlStatus
            }
        }) {
            playerObservers.insert(observer)
        }
    }
}
