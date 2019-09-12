//
//  SearchTableViewCellProtocol.swift
//  Itunes API
//
//  Created by Alexey Voronov on 07/09/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation

protocol SearchTableViewCellDelegate: class {
    func textFieldDidChange(text: String)
}
