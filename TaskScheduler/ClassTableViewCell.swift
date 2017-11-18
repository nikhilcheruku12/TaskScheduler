//
//  ClassTableViewCell.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/7/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {
    @IBOutlet weak var importanceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var colorView: UIView!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
