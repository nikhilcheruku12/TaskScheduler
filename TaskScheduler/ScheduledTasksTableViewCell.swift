//
//  ScheduledTasksTableViewCell.swift
//  TaskScheduler
//
//  Created by Kuiren Su on 11/5/17.
//  Copyright © 2017 Nikhil Cherukuri. All rights reserved.
//

import UIKit

class ScheduledTasksTableViewCell: UITableViewCell {
    

    @IBOutlet weak var taskNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

