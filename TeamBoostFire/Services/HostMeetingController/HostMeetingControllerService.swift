import Foundation

public typealias ParticipantId = String
typealias SpeakingTime = Int

class HostMeetingControllerService: MeetingControllerCurrentRoundTickerObserver {
    let meetingParams: MeetingsParams
    weak var orderObserver: SpeakerControllerOrderObserver?
    private let meetingMode: MeetingMode
    private let coreServices: HostCoreServices

    public lazy var storage: MeetingControllerStorage = {

        guard let allParticipantIdentifiers = coreServices.speakerOrder else {
            assertionFailure("Unable to retrieve speaking order during setupParticipantSpeakingRecord")
            return MeetingControllerStorage(with: [], maxTalkTime: 0,
                                            coreServices: coreServices)
        }
        let controllerStorage = MeetingControllerStorage(with: allParticipantIdentifiers,
                                                         maxTalkTime: meetingParams.maxTalkTime, coreServices: coreServices)
        return controllerStorage
    }()

    public lazy var meetingControllerSecondTicker: MeetingControllerSecondTicker = {
        return MeetingControllerSecondTicker(with: self.storage,
                                             coreServices: coreServices)
    }()

    public lazy var meetingControllerCurrentSpeakerTicker: MeetingControllerCurrentSpeakerTicker = {
        let speakerTickerTimerController = TeamBoostTimerController()
        return MeetingControllerCurrentSpeakerTicker(with: self.storage,
                                                   meetingMode: self.meetingMode,
                                                   maxTalkTime: self.meetingParams.maxTalkTime,
                                                   observer: self, timerController: speakerTickerTimerController)
    }()

    init(meetingParams: MeetingsParams,
         orderObserver: SpeakerControllerOrderObserver,
         meetingMode: MeetingMode = .Uniform,
         coreServices: HostCoreServices) {
        self.meetingParams = meetingParams
        self.orderObserver = orderObserver
        self.meetingMode = meetingMode
        self.coreServices = coreServices

        if meetingMode == .AutoModerated {
            // shuffleSpeakerOrder()
        }

        meetingControllerSecondTicker.start()
        meetingControllerCurrentSpeakerTicker.start()
        setupParticipantIsDoneInterrupt()
    }

    // MARK: - Public API(s)
    @objc public func speakerIsDone() {
        meetingControllerSecondTicker.stop()
        meetingControllerCurrentSpeakerTicker.stop()

        guard var speakingOrder = coreServices.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.circularRotate()
        coreServices.updateSpeakerOrder(with: speakingOrder)
        orderObserver?.speakingOrderUpdated(totalSpeakingRecord: storage.participantTotalSpeakingRecord)
        
        meetingControllerSecondTicker.start()
        meetingControllerCurrentSpeakerTicker.start()

    }

    public func endMeeting() {
        meetingControllerSecondTicker.stop()
        meetingControllerCurrentSpeakerTicker.stop()
    }

    public func forceSpeakerChange(participantId: String) {
        do {
            try meetingControllerCurrentSpeakerTicker.forceRestartRound(preferParticipantId: participantId)
        } catch {
            assertionFailure("Force switching participant failed: \(error)")
        }
    }

    // MARK: - Private API(s)

    private func setupParticipantIsDoneInterrupt() {
        let notificationName = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(participantIsDoneInterrupt(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func participantIsDoneInterrupt(notification: NSNotification) {        
        speakerIsDone()
    }

    private func shuffleSpeakerOrder() {
        guard var speakingOrder = coreServices.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.shuffled()
        coreServices.updateSpeakerOrder(with: speakingOrder)
    }
}

