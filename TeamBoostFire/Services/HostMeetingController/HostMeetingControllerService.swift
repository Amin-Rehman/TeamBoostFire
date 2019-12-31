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

    /**
     Responsible for updating the speaking time of each speaker every second in the storage
     */
    public lazy var speakerSpeakingTimeUpdater: SpeakerSpeakingTimeUpdater = {
        return SpeakerSpeakingTimeUpdater(with: self.storage,
                                             coreServices: coreServices)
    }()

    /**
     Responsible for keeping track of the current session
     */

    public lazy var speakingSessionUpdater: SpeakingSessionUpdater = {
        let speakerTickerTimerController = TeamBoostTimerController()
        return SpeakingSessionUpdater(with: self.storage,
                                      meetingMode: self.meetingMode,
                                      maxTalkTime: self.meetingParams.maxTalkTime,
                                      observer: self,
                                      timerController: speakerTickerTimerController)
    }()

    public lazy var meetingTimeUpdater: MeetingTimeUpdater = {
        return MeetingTimeUpdater(with: self.storage)
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

        meetingTimeUpdater.start()
        speakerSpeakingTimeUpdater.start()
        speakingSessionUpdater.start()
        setupParticipantIsDoneNotificationObserver()
        setupCallToSpeakerNotificationObserver()
    }

    // MARK: - Public API(s)
    @objc public func speakerIsDone() {
        speakerSpeakingTimeUpdater.stop()
        speakingSessionUpdater.stop()

        guard var speakingOrder = coreServices.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.circularRotate()
        coreServices.updateSpeakerOrder(with: speakingOrder)
        orderObserver?.speakingOrderUpdated(totalSpeakingRecord: storage.participantTotalSpeakingRecord)
        
        speakerSpeakingTimeUpdater.start()
        speakingSessionUpdater.start()

    }

    public func endMeeting() {
        speakerSpeakingTimeUpdater.stop()
        speakingSessionUpdater.stop()
    }

    public func forceSpeakerChange(participantId: String) {
        do {
            try speakingSessionUpdater.forceRestartRound(preferParticipantId: participantId)
        } catch {
            assertionFailure("Force switching participant failed: \(error)")
        }
    }

    // MARK: - Private API(s)

    private func setupParticipantIsDoneNotificationObserver() {
        let notificationName = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(participantIsDone(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func participantIsDone(notification: NSNotification) {
        print("ALOG: HostMeetingControllerService: participantIsDoneInterrupt")
        speakerIsDone()
    }

    private func setupCallToSpeakerNotificationObserver() {
        let notificationName = Notification.Name(TeamBoostNotifications.callToSpeakerDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(callToSpeaker(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func callToSpeaker(notification: NSNotification) {
        guard let callToSpeakerWithUniqueId = notification.object as? String else {
            assertionFailure("No call to speaker id available in the payload")
            return
        }

        // Split call to speaker with '_' to retrieve the userId
        guard let callToSpeakerId = callToSpeakerWithUniqueId.components(
            separatedBy: CharacterSet(charactersIn: "_")).first else {
                assertionFailure("Unable to retrieve call to speaker Id")
                return
        }

        print("ALOG: HostMeetingControllerService: callToSpeaker")
        self.storage.appendSpeakerToCallToSpeakerQueue(participantId: callToSpeakerId)
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

