//
//  GenderBirthyearTableViewCell.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/11/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit

class GenderBirthyearTableViewCell: UITableViewCell {
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthyearLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
