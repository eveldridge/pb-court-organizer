//
//  CourtTableViewCell.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-20.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import UIKit

class CourtTableViewCell: UITableViewCell {

  @IBOutlet weak var courtLabel: UILabel!
  @IBOutlet weak var team1Label: UILabel!
  @IBOutlet weak var vsLabel: UIView!
  @IBOutlet weak var team2Label: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
