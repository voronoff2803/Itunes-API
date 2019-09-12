//
//  SearchTableViewCell.swift
//  Itunes API
//
//  Created by Alexey Voronov on 07/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    weak var delegate: SearchTableViewCellDelegate?
    
    @IBOutlet weak var searchField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        searchField.delegate = self
        
        searchField.addTarget(self, action: #selector(searchFieldChange), for: .editingChanged)
    }
    
    @objc func searchFieldChange() {
        delegate?.textFieldDidChange(text: searchField.text ?? "")
    }

}

