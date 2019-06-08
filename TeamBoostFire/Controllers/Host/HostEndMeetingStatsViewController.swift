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

    var pieChartColourPalette = [UIColor]()

    @IBOutlet weak var pieChartView: PieChartView!
    var speakingTimesDataEntries = [PieChartDataEntry]()

    @IBOutlet weak var meetingAgendaLabel: UILabel!
    @IBOutlet weak var meetingDescriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true,
                                                          animated: true)

        populateLabelAndDescription()
        populateColourPalette()
        populatePieChart()
    }

    func populateLabelAndDescription() {
        guard let meetingStatistics = HostCoreServices.shared.meetingStatistics else {
            assertionFailure("Unable to retrieve meeting statistics")
            return
        }
        meetingAgendaLabel.text = meetingStatistics.agenda
        meetingDescriptionLabel.text = "Your meeting had \(meetingStatistics.numberOfParticipants) participants and lasted \(meetingStatistics.meetingLength.minutesAndSecondsPrettyString()) minutes"
    }

    func populateColourPalette() {

        pieChartColourPalette = [
            UIColor.blue,
            UIColor.brown,
            UIColor.cyan,
            UIColor.darkGray,
            UIColor.green,
            UIColor.magenta,
            UIColor.orange,
            UIColor.purple,
            UIColor.red,
            UIColor(red: 64/255, green: 92/255, blue: 117/255, alpha: 1.0)
            // 320D6D
        ]
    }

    func populatePieChart() {
        guard let meetingStats = HostCoreServices.shared.meetingStatistics else {
            assertionFailure("Meeting statistics not found in HostCoreServices")
            return
        }

        pieChartView.chartDescription?.text = "Participant Speaking Times"
        pieChartView.chartDescription?.font = NSUIFont(name: "HelveticaNeue", size: 12.0)!
        pieChartView.entryLabelFont = NSUIFont(name: "HelveticaNeue", size: 13.0)
        pieChartView.legend.font = NSUIFont(name: "HelveticaNeue", size: 10.0)!
        pieChartView.usePercentValuesEnabled = true

        let speakingTimes = meetingStats.participantSpeakingRecords
        speakingTimes.forEach { (arg0) in
            let (key, value) = arg0
            let dataEntry = PieChartDataEntry(value: Double(value), label: key, icon: nil, data: "nice!" as AnyObject)
            speakingTimesDataEntries.append(dataEntry)
        }

        updateChartData()
    }

    @IBAction func iAmDoneTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true,
                                           completion: nil)
    }

    func updateChartData() {
        let chartDataSet = PieChartDataSet(values: speakingTimesDataEntries, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)

        chartDataSet.colors = pieChartColourPalette
        pieChartView.data = chartData

    }
}
