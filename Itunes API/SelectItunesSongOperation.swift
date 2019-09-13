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

    private let semaphore = DispatchSemaphore(value: 0)
    
    init(presenter: UIViewController) {
        self.presenter = presenter
    }
    
    override func main() {
        DispatchQueue.main.async() {
            let selectSongVC = SelectSongTableViewController()
            selectSongVC.delegate = self
            
            if let navigationController = self.presenter.navigationController {
                navigationController.pushViewController(selectSongVC, animated: true)
            }
            else {
                let navController = UINavigationController(rootViewController: selectSongVC)
                self.presenter.present(navController, animated: true)
            }
        }
        semaphore.wait()
    }
    
    func didSelectSong(song: ITunesSong) {
        selectedSong = song
    }
    
    private var didFinish = false
    
    func didFinish(_ vc: SelectSongTableViewController, needsDismissing: Bool) {
        guard didFinish == false else { return }
        didFinish = true
        
        if needsDismissing { vc.navigationController.assertingNonNil?.popOrDismiss() }
        semaphore.signal()
    }
}

// MARK: -

fileprivate extension UINavigationController {
    
    func popOrDismiss() {
        if viewControllers.count > 1 { popViewController(animated: true) }
        else { presentingViewController.assertingNonNil?.dismiss(animated: true) }
    }
}
