//
//  LottieLabelViewViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 20.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import UIKit
import Lottie

class LottieLabelViewController: UIViewController {
    let titleText: String
    let animationName: String

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var animationView: AnimationView!

    init(animationName: String,
         title: String) {
        self.titleText = title
        self.animationName = animationName
        super.init(nibName: "LottieLabelViewController",
                   bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.label.text = titleText
        self.animationView.animation = Animation.named(animationName)
        self.animationView.play()
        self.animationView.loopMode = .loop

        super.viewDidLoad()
    }
}
