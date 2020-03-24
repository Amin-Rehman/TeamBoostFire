import Foundation
import TeamBoostKit

public typealias ParticipantId = String
typealias SpeakingTime = Int

class HostMeetingControllerService: MeetingControllerCurrentRoundTickerObserver {
    let meetingParams: MeetingsParams
    weak var orderObserver: SpeakerControllerOrderObserver?
    private let meetingMode: MeetingMode
    private let domain: TeamBoostKitDomain

    public lazy var storage: MeetingControllerStorage = {
        let allParticipantIdentifiers = domain.speakerOrder
        let controllerStorage = MeetingControllerStorage(with: allParticipantIdentifiers,
                                                         maxTalkTime: meetingParams.maxTalkTime,
                                                         domain: self.domain)
        return controllerStorage
    }()

    /**
     Responsible for updating the speaking time of each speaker every second in the storage
     */
    public lazy var speakerSpeakingTimeUpdater: SpeakerSpeakingTimeUpdater = {
        return SpeakerSpeakingTimeUpdater(with: self.storage,
                                          domain: self.domain)
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
         domain: TeamBoostKitDomain) {
        self.meetingParams = meetingParams
        self.orderObserver = orderObserver
        self.meetingMode = meetingMode
        self.domain = domain

        meetingTimeUpdater.start()
        setupParticipantIsDoneNotificationObserver()
        setupCallToSpeakerNotificationObserver()
    }

    // MARK: - Public API(s)
    @objc public func speakerIsDone() {
        speakerSpeakingTimeUpdater.stop()
        speakingSessionUpdater.stop()

        let completedSessionSpeakerOrder = domain.speakerOrder
        speakingSessionUpdater.start(where: completedSessionSpeakerOrder)
        speakerSpeakingTimeUpdater.start()

        orderObserver?.speakingOrderUpdated(totalSpeakingRecord: storage.participantTotalSpeakingRecord)
    }

    public func endMeeting() {
        stopParticipantSpeakingSessions()
        meetingTimeUpdater.stop()
    }

    public func forceSpeakerChange(participantId: String) {
        do {
            try speakingSessionUpdater.forceRestartRound(preferParticipantId: participantId)
        } catch {
            assertionFailure("Force switching participant failed: \(error)")
        }
    }

    public func startParticipantSpeakingSessions() {
        speakerSpeakingTimeUpdater.start()
        let speakerOrder = domain.speakerOrder
        speakingSessionUpdater.start(where: speakerOrder, isStartOfMeeting: true)
    }

    public func stopParticipantSpeakingSessions() {
        speakerSpeakingTimeUpdater.stop()
        speakingSessionUpdater.stop()
    }

    // MARK: - Private API(s)

    private func setupParticipantIsDoneNotificationObserver() {
        let notificationName = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(participantIsDone(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func participantIsDone(notification: NSNotification) {
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

        self.storage.appendSpeakerToCallToSpeakerQueue(participantId: callToSpeakerId)
    }
}

