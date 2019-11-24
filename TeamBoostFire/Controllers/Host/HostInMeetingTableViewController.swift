//
//  HostInMeetingTableViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class HostInMeetingTableViewController: UITableViewController {
    /**
     Map used to update the UIView width to indicate the progress view.
     This progress view indicates the % of time the user spoke in the Host Meeting View Cell
     */
    var participantIdSpeakingFactorMap =  [ParticipantId : SpeakingFactor]()
    var tableViewDataSource: [Participant]
    weak var hostControllerService: HostMeetingControllerService?

    init() {
        tableViewDataSource = HostCoreServices.shared.allParticipants ?? [Participant]()
        super.init(style: .plain)
        self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = false

        let notificationName = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTableViewWithSpeakerOrder),
                                               name: notificationName, object: nil)
    }

    @objc public func updateTableViewWithSpeakerOrder() {
        tableViewDataSource = HostCoreServices.shared.allParticipants!
        tableView.reloadData()
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
        if let timeSpoken = hostControllerService?.storage.participantTotalSpeakingRecord[participantIdentifier] {
            cell.speakingTimeLabel.text = timeSpoken.minutesAndSecondsPrettyString()
        }

        let currentSpeakerIdentifier = HostCoreServices.shared.speakerOrder?[0]
        let speakerOrder = cellParticipant.speakerOrder

        let isCurrentSpeaker = participantIdentifier == currentSpeakerIdentifier
        if isCurrentSpeaker {
            cell.orderLabel.isHidden = true
            showAndAnimateRedCircle(for: cell)

        } else {
            hideRedAnimatingCircle(for: cell)
            showSpeakingOrderIfNeeded(for: cell, speakingOrder: speakerOrder)
        }



        // Update progressViewFactor
        let evenCellColor = UIColor(red: 0.75,
                                    green: 0.92,
                                    blue: 0.99,
                                    alpha: 1.0)

        let oddCellColor = UIColor(red: 0.86,
                                   green: 0.86,
                                   blue: 0.86,
                                   alpha: 1.0)

        let participantSpeakingFactor = participantIdSpeakingFactorMap[participantIdentifier]
        if participantSpeakingFactor != nil {
            let color = indexPath.row % 2 == 0 ? evenCellColor : oddCellColor
            cell.updateProgress(to: participantSpeakingFactor!, color: color)
        } else {
            cell.updateProgress(to: 0.0, color: UIColor.clear)
        }


        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let participantId = tableViewDataSource[indexPath.row].id
        hostControllerService?.forceSpeakerChange(participantId: participantId)

        let totalSpeakingTimeMap = hostControllerService?.storage.participantTotalSpeakingRecord
        participantIdSpeakingFactorMap = SpeakerFactorable.mapToSpeakingFactor(from: totalSpeakingTimeMap!)
        updateTableViewWithSpeakerOrder()
    }
}

// MARK: - Private Helpers
extension HostInMeetingTableViewController {
    private func showAndAnimateRedCircle(for cell: HostInMeetingTableViewCell) {
        cell.startCircleAnimation()
    }

    private func hideRedAnimatingCircle(for cell: HostInMeetingTableViewCell) {
        cell.stopCircleAnimation()
    }

    private func showSpeakingOrderIfNeeded(for cell: HostInMeetingTableViewCell,
                                           speakingOrder:Int) {
        if (HostCoreServices.shared.meetingParams?.moderationMode == MeetingMode.AutoModerated) {
            cell.orderLabel.isHidden = true
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

// MARK: - SpeakerControllerSecondTickObserver Delegate methods
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

        if let timeSpoken = hostControllerService?.storage.participantTotalSpeakingRecord[participantIdentifier] {
            cell.speakingTimeLabel.text = timeSpoken.minutesAndSecondsPrettyString()
        }

    }
}

extension HostInMeetingTableViewController: ParticipantSelectableProtocol {
    func selectedParticipant(participantId: String) {
        hostControllerService?.forceSpeakerChange(participantId: participantId)
    }
}
