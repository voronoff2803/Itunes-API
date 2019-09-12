//
//  SelectSongViewControllerDelegate.swift
//  Itunes API
//
//  Created by Alexey Voronov on 08/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation

protocol SelectSongViewControllerDelegate: class {
    func didSelectSong(song: ITunesSong)
}
