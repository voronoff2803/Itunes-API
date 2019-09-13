//
//  UIView+decoration.swift
//  ITMO
//
//  Created by Alexey Voronov on 01/08/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return self.layer.cornerRadius }
        set { self.layer.cornerRadius = newValue }
    }
}
