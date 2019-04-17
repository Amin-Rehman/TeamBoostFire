//
//  ParticipantLobbyViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class ParticipantLobbyViewController: UIViewController {

    @IBOutlet weak var lobbyImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.lobbyImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
    }

}
