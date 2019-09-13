//
//  HostInMeetingTableViewCell.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import Lottie

protocol ProgressViewUpdatable {
    /*
     Update progress view
     Width factor needs to be between 0 and 1
     */
    func updateProgress(to widthFactor: Float, color: UIColor);
}

protocol ParticipantSelectableProtocol {
    func selectedParticipant(participantId: String)
}

class HostInMeetingTableViewCell: UITableViewCell {
    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var speakingTimeLabel: UILabel!
    @IBOutlet weak var circleAnimationView: AnimationView!
    private var circleAnimation: Animation!
    @IBOutlet weak var progressBackgroundView: UIView!

    @IBOutlet weak var progressViewWidthContraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        circleAnimation = Animation.named("lottie_circle")
        circleAnimationView.animation = circleAnimation
        circleAnimationView.loopMode = .loop

        // Not sure why we need this but whatevs
        //progressBackgroundView.sendSubviewToBack(speakingTimeLabel)
        //sendSubviewToBack(progressBackgroundView)
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

extension HostInMeetingTableViewCell: ProgressViewUpdatable {
    func updateProgress(to widthFactor: Float, color: UIColor) {
        // Lets assume the frame width is twice as wide so that in the UI it looks a bit better
        let cellViewWidth = frame.width * 2
        let widthOfProgressView = CGFloat(widthFactor) * cellViewWidth
        progressViewWidthContraint.constant = widthOfProgressView
        progressBackgroundView.backgroundColor = color
        progressBackgroundView.layoutIfNeeded()
    }
}
