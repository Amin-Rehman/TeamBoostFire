import Foundation

typealias ParticipantId = String
typealias SpeakingTime = Int

class MeetingControllerService: MeetingControllerCurrentRoundTickerObserver {
    let meetingParams: MeetingsParams
    weak var orderObserver: SpeakerControllerOrderObserver?
    private let meetingMode: MeetingMode

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
        return MeetingControllerSecondTicker(with: self.storage)
    }()

    public lazy var meetingControllerCurrentRoundTicker: MeetingControllerCurrentSpeakerTicker = {
        return MeetingControllerCurrentSpeakerTicker(with: self.storage,
                                                   meetingMode: self.meetingMode,
                                                   maxTalkTime: self.meetingParams.maxTalkTime,
                                                   observer: self)
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

        meetingControllerSecondTicker.start()
        meetingControllerCurrentRoundTicker.start()
        setupParticipantIsDoneInterrupt()
    }

    // MARK: - Public API(s)
    @objc public func speakerIsDone() {
        meetingControllerSecondTicker.stop()
        meetingControllerCurrentRoundTicker.stop()

        guard var speakingOrder = HostCoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.circularRotate()
        HostCoreServices.shared.updateSpeakerOrder(with: speakingOrder)

        meetingControllerSecondTicker.start()
        meetingControllerCurrentRoundTicker.start()

    }

    public func endMeeting() {
        meetingControllerSecondTicker.stop()
        meetingControllerCurrentRoundTicker.stop()
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
        guard var speakingOrder = HostCoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.shuffled()
        HostCoreServices.shared.updateSpeakerOrder(with: speakingOrder)
    }
}

