//
//  PlayerTableViewCell.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-21.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
