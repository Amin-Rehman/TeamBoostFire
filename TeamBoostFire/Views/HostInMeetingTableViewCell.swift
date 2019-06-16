//
//  HostInMeetingTableViewCell.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import Lottie

class HostInMeetingTableViewCell: UITableViewCell {
    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var speakingTimeLabel: UILabel!
    @IBOutlet weak var circleAnimationView: AnimationView!
    private var circleAnimation: Animation!

    override func awakeFromNib() {
        super.awakeFromNib()
        circleAnimation = Animation.named("lottie_circle")
        circleAnimationView.animation = circleAnimation
        circleAnimationView.loopMode = .loop
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    public func startCircleAnimation() {
        circleAnimationView.isHidden = false
        circleAnimationView.play()
    }

    public func stopCircleAnimation() {
        circleAnimationView.isHidden = true
        circleAnimationView.stop()
    }
    
}
