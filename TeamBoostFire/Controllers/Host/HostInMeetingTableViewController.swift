//
//  HostInMeetingTableViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class HostInMeetingTableViewController: UITableViewController, SpeakerControllerSecondTickObserver {
    var tableViewDataSource: [Participant]
    weak var speakerControllerService: SpeakerControllerService?

    init() {
        self.tableViewDataSource = CoreServices.shared.allParticipants ?? [Participant]()
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let hostInMeetingTableViewCell = UINib(nibName: "HostInMeetingTableViewCell", bundle: nil)
        self.tableView.register(hostInMeetingTableViewCell, forCellReuseIdentifier: "HostInMeetingTableViewCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostInMeetingTableViewCell",
                                                 for: indexPath) as! HostInMeetingTableViewCell
        let cellParticipant = tableViewDataSource[indexPath.row]
        cell.participantNameLabel.text = cellParticipant.name
        let speakerOrder = cellParticipant.speakerOrder

        let isCurrentSpeaker = (cellParticipant.speakerOrder == 0)

        if isCurrentSpeaker {
            showAndAnimateRedCircle(for: cell)
            cell.orderLabel.isHidden = true
        } else {
            hideRedAnimatingCircle(for: cell)
            showSpeakingOrderIfNeeded(for: cell, speakingOrder: speakerOrder)
        }

        return cell
    }

    private func showAndAnimateRedCircle(for cell: HostInMeetingTableViewCell) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            cell.redCircleImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
        cell.redCircleImage.isHidden = false
    }

    private func hideRedAnimatingCircle(for cell: HostInMeetingTableViewCell) {
        cell.redCircleImage.transform = .identity
        cell.redCircleImage.isHidden = true
    }

    private func showSpeakingOrderIfNeeded(for cell: HostInMeetingTableViewCell,
                                           speakingOrder:Int) {
        if speakingOrder < 3 {
            cell.orderLabel.text = String(speakingOrder)
            cell.orderLabel.isHidden = false
        } else {
            cell.orderLabel.isHidden = true
        }
    }

    func speakerSecondTicked() {
        print("Speaker second tick!")
    }

}
