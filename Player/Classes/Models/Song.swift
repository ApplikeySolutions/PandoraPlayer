//
//  Song.swift
//  Player
//
//  Created by Boris Bondarenko on 6/2/17.
//  Copyright © 2017 Applikey Solutions. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class Song {
    var url: URL?
    var metadata: MetaData?
    var colors: UIImageColors?
    var item: AVPlayerItem?
    
    init() {}
    
    init?(path aPath: String, type: String = "mp3") {
        if let bundlePath = Bundle.main.path(forResource: aPath, ofType: type) {
            url = URL(fileURLWithPath: bundlePath)
        }
        if let url = url {
            self.item = AVPlayerItem(url: url)
            metadata = MetaData(withAVPlayerItem: self.item)
        }
    }
    
    init?(withAVPlayerItem item: AVPlayerItem) {
        guard let urlAsset = item.asset as? AVURLAsset else { return nil }
        metadata = MetaData(withAVPlayerItem: item)
        url = urlAsset.url
    }
    
    static func construct(withMPMediaItem item: MPMediaItem, completion: GenericClosure<Song?>?) {
        let song = Song()
        guard let url = item.assetURL else {
            completion?(nil)
            return
        }
        let fileUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(item.persistentID)_exported.m4a")
        try? FileManager.default.removeItem(at: fileUrl)
        let exportSession = AVAssetExportSession(asset: AVAsset(url: url), presetName: AVAssetExportPresetAppleM4A)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileType.m4a
        exportSession?.outputURL = fileUrl
        
        exportSession?.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async(execute: {
                song.url = fileUrl
                completion?(song)
            })
        })
        
        song.metadata = MetaData(withMPMediaItem: item)
    }
}
