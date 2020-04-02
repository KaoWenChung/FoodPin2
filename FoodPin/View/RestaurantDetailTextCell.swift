//
//  RestaurantDetailTextCell.swift
//  FoodPin
//
//  Created by wyn on 2020/3/31.
//  Copyright © 2020 AppCoda. All rights reserved.
//

import UIKit

class RestaurantDetailTextCell: UITableViewCell {
    @IBOutlet var descrsiptionLabel: UILabel! {
            didSet {
                descrsiptionLabel.numberOfLines = 0
            }
        }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
