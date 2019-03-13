//
//  ImageCache.swift
//  GiantBombSearch
//
//  Created by Jordan Jackson on 3/12/19.
//  Copyright © 2019 Perium. All rights reserved.
//

import Foundation
import UIKit

public class ImageCache {
    
    public static var cache: NSCache<NSString, UIImage> {
        let cache = NSCache<NSString, UIImage>()
        
        cache.name = "SLKImageCache"
        cache.countLimit = 20
        cache.totalCostLimit = 10*1024*1024
        
        return cache
    }
}
