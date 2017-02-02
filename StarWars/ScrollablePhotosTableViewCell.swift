//
//  ScrollablePhotosTableViewCell.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/2/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit

class ScrollablePhotosTableViewCell: UITableViewCell {
    @IBOutlet weak var outerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
