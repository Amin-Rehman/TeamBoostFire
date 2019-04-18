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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostInMeetingTableViewCell", for: indexPath) as! HostInMeetingTableViewCell
        cell.participantNameLabel.text = self.tableViewDataSource[indexPath.row].name
        let shouldHideRedCircle = !self.tableViewDataSource[indexPath.row].isActiveSpeaker
        cell.redCircleImage.isHidden = shouldHideRedCircle

        if !shouldHideRedCircle {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
                cell.redCircleImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: nil)
        }

        cell.orderLabel.isHidden = true
        return cell
    }


}
