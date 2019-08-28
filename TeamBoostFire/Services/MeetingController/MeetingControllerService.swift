import Foundation

typealias ParticipantId = String
typealias SpeakingTime = Int

class MeetingControllerService {
    let meetingParams: MeetingsParams
    weak var orderObserver: SpeakerControllerOrderObserver?
    private var speakerTimer: Timer?
    private let meetingMode: MeetingMode

    private var indexForParticipantRoundSpeakingTime = 0

    public lazy var storage: MeetingControllerStorage = {

        guard let allParticipantIdentifiers = HostCoreServices.shared.speakerOrder else {
            assertionFailure("Unable to retrieve speaking order during setupParticipantSpeakingRecord")
            return MeetingControllerStorage(with: [], maxTalkTime: 0)
        }
        let controllerStorage = MeetingControllerStorage(with: allParticipantIdentifiers,
                                                         maxTalkTime: meetingParams.maxTalkTime)
        return controllerStorage
    }()

    public lazy var meetingControllerSecondTicker: MeetingControllerSecondTicker = {
        // FIXME
        return MeetingControllerSecondTicker(with: self.storage)
    }()

    init(meetingParams: MeetingsParams,
         orderObserver: SpeakerControllerOrderObserver,
         meetingMode: MeetingMode = .Uniform) {
        self.meetingParams = meetingParams
        self.orderObserver = orderObserver
        self.meetingMode = meetingMode

        if meetingMode == .AutoModerated {
            shuffleSpeakerOrder()
        }

        self.meetingControllerSecondTicker.startSecondTickerTimer()
        startSpeakerTimerForCurrentRound()
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
        self.meetingControllerSecondTicker.stopSecondTickerTimer()
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


    @objc private func rotateSpeakerOrder() {
        self.meetingControllerSecondTicker.stopSecondTickerTimer()
        stopSpeakerRoundTimer()

        guard var speakingOrder = HostCoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.circularRotate()
        HostCoreServices.shared.updateSpeakerOrder(with: speakingOrder)
        orderObserver?.speakingOrderUpdated(totalSpeakingRecord: storage.participantTotalSpeakingRecord)

        self.meetingControllerSecondTicker.startSecondTickerTimer()
        startSpeakerTimerForCurrentRound()

    }

    private func shuffleSpeakerOrder() {
        guard var speakingOrder = HostCoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.shuffled()
        HostCoreServices.shared.updateSpeakerOrder(with: speakingOrder)
    }

    // MARK :- Speaker timer
    private func startSpeakerTimerForCurrentRound() {

        switch meetingMode {
        case .Uniform:
            speakerTimer = Timer.scheduledTimer(timeInterval: Double(meetingParams.maxTalkTime), target: self,
                                                selector: #selector(goToNextSpeaker),
                                                userInfo: nil, repeats: false)
        case .AutoModerated:
            let isNewRound = indexForParticipantRoundSpeakingTime == storage.participantSpeakingRecordPerRound.count

            if isNewRound {
                indexForParticipantRoundSpeakingTime = 0
                let speakingRecordForNewRound = MeetingOrderEvaluator.evaluateOrder(
                    participantTotalSpeakingRecord: storage.participantTotalSpeakingRecord,
                    maxTalkingTime: meetingParams.maxTalkTime)!
                storage.updateSpeakingRecordForCurrentRound(speakingRecord: speakingRecordForNewRound)

                HostCoreServices.shared.updateSpeakerOrder(with: storage.speakingRecord)
                orderObserver?.speakingOrderUpdated(totalSpeakingRecord: storage.participantTotalSpeakingRecord)
            }

            speakerTimer = Timer.scheduledTimer(
                timeInterval:
                Double(storage.participantSpeakingRecordPerRound[indexForParticipantRoundSpeakingTime].speakingTime),
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

