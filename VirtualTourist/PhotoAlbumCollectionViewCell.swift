//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Thomas Manos Bajis on 3/16/17.
//  Copyright © 2017 Thomas Manos Bajis. All rights reserved.
//

import UIKit

// MARK: - PhotoAlbumCollectionViewCell: UICollectionViewCell

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    /*// MARK: Properties
    override var isSelected: Bool {
        didSet {
            photoAlbumCollectionImageView.layer.borderWidth = isSelected ? 10 : 0
        }
    }*/
    
    // MARK: Properties
    var taskToCancelIfCellReused: URLSessionTask? {
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
    // MARK: Outlets
    @IBOutlet weak var photoAlbumCollectionImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /* // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        photoAlbumCollectionImageView.layer.borderColor = UIColor(red: 0.45, green: 0.67, blue: 0.88, alpha: 1.0).cgColor
        isSelected = false
    }*/
}
