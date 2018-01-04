//
//  TaskTableViewCell.swift
//  TaskScheduler
//
//  Created by Nikhil Cherukuri on 7/17/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
       
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
