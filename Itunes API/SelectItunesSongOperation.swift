//
//  SelectItunesSongOperation.swift
//  Itunes API
//
//  Created by Alexey Voronov on 11/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

class SelectItunesSongOperation: Operation, SelectSongViewControllerDelegate {
    
    let presenter: UIViewController
    var selectedSong: ITunesSong?
    let selectSongVC = SelectSongTableViewController()

    private let semaphore = DispatchSemaphore(value: 0)
    
    init(presenter: UIViewController) {
        self.presenter = presenter
    }
    
    override func main() {
        DispatchQueue.main.async() {
            self.selectSongVC.delegate = self
            
            if let navigationController = self.presenter.navigationController {
                navigationController.pushViewController(self.selectSongVC, animated: true)
            }
            else {
                let navController = UINavigationController(rootViewController: self.selectSongVC)
                self.presenter.present(navController, animated: true)
            }
        }
        semaphore.wait()
    }
    
    func didSelectSong(song: ITunesSong) {
        selectedSong = song
        semaphore.signal()
    }
    
    func didFinish() {
        if let navigationController = presenter.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            selectSongVC.dismiss(animated: true, completion: nil)
        }
        semaphore.signal()
    }
}
