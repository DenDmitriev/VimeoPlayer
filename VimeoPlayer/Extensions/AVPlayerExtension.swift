//
//  AVPlayerExtension.swift
//  VimeoPlayer
//
//  Created by Denis Dmitriev on 18.01.2024.
//

import AVKit

extension AVPlayer.Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return String(localized: "unknown")
        case .readyToPlay:
            return String(localized: "ready to play")
        case .failed:
            return String(localized: "failed")
        @unknown default:
            return String(localized: "unknown")
        }
    }
}
extension AVPlayer.TimeControlStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .paused:
            return String(localized: "paused")
        case .waitingToPlayAtSpecifiedRate:
            return String(localized: "waiting")
        case .playing:
            return String(localized: "playing")
        @unknown default:
            return String(localized: "unknown")
        }
    }
}
extension AVPlayerItem.Status: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return String(localized: "unknown")
        case .readyToPlay:
            return String(localized: "ready to play")
        case .failed:
            return String(localized: "failed")
        @unknown default:
            return String(localized: "unknown")
        }
    }
}
