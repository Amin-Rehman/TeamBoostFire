//
//  HostWaitingViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import Lottie

class HostWaitingViewController: UIViewController {
    @IBOutlet weak var meetingCodeLabel: UILabel!
    @IBOutlet weak var childContainerView: UIView!
    @IBOutlet weak var spinnerView: AnimationView!

    var hostWaitingTableViewController = HostWaitingTableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        hostWaitingTableViewController.view.frame = childContainerView.bounds;
        hostWaitingTableViewController.willMove(toParent: self)
        childContainerView.addSubview(hostWaitingTableViewController.view)
        self.addChild(hostWaitingTableViewController)
        hostWaitingTableViewController.didMove(toParent: self)

        loadLottieSpinner()

        let meetingIdentifier = getHostDomain().meetingIdentifier
        meetingCodeLabel.text = meetingIdentifier
        let notificationName = Notification.Name(TeamBoostNotifications.participantListDidChange.rawValue)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(participantsListChanged(notification:)),
        name: notificationName, object: nil)

    }

    private func loadLottieSpinner() {
        spinnerView.animation = Animation.named("lottie_spinner")
        spinnerView.loopMode = .loop
        spinnerView.play()
    }

    @objc private func participantsListChanged(notification: NSNotification){
        let objects = notification.object as! [Participant]
        var participantNames = [String]()

        for object in objects {
            participantNames.append(object.name)
        }

        hostWaitingTableViewController.tableViewDataSource = participantNames
        hostWaitingTableViewController.tableView.reloadData()

    }

    // MARK: - Actions
    @IBAction func startMeetingClicked(_ sender: Any) {
        if hostWaitingTableViewController.tableViewDataSource.count == 0 {
            let alertController = UIAlertController(
                title: "No Participants in the meeting yet!",
                message: "Unable to start meeting till participants have joined the meeting.",
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(okAction)

            self.present(alertController, animated: true, completion: nil)
            return
        }

        AnalyticsService.shared.hostMeetingStarted()
        let hostDomain = getHostDomain()
        hostDomain.startMeeting()
        let meetingParams = hostDomain.meetingParams

        let hostHaveYourSayViewController = HostHaveYourSayViewController(with: meetingParams)
        self.navigationController?.pushViewController(hostHaveYourSayViewController, animated: true)
    }

    @IBAction func addParticipantManuallyClicked(_ sender: Any) {
    }

}
