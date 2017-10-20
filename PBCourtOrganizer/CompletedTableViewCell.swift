//
//  CompletedTableViewCell.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-21.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import UIKit

class CompletedTableViewCell: UITableViewCell {
  @IBOutlet weak var completedSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
