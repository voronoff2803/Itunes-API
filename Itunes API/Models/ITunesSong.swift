//
//  Song.swift
//  Itunes API
//
//  Created by Alexey Voronov on 06/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation

struct ITunesSong: Decodable {
    
    let id: Int
    let name: String
    let censoredName: String
    let trackTime: Int
    let artistName: String
    let albumName: String
    let previewUrl: URL
    let albumImageUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case name = "trackName"
        case censoredName = "trackCensoredName"
        case trackTime = "trackTimeMillis"
        case artistName = "artistName"
        case albumName = "collectionName"
        case previewUrl
        case albumImageUrl = "artworkUrl60"
    }
}
