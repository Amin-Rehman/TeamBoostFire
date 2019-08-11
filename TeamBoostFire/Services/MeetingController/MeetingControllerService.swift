import Foundation

protocol SpeakerControllerOrderObserver: class {
    /**
     Method to indicate that the speaker order has changed and the observer can fetch the new
     order from CoreServices

     Pass in the total speaking time that the observer can use; for example to update the progress view in the cell
     */
    func speakingOrderUpdated(totalSpeakingRecord: [ParticipantId: SpeakingTime])
}


protocol SpeakerControllerSecondTickObserver: class {
    /**
     Indicate that the speaking time for a particular participant changed
     */
    func speakerSecondTicked(participantIdentifier: String)
}

typealias ParticipantId = String
typealias SpeakingTime = Int

typealias ParticipantSpeakingRecord = [ParticipantId: SpeakingTime]

class MeetingControllerService {
    let meetingParams: MeetingsParams
    weak var orderObserver: SpeakerControllerOrderObserver?
    private var speakerTimer: Timer?
    private var secondTickTimer: Timer?
    private let meetingMode: MeetingMode

    // To be updated for every round if speaking time needs to be adjusted
    private var participantSpeakingRecordPerRound = [SpeakerRecord]()

    public private(set) var participantTotalSpeakingRecord = ParticipantSpeakingRecord()
    public weak var speakerSecondTickObserver: SpeakerControllerSecondTickObserver?

    private var indexForParticipantRoundSpeakingTime = 0

    init(meetingParams: MeetingsParams,
         orderObserver: SpeakerControllerOrderObserver,
         meetingMode: MeetingMode = .Uniform) {
        self.meetingParams = meetingParams
        self.orderObserver = orderObserver
        self.meetingMode = meetingMode

        setupParticipantSpeakingRecord()

        if meetingMode == .AutoModerated {
            shuffleSpeakerOrder()
        }

        startSpeakerTimerForCurrentRound()
        // First second gets missed so brute force the first secondTicked
        secondTicked()
        startSecondTickerTimer()
        setupParticipantIsDoneInterrupt()
    }

    // MARK: - Public API(s)
    @objc public func goToNextSpeaker() {

        switch meetingMode {
        case .Uniform:
            rotateSpeakerOrder()
        case .AutoModerated:
            indexForParticipantRoundSpeakingTime = indexForParticipantRoundSpeakingTime + 1
            rotateSpeakerOrder()
        }

    }

    public func endMeeting() {
        stopSecondTickerTimer()
        stopSpeakerRoundTimer()
    }

    // MARK: - Private API(s)

    private func setupParticipantIsDoneInterrupt() {
        let notificationName = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(participantIsDoneInterrupt(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func participantIsDoneInterrupt(notification: NSNotification) {        
        goToNextSpeaker()
    }

    private func setupParticipantSpeakingRecord() {
        guard let allParticipantIdentifiers = HostCoreServices.shared.speakerOrder else {
            assertionFailure("Unable to retrieve speaking order during setupParticipantSpeakingRecord")
            return
        }

        for identifiers in allParticipantIdentifiers {
            participantTotalSpeakingRecord[identifiers] = 0
        }

        // Start off with some defaults
        allParticipantIdentifiers.forEach { identifier in
            participantSpeakingRecordPerRound.append(SpeakerRecord(participantId: identifier,
                                                                   speakingTime: meetingParams.maxTalkTime))
        }
    }

    @objc private func rotateSpeakerOrder() {
        stopSecondTickerTimer()
        stopSpeakerRoundTimer()

        guard var speakingOrder = HostCoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.circularRotate()
        HostCoreServices.shared.updateSpeakerOrder(with: speakingOrder)
        orderObserver?.speakingOrderUpdated(totalSpeakingRecord: participantTotalSpeakingRecord)

        startSecondTickerTimer()
        startSpeakerTimerForCurrentRound()

    }

    @objc private func secondTicked() {
        guard let speakerOrder = HostCoreServices.shared.speakerOrder,
            let currentSpeakerIdentifier = speakerOrder.first else {
            assertionFailure("Unable to retrieve current speaker")
            return
        }

        guard var speakerTime = participantTotalSpeakingRecord[currentSpeakerIdentifier] else {
            assertionFailure("Unable to retrieve speaker time")
            return
        }

        speakerTime = speakerTime + 1
        participantTotalSpeakingRecord[currentSpeakerIdentifier] = speakerTime
        speakerSecondTickObserver?.speakerSecondTicked(participantIdentifier: currentSpeakerIdentifier)
    }

    private func shuffleSpeakerOrder() {
        guard var speakingOrder = HostCoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.shuffled()
        HostCoreServices.shared.updateSpeakerOrder(with: speakingOrder)
    }

    private func startSecondTickerTimer() {
        secondTickTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                               selector: #selector(secondTicked),
                                               userInfo: nil, repeats: true)
    }

    private func stopSecondTickerTimer() {
        secondTickTimer?.invalidate()
        secondTickTimer = nil
    }

    // MARK :- Speaker timer
    private func startSpeakerTimerForCurrentRound() {

        switch meetingMode {
        case .Uniform:
            speakerTimer = Timer.scheduledTimer(timeInterval: Double(meetingParams.maxTalkTime), target: self,
                                                selector: #selector(goToNextSpeaker),
                                                userInfo: nil, repeats: false)
        case .AutoModerated:
            let isNewRound = indexForParticipantRoundSpeakingTime == participantSpeakingRecordPerRound.count

            if isNewRound {
                indexForParticipantRoundSpeakingTime = 0
                participantSpeakingRecordPerRound = MeetingOrderEvaluator.evaluateOrder(
                    participantTotalSpeakingRecord: participantTotalSpeakingRecord,
                    maxTalkingTime: meetingParams.maxTalkTime)!

                print("participantSpeakingRecordPerRound: \(participantSpeakingRecordPerRound)")

                var newSpeakingOrder = [String]()
                participantSpeakingRecordPerRound.forEach { (speakerRecord) in
                    newSpeakingOrder.append(speakerRecord.participantId)
                }
                HostCoreServices.shared.updateSpeakerOrder(with: newSpeakingOrder)
                orderObserver?.speakingOrderUpdated(totalSpeakingRecord: participantTotalSpeakingRecord)
            }

            speakerTimer = Timer.scheduledTimer(timeInterval:
                Double(participantSpeakingRecordPerRound[indexForParticipantRoundSpeakingTime].speakingTime),
                                                target: self,
                                                selector: #selector(goToNextSpeaker),
                                                userInfo: nil, repeats: false)
        }
    }

    private func stopSpeakerRoundTimer() {
        speakerTimer?.invalidate()
        speakerTimer = nil
    }
}

