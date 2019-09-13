//
//  Optional+AssertNonNil.swift
//  Itunes API
//
//  Created by Bogdan Pashchenko on 9/13/19.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

extension Optional {
    var assertingNonNil: Optional {
        assert(self != nil)
        return self
    }
}
