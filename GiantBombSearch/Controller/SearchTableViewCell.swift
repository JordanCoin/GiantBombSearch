//
//  SearchTableViewCell.swift
//  GiantBombSearch
//
//  Created by Jordan Jackson on 3/12/19.
//  Copyright © 2019 Perium. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    var game: Game! {
        didSet {
            thumbnailImage(game: game)
            self.gameNameLabel.text = game.name
        }
    }
    
    @IBOutlet weak var gameThumbnailImageView: UIImageView!
    @IBOutlet weak var gameNameLabel: UILabel!
    
    override func prepareForReuse() {
        gameThumbnailImageView.image = nil
        super.prepareForReuse()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func thumbnailImage(game: Game) -> Void {
        if let thumbnailUrlString = game.thumbnailImageStringURL {
            URL(string: thumbnailUrlString)?.fetchImage(imageKey: thumbnailUrlString, completion: { (image, data) in
                DispatchQueue.main.async {
                    guard let data = data else {
                        self.gameThumbnailImageView.image = image
                        return
                    }
                    self.gameThumbnailImageView.image = UIImage(data: data)
                    //                self.saveImageDataToCoreData(favorite: favorite, imageData: data as NSData)
                }
            })
        }
    }
    
}
