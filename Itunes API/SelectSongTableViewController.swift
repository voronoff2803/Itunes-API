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
        
        // COMMENT: кнопку отмены нужно добавлять только если нас презентовали через present(), не push; во втором случае будет стандартная кнопка back; можно проверить через количество viewControllers в navigationController'е прямо тут
        // COMMENT: тут лучше использовать barButtonSystemItem: .cancel
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(closeAction))
        
        navigationController?.navigationBar.tintColor = .red
    }
    
    @objc func closeAction() {
        audioPlayer?.stop()
        // COMMENT: закрывать UI нужно по другому если этот VC был презентован через present()
        // COMMENT: в данном случае можем перенести ответственность за закрытие в операцию добавив метод в делегат типа didFinish
        // COMMENT: также сейчас есть проблема что операция никогда не закончится если юзер сделает cancel
        navigationController?.popViewController(animated: true)
    }
    
    @objc func doneAction() {
        if let selectedSong = playingSong { delegate?.didSelectSong(song: selectedSong) }
        
        // COMMENT: вместо этого лучше вызвать closeAction
        audioPlayer?.stop()
        navigationController?.popViewController(animated: true)
    }
    
    func selectSong(song: ITunesSong) {
        // COMMENT: давай тут используем barButtonSystemItem: .done
        // COMMENT: при данном UI кнопку стоит прятать когда юзер редактирует поле поиска и выбранная песня пропадает из списка
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Выбрать", style: .plain, target: self, action: #selector(doneAction))
        
        downloadTask?.cancel()
        downloadTask = itunes.downloadSong(url: song.previewUrl, id: song.id) {[weak self] error, resultURL in
            guard error == nil else { return }
            self?.playingSong = song
            // COMMENT: force unwrap надо убрать
            self?.playSong(url: resultURL!)
        }
        
        // COMMENT: этот resume лучше вынести в itunes api
        downloadTask?.resume()
        
        // COMMENT: эту логику стоит перенести в itunes api; там можно просто вызвать completionblock если файл есть
        if downloadTask == nil {
            let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(song.id).m4a")
            playingSong = song
            playSong(url: url)
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
        guard indexPath.row != 0 else { return }
        let songToPlay = songs[indexPath.row - 1]
        let cell = tableView.cellForRow(at: indexPath) as? SongTableViewCell
        audioPlayer?.stop()
        if playingSong?.previewUrl == songToPlay.previewUrl {
            playingSong = nil
            cell?.setPlaying(playing: false)
        }
        else {
            selectSong(song: songToPlay)
            cell?.setPlaying(playing: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SongTableViewCell
        cell?.setPlaying(playing: false)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: searchCellId) as! SearchTableViewCell
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: songCellId) as! SongTableViewCell
            let song = songs[indexPath.row - 1]
            cell.setup(song: song)
            if playingSong?.previewUrl == song.previewUrl { cell.setPlaying(playing: true) } else { cell.setPlaying(playing: false) }
            return cell
        }
    }
    
    // COMMENT: у нас тут слишком много жонглирования с + / - 1 из-за search cell, предлагаю посадить ее в отдельную секцию и избавится от неё; иначе для читабельности придется вынести в отдельные методы типа song(forIndexPath), но в данном случае первое проще
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + songs.count
    }
    
    func textFieldDidChange(text: String) {
        dataTask?.cancel()
        dataTask = itunes.searchMusic(name: text) { error, result in
            guard error == nil else { return }
            self.songs = result ?? []
            DispatchQueue.main.async {
                self.updateSongRows()
            }
        }
        // COMMENT: этот resume лучше перенести в itunes api
        dataTask?.resume()
    }
    
    func updateSongRows() {
        tableView.performBatchUpdates({
            if tableView.numberOfRows(inSection: 0) - 1 > songs.count {
                var indexPaths: [IndexPath] = []
                for i in songs.count + 1..<tableView.numberOfRows(inSection: 0) {
                    indexPaths.append(IndexPath(item: i, section: 0))
                }
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
            else if tableView.numberOfRows(inSection: 0) - 1 < songs.count {
                var indexPaths: [IndexPath] = []
                for i in self.tableView.numberOfRows(inSection: 0)...songs.count {
                    indexPaths.append(IndexPath(item: i, section: 0))
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
            else if self.tableView.numberOfRows(inSection: 0) > 1 {
                var indexPaths: [IndexPath] = []
                for i in 1..<self.tableView.numberOfRows(inSection: 0) - 1 {
                    indexPaths.append(IndexPath(item: i, section: 0))
                }
                tableView.reloadRows(at: indexPaths, with: .automatic)
            }
        }, completion: nil)
    }
}
