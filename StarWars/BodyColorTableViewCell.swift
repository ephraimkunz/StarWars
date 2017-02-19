//
//  BodyColorTableViewCell.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/11/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit

class BodyColorTableViewCell: UITableViewCell {
    @IBOutlet weak var eyecolorLabel: UILabel!
    @IBOutlet weak var skincolorLabel: UILabel!
    @IBOutlet weak var haircolorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
