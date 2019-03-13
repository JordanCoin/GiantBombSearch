//
//  Networking.swift
//  GiantBombSearch
//
//  Created by Jordan Jackson on 3/12/19.
//  Copyright © 2019 Perium. All rights reserved.
//

import Foundation
import UIKit

class Networking: NSObject {
    
    static let shared = Networking()
    var urlSession = URLSession.shared
    
    let BASE_URL = "https://www.giantbomb.com/api/search/?api_key=c504638e740339650bdff41571cdba815e861255&format=json&query={searchInput}&resources=game"
    
    enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    
    func searchGames(searchInput: String, completion: @escaping (Result<[Game]>) -> Void) {
        
        func sendError(_ error: String) {
            let userInfo = [NSLocalizedDescriptionKey : error]
            completion(.failure(NSError(domain: "taskForFetchGamesMethod", code: 1, userInfo: userInfo)))
        }
        
        guard let stringURL = substituteKeyInMethod(BASE_URL, key: "searchInput", value: searchInput) else { return }
        
        guard let url = URL(string: stringURL) else { return }
        print(url)
        let urlRequest = URLRequest(url: url)
        
        // create a data task and handle each case
        urlSession.dataTask(with: urlRequest) { (data, response, error) in
            
            guard (error == nil) else {
                sendError("Error fetching reddit posts. " + error!.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Error getting a status code between 200 and 299")
                return
            }
            
            guard let data = data else {
                sendError("No data found from the request")
                return
            }
            
            var games = [Game]()
            
            do {
                print("Trying to parse data...")

                if let gamesList = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    guard let resultsDictionary = gamesList["results"] as? [[String: Any]] else { return }
                    
                    for result in resultsDictionary {
                        guard let imageList = result["image"] as? [String: Any] else { return }
                        
                        // thumbnail might not be avaliable
                        let thumbnailUrlString = imageList["thumb_url"] as? String
                        
                        guard let deck = result["deck"] as? String else { return }
                        guard let name = result["name"] as? String else { return }
                        
                        guard let giantBombURL = result["site_detail_url"] as? String else { return }
                        
                        let game = Game(name: name, description: deck, giantBombURL: giantBombURL, thumbnailImageStringURL: thumbnailUrlString)
                        
                        print(game.giantBombURL)
                        games.append(game)
                        
                        
                    }
                    
                }
                completion(.success(games))
                
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                completion(.failure(NSError(domain: "convertData", code: 1, userInfo: userInfo)))
            }
            }.resume()
        
    }
    
    // substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
}

// MARK: - Image Cache URL Extension

extension URL {
    
    public typealias ImageCacheCompletion = (UIImage, Data?) -> Void
    
    public func fetchImage(imageKey: String, completion: @escaping ImageCacheCompletion) {
        
        if let image = ImageCache.cache.object(forKey: imageKey as NSString) {
            completion(image, nil)
            return
        } else {
            
            URLSession.shared.dataTask(with: self, completionHandler: { (data, response, error) in
                guard error == nil else { return }
                guard data != nil else { return }
                
                if let image = UIImage(data: data!) {
                    ImageCache.cache.setObject(image, forKey: imageKey as NSString)
                    completion(image, data!)
                    return
                }
            }).resume()
        }
    }
}
