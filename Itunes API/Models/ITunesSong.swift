//
//  Song.swift
//  Itunes API
//
//  Created by Alexey Voronov on 06/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation

struct ITunesSong {
    let id: Int
    let name: String
    let censoredName: String
    let trackTime: Int
    let artistName: String
    let albumName: String
    let previewUrl: URL
    let albumImageUrl: URL
}
