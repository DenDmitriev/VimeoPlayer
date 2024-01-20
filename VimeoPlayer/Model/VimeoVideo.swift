//
//  VimeoVideo.swift
//  VimeoPlayer
//
//  Created by Denis Dmitriev on 18.01.2024.
//

import Foundation

struct VimeoVideo {
    let id: UUID
    let title: String
    let videoUrls: [URLVideo]
    let url: URL
    let size: CGSize
    var aspectRatio: Double {
        size.width / size.height
    }
    let coverURL: URL?
    let thumbs: [URLThumbQuality]
    let duration: Double
    let frameRate: Double
}

extension VimeoVideo {
    struct URLVideo {
        let quality: VimeoResponse.Files.Progressive.Quality
        let url: URL
        let size: CGSize?
    }
    
    struct URLThumbQuality {
        let quality: VimeoResponse.Video.Thumbs.CodingKeys
        let url: URL
    }
}

extension VimeoVideo {
    static func build(response: VimeoResponse) -> Self? {
        var videoUrls = response.request.files.progressive.compactMap({ file -> VimeoVideo.URLVideo? in
            return .init(quality: file.quality, url: file.url, size: .init(width: file.width, height: file.height))
        })
        let size = CGSize(width: response.video.width, height: response.video.height)
        
        if let cdnPlayer = response.request.files.hls.defaultPlayer {
            let videoURL: URLVideo = .init(quality: .qualityUnknown, url: cdnPlayer.url, size: nil)
            videoUrls.append(videoURL)
        }
        
        guard let url = videoUrls.highestResolutionURLVideo?.url else { return nil }
        
        print(url)
        
        let id = UUID()
        let title = response.video.title
        let thumbs = VimeoResponse.Video.Thumbs.CodingKeys.allCases.compactMap { quality -> URLThumbQuality? in
            guard let url = quality.url(response.video.thumbs) else { return nil }
            return URLThumbQuality(quality: quality, url: url)
        }
        let coverURL = thumbs.first?.url
        let duration = response.video.duration
        let frameRate = response.video.fps
        
        return .init(
            id: id,
            title: title,
            videoUrls: videoUrls,
            url: url,
            size: size,
            coverURL: coverURL,
            thumbs: thumbs,
            duration: duration,
            frameRate: frameRate
        )
    }
}

extension Array<VimeoVideo.URLVideo> {
    var highestResolutionURLVideo: VimeoVideo.URLVideo? {
        self.max { lhs, rhs in
            if let lhsSize = lhs.size, let rhsSize = rhs.size {
                lhsSize.width < rhsSize.width
            } else {
                false
            }
        }
    }
    
    var lowestResolutionURLVideo: VimeoVideo.URLVideo? {
        self.min { lhs, rhs in
            if let lhsSize = lhs.size, let rhsSize = rhs.size {
                lhsSize.width < rhsSize.width
            } else {
                false
            }
        }
    }
}
