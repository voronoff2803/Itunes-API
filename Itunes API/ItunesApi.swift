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
    
    func searchMusic(name: String, completion: @escaping (Error?, [ITunesSong]?) -> Void) -> URLSessionDataTask? {
        let parametrs = [URLQueryItem(name: "media", value: "music"),
                         URLQueryItem(name: "entity", value: "song"),
                         URLQueryItem(name: "term", value: name)]
        let dataTask = getRequest(endpoint: endpointSearch, parametrs: parametrs) { error, result in
            
            guard error == nil else { completion(error, nil); return }
            guard let resultDict = result else { completion(error, nil); return }
            guard let songsDict = resultDict["results"] as? [[String: Any]] else { completion(error, nil); return }

            var songs: [ITunesSong] = []
            for songDict in songsDict {
                guard let song = self.songFromDict(songDict: songDict) else { return }
                songs.append(song)
            }
            completion(nil, songs)
        }
        return dataTask
    }

    func songFromDict(songDict: [String: Any]) -> ITunesSong? {
        guard let previewUrl = URL(string: songDict["previewUrl"] as? String ?? "") else { return nil }
        guard let albumImageUrl = URL(string: songDict["artworkUrl60"] as? String ?? "") else { return nil }
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
    
    
    func downloadSong(url: URL, id: Int, completion: @escaping (Error?, URL?) -> Void) -> URLSessionDownloadTask? {
        let destinationURL = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(id).m4a")
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            return nil
        }
        else {
            let downloadTask = URLSession.shared.downloadTask(with: url) { urlData, response, error in
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
