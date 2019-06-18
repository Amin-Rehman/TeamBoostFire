import Foundation

protocol SpeakerControllerOrderObserver: class {
    /**
     Method to indicate that the speaker order has changed and the observer can fetch the new
     order from CoreServices
     */
    func speakingOrderUpdated()
}


protocol SpeakerControllerSecondTickObserver: class {
    /**
     Indicate that the speaking time for a particular participant changed
     */
    func speakerSecondTicked(participantIdentifier: String)
}

enum MeetingMode {
    case Uniform
    case AutoModerated
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

    public private(set) var participantTotalSpeakingRecord = ParticipantSpeakingRecord()
    public weak var speakerSecondTickObserver: SpeakerControllerSecondTickObserver?

    private var numberOfTimesMovingToNextSpeaker = 1

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

        startSpeakerTimer()
        // First second gets missed so brute force the first secondTicked
        secondTicked()
        startSecondTickerTimer()
        setupParticipantIsDoneInterrupt()
    }

    // MARK: - Public API(s)
    public func goToNextSpeaker() {
        numberOfTimesMovingToNextSpeaker = numberOfTimesMovingToNextSpeaker + 1

        switch meetingMode {
        case .Uniform:
            rotateSpeakerOrder()
        case .AutoModerated:
            assertionFailure("Not implemented")
        }

    }

    public func endMeeting() {
        stopSecondTickerTimer()
        stopSpeakerTimer()
    }

    // MARK: - Private API(s)

    private func setupParticipantIsDoneInterrupt() {
        let notificationName = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(participantIsDoneInterrupt(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func participantIsDoneInterrupt(notification: NSNotification) {        
        rotateSpeakerOrder()
    }

    private func setupParticipantSpeakingRecord() {
        guard let allParticipantIdentifiers = HostCoreServices.shared.speakerOrder else {
            assertionFailure("Unable to retrieve speaking order during setupParticipantSpeakingRecord")
            return
        }

        for identifiers in allParticipantIdentifiers {
            participantTotalSpeakingRecord[identifiers] = 0
        }
    }

    @objc private func rotateSpeakerOrder() {
        stopSecondTickerTimer()
        stopSpeakerTimer()

        guard var speakingOrder = HostCoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.circularRotate()
        HostCoreServices.shared.updateSpeakerOrder(with: speakingOrder)
        orderObserver?.speakingOrderUpdated()

        startSecondTickerTimer()
        startSpeakerTimer()

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
    private func startSpeakerTimer() {
        speakerTimer = Timer.scheduledTimer(timeInterval: Double(meetingParams.maxTalkTime), target: self,
                                            selector: #selector(rotateSpeakerOrder),
                                            userInfo: nil, repeats: false)
    }

    private func stopSpeakerTimer() {
        speakerTimer?.invalidate()
        speakerTimer = nil
    }
}

