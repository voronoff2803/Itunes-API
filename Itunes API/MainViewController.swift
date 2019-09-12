//
//  MainViewController.swift
//  Itunes API
//
//  Created by Alexey Voronov on 08/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var songLabel: UILabel!
    
    @IBAction func selectSongAction() {
        let queue = OperationQueue()
        let selectItunesSongOpertaion = SelectItunesSongOperation(presenter: self)
        
        selectItunesSongOpertaion.completionBlock = {
            DispatchQueue.main.async() {
                self.songLabel.text = selectItunesSongOpertaion.selectedSong?.name
            }
        }
        
        queue.addOperation(selectItunesSongOpertaion)
    }
}
