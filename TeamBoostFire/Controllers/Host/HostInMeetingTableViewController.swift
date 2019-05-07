//
//  HostInMeetingTableViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class HostInMeetingTableViewController: UITableViewController {
    var tableViewDataSource: [Participant]
    weak var speakerControllerService: SpeakerControllerService?

    init() {
        tableViewDataSource = CoreServices.shared.allParticipants ?? [Participant]()
        super.init(style: .plain)
        self.tableView.allowsSelection = false
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
        let participantIdentifier = cellParticipant.id
        let timeSpoken = speakerControllerService?.participantSpeakingRecord[participantIdentifier]

        cell.participantNameLabel.text = cellParticipant.name
        cell.speakingTimeLabel.text = String(timeSpoken!)
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
        let nextSpeakersToShow = 3
        if speakingOrder <= nextSpeakersToShow {
            cell.orderLabel.text = String(speakingOrder)
            cell.orderLabel.isHidden = false
        } else {
            cell.orderLabel.isHidden = true
        }
    }
}

extension HostInMeetingTableViewController: SpeakerControllerSecondTickObserver {
    func speakerSecondTicked(participantIdentifier: String) {
        guard let index = tableViewDataSource.firstIndex(where: { $0.id == participantIdentifier }) else {
            assertionFailure("Unable to find participant in the table view datasource")
            return
        }

        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
