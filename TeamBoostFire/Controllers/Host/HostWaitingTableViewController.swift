//
//  HostWaitingTableViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class HostWaitingTableViewController: UITableViewController {

    var tableViewDataSource: [String]

    init() {
        tableViewDataSource = [String]()
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let hostWaitingTableViewCell = UINib(nibName: "HostWaitingTableViewCell", bundle: nil)
        self.tableView.register(hostWaitingTableViewCell, forCellReuseIdentifier: "HostWaitingTableViewCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableViewDataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostWaitingTableViewCell", for: indexPath) as! HostWaitingTableViewCell
        cell.participantName.text = self.tableViewDataSource[indexPath.row]
        return cell
    }

}
