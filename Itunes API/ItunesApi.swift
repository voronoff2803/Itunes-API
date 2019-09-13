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

    private func getRequest(endpoint: String, parametrs: [URLQueryItem], completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask? {
        var urlComponents = URLComponents(string: domain + endpoint)
        urlComponents?.queryItems = parametrs
        guard let url = urlComponents?.url else { assert(false); return nil }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            completion(data, nil)
        }
        
        dataTask.resume()
        return dataTask
    }
    
    typealias SearchCompletionBlock = ([ITunesSong]?, Error?) -> ()
    
    func searchMusic(name: String, completion: @escaping SearchCompletionBlock) -> URLSessionDataTask? {
        let parameters = [URLQueryItem(name: "media", value: "music"), URLQueryItem(name: "entity", value: "song"), URLQueryItem(name: "term", value: name)]
        
        return getRequest(endpoint: endpointSearch, parametrs: parameters) { data, error in
            guard error == nil, let resultData = data else { completion(nil, error); return }
            
            do {
                let songsSearchResult = try JSONDecoder().decode(ItunesSongsSearchResult.self, from: resultData)
                completion(songsSearchResult.results, nil)
            }
            catch {
                completion(nil, error); return
            }
        }
    }
    
    typealias DownloadSongCompletionBlock = (URL?, Error?) -> ()
    
    func downloadSong(url: URL, id: Int, completion: @escaping DownloadSongCompletionBlock) -> URLSessionDownloadTask? {
        let destinationURL = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(id).m4a")
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            completion(destinationURL, nil)
            return nil
        }
        
        let downloadTask = URLSession.shared.downloadTask(with: url) { urlData, response, error in
            guard error == nil, let songDataUrl = urlData else { completion(nil, error); return }
            do {
                try FileManager.default.copyItem(at: songDataUrl, to: destinationURL)
                completion(destinationURL, nil)
            }
            catch {
                completion(nil, error)
            }
        }
        
        downloadTask.resume()
        return downloadTask
    }
}
