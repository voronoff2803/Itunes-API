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
        case trackId
        case trackName
        case trackCensoredName
        case trackTimeMillis
        case artistName
        case collectionName
        case previewUrl
        case artworkUrl60
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
    
        self.id = try container.decode(Int.self, forKey: .trackId)
        self.name = try container.decode(String.self, forKey: .trackName)
        self.censoredName = try container.decode(String.self, forKey: .trackCensoredName)
        self.trackTime = try container.decode(Int.self, forKey: .trackTimeMillis)
        self.artistName = try container.decode(String.self, forKey: .artistName)
        self.albumName = try container.decode(String.self, forKey: .collectionName)
        self.previewUrl = try container.decode(URL.self, forKey: .previewUrl)
        self.albumImageUrl = try container.decode(URL.self, forKey: .artworkUrl60)
    }
}
