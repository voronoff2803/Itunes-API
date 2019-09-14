//
//  FailableDecodable.swift
//  Itunes API
//
//  Created by Bogdan Pashchenko on 9/13/19.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

enum FailableDecodable<T: Decodable>: Decodable {
    case success(T)
    case failure(Error)
    
    init(from decoder: Decoder) throws {
        do {
            let decoded = try T(from: decoder)
            self = .success(decoded)
        } catch let error {
            self = .failure(error)
        }
    }
    
    var value: T? {
        switch self {
        case .success(let val): return val
        case .failure(_): return nil
        }
    }
}
