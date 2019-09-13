//
//  ViewController.swift
//  Itunes API
//
//  Created by Alexey Voronov on 06/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit
import AVFoundation

class SelectSongTableViewController: UITableViewController, SearchTableViewCellDelegate {
    
    let itunes = ITunesApi()
    var songs: [ITunesSong] = []
    
    var downloadTask: URLSessionDownloadTask?
    var dataTask: URLSessionDataTask?
    
    var audioPlayer: AVAudioPlayer?
    var playingSong: ITunesSong?
    
    let searchCellId = "SearchTableViewCell"
    let songCellId = "SongTableViewCell"
    
    weak var delegate: SelectSongViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: searchCellId, bundle: nil), forCellReuseIdentifier: searchCellId)
        tableView.register(UINib(nibName: songCellId, bundle: nil), forCellReuseIdentifier: songCellId)
        
        if self.navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeAction))
        } else {
            
        }
        
        navigationController?.navigationBar.tintColor = .red
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            closeAction()
        }
    }
    
    @objc func closeAction() {
        audioPlayer?.stop()
        delegate?.didFinish()
    }
    
    @objc func doneAction() {
        if let selectedSong = playingSong { delegate?.didSelectSong(song: selectedSong) }
        closeAction()
    }
    
    func selectSong(song: ITunesSong) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        
        downloadTask?.cancel()
        downloadTask = itunes.downloadSong(url: song.previewUrl, id: song.id) {[weak self] (resultURL, error) in
            guard error == nil else { return }
            guard let songURL = resultURL else { return }
            self?.playingSong = song
            self?.playSong(url: songURL)
        }
    }
    
    func playSong(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf:  url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        }
        catch {
            assert(false, error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { return }
        let songToPlay = songs[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as? SongTableViewCell
        audioPlayer?.stop()
        if playingSong?.previewUrl == songToPlay.previewUrl {
            playingSong = nil
            cell?.setSelected(false, animated: false)
        }
        else {
            selectSong(song: songToPlay)
            cell?.setSelected(true, animated: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SongTableViewCell
        cell?.setSelected(false, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0  {
            let cell = tableView.dequeueReusableCell(withIdentifier: searchCellId) as! SearchTableViewCell
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: songCellId) as! SongTableViewCell
            let song = songs[indexPath.row]
            cell.setup(song: song)
            if playingSong?.previewUrl == song.previewUrl { cell.setSelected(true, animated: false) } else { cell.setSelected(false, animated: false) }
            return cell
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 } else { return songs.count }
    }
    
    func textFieldDidChange(text: String) {
        dataTask?.cancel()
        dataTask = itunes.searchMusic(name: text) { result, error in
            guard error == nil else { return }
            self.songs = result ?? []
            DispatchQueue.main.async {
                self.updateSongRows()
            }
        }
        navigationItem.rightBarButtonItem = nil
        audioPlayer?.stop()
    }
    
    func updateSongRows() {
        tableView.performBatchUpdates({
            if tableView.numberOfRows(inSection: 1) > songs.count {
                var indexPaths: [IndexPath] = []
                for i in songs.count..<tableView.numberOfRows(inSection: 1) {
                    indexPaths.append(IndexPath(item: i, section: 1))
                }
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            else if tableView.numberOfRows(inSection: 1) < songs.count {
                var indexPaths: [IndexPath] = []
                print(self.tableView.numberOfRows(inSection: 1))
                for i in self.tableView.numberOfRows(inSection: 1)..<songs.count {
                    indexPaths.append(IndexPath(item: i, section: 1))
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
            else if self.tableView.numberOfRows(inSection: 1) > 0 {
                var indexPaths: [IndexPath] = []
                for i in 0..<self.tableView.numberOfRows(inSection: 1) {
                    indexPaths.append(IndexPath(item: i, section: 1))
                }
                tableView.reloadRows(at: indexPaths, with: .automatic)
            }
        }, completion: nil)
    }
}
