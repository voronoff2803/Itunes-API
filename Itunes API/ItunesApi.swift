//
//  Network.swift
//  Itunes API
//
//  Created by Alexey Voronov on 06/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation
import AVFoundation

class ITunesApi {
    
    private let domain = "https://itunes.apple.com/"
    private let endpointSearch = "search"
    
    private func getRequest(endpoint: String, parametrs: [URLQueryItem], completion: @escaping (Error?, [String: Any]?) -> Void) -> URLSessionDataTask? {
        guard var urlComponents = URLComponents(string: domain + endpoint) else { return nil }
        urlComponents.queryItems = parametrs
        guard let url = urlComponents.url else { return nil }
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                // COMMENT: эти guard можно соединить в один
                guard let recivedData = data else { return }
                guard let result = try JSONSerialization.jsonObject(with: recivedData, options: []) as? [String: Any] else { return }
                completion(nil, result)
            }
            catch {
                completion(error, nil)
            }
        }
        return dataTask
    }
    
    // COMMENT: typealias на тип блока, пожалуйста; также в ios обычно первый параметр колбека успешный, ошибка на втором месте
    
    func searchMusic(name: String, completion: @escaping (Error?, [ITunesSong]?) -> Void) -> URLSessionDataTask? {
        let parameters = [URLQueryItem(name: "media", value: "music"), URLQueryItem(name: "entity", value: "song"), URLQueryItem(name: "term", value: name)]
        let dataTask = getRequest(endpoint: endpointSearch, parametrs: parameters) { error, result in
            
            // COMMENT: эти guard можно соединить в один
            guard error == nil else { completion(error, nil); return }
            guard let resultDict = result else { completion(error, nil); return }
            guard let songsDict = resultDict["results"] as? [[String: Any]] else { completion(error, nil); return }
            
            // COMMENT: тут вместо этого цикла лучше compactMap
            var songs: [ITunesSong] = []
            for songDict in songsDict {
                guard let song = self.songFromDict(songDict: songDict) else { return }
                songs.append(song)
            }
            completion(nil, songs)
        }
        return dataTask
    }
    
    // COMMENT: эту функцию можно вынести в ItunesSong как init(withItunesSongDict dict: [String : Any])
    func songFromDict(songDict: [String: Any]) -> ITunesSong? {
        // COMMENT: эти guard можно соединить в один
        guard let previewUrl = URL(string: songDict["previewUrl"] as? String ?? "") else { return nil }
        guard let albumImageUrl = URL(string: songDict["artworkUrl60"] as? String ?? "") else { return nil }
        // COMMENT: бывают ли песни где одхого из этих параметров может не быть? Если нет, можно вынести все проверки и кастования из кода ниже в guard и в его else вызвать assert
        let song = ITunesSong(id: songDict["trackId"] as? Int ?? 0,
                              name: songDict["trackName"] as? String ?? "",
                              censoredName: songDict["trackCensoredName"] as? String ?? "",
                              trackTime: songDict["trackTimeMillis"] as? Int ?? 0,
                              artistName: songDict["artistName"] as? String ?? "",
                              albumName: songDict["collectionName"] as? String ?? "",
                              previewUrl: previewUrl,
                              albumImageUrl: albumImageUrl)
        return song
    }
    
    // COMMENT: typealias на тип блока, пожалуйста; также в ios обычно первый параметр колбека успешный, ошибка на втором месте
    func downloadSong(url: URL, id: Int, completion: @escaping (Error?, URL?) -> Void) -> URLSessionDownloadTask? {
        let destinationURL = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(id).m4a")
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            // вот тут перед возвращением nil можно сразу вызвать completion
            return nil
        }
            // COMMENT: тут else излишен, т.к. в теле if есть return
        else {
            let downloadTask = URLSession.shared.downloadTask(with: url) { urlData, response, error in
                // COMMENT: эти guard можно соединить в один
                guard error == nil else { completion(error, nil); return }
                guard let songDataUrl = urlData else {completion(nil, nil); return }
                do {
                    try FileManager.default.copyItem(at: songDataUrl, to: destinationURL)
                    completion(nil, destinationURL)
                }
                catch {
                    completion(error, nil)
                }
            }
            return downloadTask
        }
    }
}
