//
//  RestaurantDetailHeaderView.swift
//  FoodPin
//
//  Created by wyn on 2020/3/31.
//  Copyright © 2020 AppCoda. All rights reserved.
//

import UIKit

class RestaurantDetailHeaderView: UIView {

    @IBOutlet var ratingImageView: UIImageView!
    
    @IBOutlet var heartImageView: UIImageView! {
        didSet {
            heartImageView.image = UIImage(named: "heart-tick")?.withRenderingMode(.alwaysTemplate)
            heartImageView.tintColor = .white
        }
    }
    @IBOutlet var nameLabel: UILabel! {
        didSet {
            nameLabel.numberOfLines = 0
        }
    }
    @IBOutlet var typeLabel: UILabel! {
        didSet {
            typeLabel.layer.cornerRadius = 5.0
            typeLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet var headerImageView: UIImageView!

}
