//
//  SongTableViewCell.swift
//  Itunes API
//
//  Created by Alexey Voronov on 07/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songDescriptionLabel: UILabel!
    @IBOutlet weak var songAlbumImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func setup(song: ITunesSong) {
        songNameLabel.text = song.name
        songDescriptionLabel.text = song.artistName + " — " + song.albumName
        loadAlbumImage(url: song.albumImageUrl)
    }
    
    var currentAlbumImageURL: URL?
    
    func loadAlbumImage(url: URL) {
        currentAlbumImageURL = url
        songAlbumImageView.image = nil
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                guard let image = UIImage(data: data), url == self?.currentAlbumImageURL else { return }
                self?.songAlbumImageView.image = image
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            songNameLabel.textColor = .red
            self.backgroundColor = UIColor.init(white: 0.9, alpha: 1.0)
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = UIColor.white
            }
        } else {
            songNameLabel.textColor = .darkText
        }
    }
}
