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
    let qualityUrls: [URLVideoQuality]
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
    struct URLVideoQuality {
        let quality: VimeoResponse.Files.Progressive.Quality
        let url: URL
        let size: CGSize
    }
    
    struct URLThumbQuality {
        let quality: VimeoResponse.Video.Thumbs.CodingKeys
        let url: URL
    }
}

extension VimeoVideo {
    static func build(response: VimeoResponse) -> Self? {
        let qualityUrls = response.request.files.progressive.compactMap({ file -> VimeoVideo.URLVideoQuality? in
            return .init(quality: file.quality, url: file.url, size: .init(width: file.width, height: file.height))
        })
        let size = CGSize(width: response.video.width, height: response.video.height)
        guard let url = qualityUrls.first(where: { $0.size == size })?.url else { return nil }
        
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
            qualityUrls: qualityUrls,
            url: url,
            size: size,
            coverURL: coverURL,
            thumbs: thumbs,
            duration: duration,
            frameRate: frameRate
        )
    }
}
