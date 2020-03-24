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

        pieChartView.animate(xAxisDuration: 2.0,
                             yAxisDuration: 2.0,
                             easingOption: .easeInSine)
        pieChartView.holeRadiusPercent = 0.10
        pieChartView.transparentCircleRadiusPercent = 0.20

        populateLabelAndDescription()
        populateColourPalette()
        populatePieChart()
    }

    func populateLabelAndDescription() {
        guard let meetingStatistics =  teamBoostKitDomainInstance().meetingStatistics else {
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
        guard let meetingStats = teamBoostKitDomainInstance().meetingStatistics else {
            assertionFailure("Meeting statistics not found in HostDomain")
            return
        }

        pieChartView.chartDescription?.text = "Participant % Speaking Times"
        pieChartView.chartDescription?.font = NSUIFont(name: "HelveticaNeue", size: 12.0)!
        pieChartView.entryLabelFont = NSUIFont(name: "HelveticaNeue-Bold", size: 18.0)
        pieChartView.entryLabelColor = NSUIColor.black

        pieChartView.legend.font = NSUIFont(name: "HelveticaNeue", size: 10.0)!
        pieChartView.usePercentValuesEnabled = true

        let speakingTimes = meetingStats.participantSpeakingRecords
        speakingTimes.forEach { (arg0) in
            let (key, value) = arg0
            let dataEntry = PieChartDataEntry(value: Double(value), label: key)
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
        chartDataSet.colors = ChartColorTemplates.colorful().shuffled()
        pieChartView.data = chartData
    }
}
