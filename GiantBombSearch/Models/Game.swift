//
//  Game.swift
//  GiantBombSearch
//
//  Created by Jordan Jackson on 3/12/19.
//  Copyright © 2019 Perium. All rights reserved.
//

import Foundation
import UIKit

struct Game {
    var name: String
    var description: String
    var giantBombURL: String
    var thumbnailImageStringURL: String?
    
    init(name: String, description: String, giantBombURL: String, thumbnailImageStringURL: String?) {
        self.name = name
        self.description = description
        self.giantBombURL = giantBombURL
        self.thumbnailImageStringURL = thumbnailImageStringURL
    }
}
