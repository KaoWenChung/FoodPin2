//
//  UINavigationController+Ext.swift
//  FoodPin
//
//  Created by wyn on 2020/4/3.
//  Copyright © 2020 AppCoda. All rights reserved.
//

import UIKit

extension UINavigationController {

    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

}
