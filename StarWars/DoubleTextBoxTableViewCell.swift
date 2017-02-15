//
//  DoubleTextBoxTableViewCell.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/14/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit

class DoubleTextBoxTableViewCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
