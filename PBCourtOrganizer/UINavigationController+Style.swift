//
//  UINavigationBar+Style.swift
//  FarmLead
//
//  Created by Evelyn Eldridge on 2016-06-02.
//  Copyright © 2016 FarmLead. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
  
  func styleForPB () {
    navigationBar.barTintColor = kcolour.navBar
    navigationBar.tintColor = UIColor.white
    navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
  }
}
