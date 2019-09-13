//
//  ItunesSongsSearchResult.swift
//  Itunes API
//
//  Created by Alexey Voronov on 13/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation

struct ItunesSongsSearchResult: Decodable {
    let results: [ITunesSong]
    
    enum CodingKeys: String, CodingKey {
        case results
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.results = try container.decode([ITunesSong].self, forKey: .results)
    }
}
