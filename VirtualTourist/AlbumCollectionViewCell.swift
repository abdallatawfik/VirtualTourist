//
//  AlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Abdalla Tawfik on 8/8/17.
//  Copyright © 2017 AT Apps. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Helpers (Setting up the cell and Change selection state)
    
    func setupCell(withImage image:UIImage, loading:Bool) {
        imageView.image = image
        activityIndicator.isHidden = !loading
        
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func setSelected(selected:Bool) {
        if selected {
            self.imageView.alpha = 0.25
        } else {
            self.imageView.alpha = 1.0
        }
    }
}
