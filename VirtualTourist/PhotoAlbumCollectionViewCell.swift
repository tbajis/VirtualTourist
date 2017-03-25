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
}
