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
    weak var hostControllerService: MeetingControllerService?

    init() {
        tableViewDataSource = HostCoreServices.shared.allParticipants ?? [Participant]()
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

        cell.participantNameLabel.text = cellParticipant.name
        if let timeSpoken = hostControllerService?.participantTotalSpeakingRecord[participantIdentifier] {
            cell.speakingTimeLabel.text = timeSpoken.minutesAndSecondsPrettyString()
        }

        let speakerOrder = cellParticipant.speakerOrder

        let isCurrentSpeaker = (cellParticipant.speakerOrder == 0)
        if isCurrentSpeaker {
            cell.orderLabel.isHidden = true
            showAndAnimateRedCircle(for: cell)

        } else {
            hideRedAnimatingCircle(for: cell)
            showSpeakingOrderIfNeeded(for: cell, speakingOrder: speakerOrder)
        }

        return cell
    }

    private func showAndAnimateRedCircle(for cell: HostInMeetingTableViewCell) {
        cell.startCircleAnimation()
    }

    private func hideRedAnimatingCircle(for cell: HostInMeetingTableViewCell) {
        cell.stopCircleAnimation()
    }

    private func showSpeakingOrderIfNeeded(for cell: HostInMeetingTableViewCell,
                                           speakingOrder:Int) {
        if (HostCoreServices.shared.meetingParams?.moderationMode == MeetingMode.AutoModerated) {
            return
        }
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
        guard let index = tableViewDataSource.firstIndex(
            where: { $0.id == participantIdentifier }) else {
            assertionFailure("Unable to find participant in the table view datasource")
            return
        }

        let indexPath = IndexPath(row: index, section: 0)
        //tableView.reloadRows(at: [indexPath], with: .none)
        let cell = tableView.cellForRow(at: indexPath) as! HostInMeetingTableViewCell
        let cellParticipant = tableViewDataSource[indexPath.row]
        let participantIdentifier = cellParticipant.id

        if let timeSpoken = hostControllerService?.participantTotalSpeakingRecord[participantIdentifier] {
            cell.speakingTimeLabel.text = timeSpoken.minutesAndSecondsPrettyString()
        }

    }
}
