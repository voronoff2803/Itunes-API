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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        if self.navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        }
        
        navigationController?.navigationBar.tintColor = .red
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent { close(needsDismissing: false) }
    }
    
    func close(needsDismissing: Bool) {
        audioPlayer?.stop()
        delegate?.didFinish(self, needsDismissing: needsDismissing)
    }
    
    @objc func cancelAction() {
        close(needsDismissing: true)
    }
    
    @objc func doneAction() {
        if let selectedSong = playingSong { delegate?.didSelectSong(song: selectedSong) }
        close(needsDismissing: true)
    }
    
    func pauseCurrentOrPlayNew(withCell cell: SongTableViewCell, andSong song: ITunesSong) {
        audioPlayer?.stop()
        
        if playingSong?.previewUrl == song.previewUrl {
            playingSong = nil
            cell.setSelected(false, animated: false)
        }
        else {
            selectSong(song: song)
            cell.setSelected(true, animated: false)
        }
    }
    
    func selectSong(song: ITunesSong) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        
        downloadTask?.cancel()
        downloadTask = itunes.downloadSong(url: song.previewUrl, id: song.id) {[weak self] (resultURL, error) in
            guard error == nil, let songURL = resultURL else { return }
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
        guard indexPath.section != 0, let cell = tableView.cellForRow(at: indexPath) as? SongTableViewCell else { return }
        pauseCurrentOrPlayNew(withCell: cell, andSong: songs[indexPath.row])
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
        deselectSelectedRow()
        dataTask = itunes.searchMusic(name: text) { result, error in
            guard error == nil else { return }
            self.songs = result ?? []
            self.updateSongRows()
        }
        navigationItem.rightBarButtonItem = nil
        audioPlayer?.stop()
    }
    
    func deselectSelectedRow() {
        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRowIndexPath, animated: false)
            playingSong = nil
        }
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
                for i in self.tableView.numberOfRows(inSection: 1)..<songs.count {
                    indexPaths.append(IndexPath(item: i, section: 1))
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }, completion: nil)
        tableView.performBatchUpdates({
            if self.tableView.numberOfRows(inSection: 1) > 0 {
                var indexPaths: [IndexPath] = []
                for i in 0..<songs.count {
                    indexPaths.append(IndexPath(item: i, section: 1))
                }
                tableView.reloadRows(at: indexPaths, with: .automatic)
            }
        }, completion: nil)
    }
}
