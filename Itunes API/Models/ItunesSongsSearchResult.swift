//
//  ItunesSongsSearchResult.swift
//  Itunes API
//
//  Created by Alexey Voronov on 13/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation

struct ItunesSongsSearchResult: Decodable {
    let results: [FailableDecodable<ITunesSong>]
}
