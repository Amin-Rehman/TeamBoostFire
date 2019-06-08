//
//  HostEndMeetingStatsViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 07.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import Charts

class HostEndMeetingStatsViewController: UIViewController {
    @IBOutlet weak var pieChartView: PieChartView!

    var iosDataEntry = PieChartDataEntry(value: 0)
    var macDataEntry = PieChartDataEntry(value: 0)
    var macDataEntry2 = PieChartDataEntry(value: 0)

    var numberOfDownloadsDataEntries = [PieChartDataEntry]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true,
                                                          animated: true)

        pieChartView.chartDescription?.text = "Participant Speaking Times"
        pieChartView.entryLabelFont = NSUIFont(name: "HelveticaNeue", size: 16.0)

        iosDataEntry.value = 30
        iosDataEntry.label = "Participant 1"

        macDataEntry.value = 20
        macDataEntry.label = "Participant 2"

        macDataEntry2.value = 50
        macDataEntry2.label = "Participant 3"

        numberOfDownloadsDataEntries = [iosDataEntry, macDataEntry,macDataEntry2]

        updateChartData()
    }

    @IBAction func iAmDoneTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true,
                                           completion: nil)
    }

    func updateChartData() {
        let chartDataSet = PieChartDataSet(values: numberOfDownloadsDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        var colors = [UIColor]()
        for _ in 0..<chartDataSet.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))

            let color = UIColor(red: CGFloat(red/255),
                                green: CGFloat(green/255),
                                blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }

        chartDataSet.colors = colors
        pieChartView.data = chartData

    }
}
