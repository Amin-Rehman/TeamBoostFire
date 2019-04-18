//
//  HostInMeetingTableViewCell.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class HostInMeetingTableViewCell: UITableViewCell {
    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet weak var redCircleImage: UIImageView!
    @IBOutlet weak var orderLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
