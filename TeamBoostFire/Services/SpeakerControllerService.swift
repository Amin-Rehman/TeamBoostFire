import Foundation

protocol SpeakerControllerOrderObserver: class {
    /**
     Method to indicate that the speaker order has changed and the observer can fetch the new order from CoreServices
     */
    func speakingOrderUpdated()
}


protocol SpeakerControllerSecondTickObserver: class {
    func speakerSecondTicked(participantIdentifier: String)
}

class SpeakerControllerService {
    let meetingParams: MeetingsParams
    weak var orderObserver: SpeakerControllerOrderObserver?
    weak var speakerSecondTickObserver: SpeakerControllerSecondTickObserver?

    var speakerTimer: Timer?
    var secondTickTimer: Timer?


    public private(set) var participantSpeakingRecord = [String: Int]()

    init(meetingParams: MeetingsParams,
         orderObserver: SpeakerControllerOrderObserver) {
        self.meetingParams = meetingParams
        self.orderObserver = orderObserver

        setupParticipantSpeakingRecord()
        shuffleSpeakerOrder()
        startSpeakerTimer()
        // First second gets missed so brute force the first secondTicked
        secondTicked()
        startSecondTickerTimer()
    }

    func setupParticipantSpeakingRecord() {
        guard let allParticipantIdentifiers = CoreServices.shared.speakerOrder else {
            assertionFailure("Unable to retrieve speaking order during setupParticipantSpeakingRecord")
            return
        }

        for identifiers in allParticipantIdentifiers {
            participantSpeakingRecord[identifiers] = 0
        }
    }

    public func goToNextSpeaker() {
        rotateSpeakerOrder()
    }

    @objc func rotateSpeakerOrder() {
        stopSecondTickerTimer()
        stopSpeakerTimer()

        guard var speakingOrder = CoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.circularRotate()
        CoreServices.shared.updateSpeakerOrder(with: speakingOrder)
        orderObserver?.speakingOrderUpdated()

        startSecondTickerTimer()
        startSpeakerTimer()

    }

    @objc func secondTicked() {
        guard let speakerOrder = CoreServices.shared.speakerOrder,
            let currentSpeakerIdentifier = speakerOrder.first else {
            assertionFailure("Unable to retrieve current speaker")
            return
        }

        guard var speakerTime = participantSpeakingRecord[currentSpeakerIdentifier] else {
            assertionFailure("Unable to retrieve speaker time")
            return
        }

        speakerTime = speakerTime + 1
        participantSpeakingRecord[currentSpeakerIdentifier] = speakerTime
        speakerSecondTickObserver?.speakerSecondTicked(participantIdentifier: currentSpeakerIdentifier)
    }

    private func shuffleSpeakerOrder() {
        guard var speakingOrder = CoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.shuffled()
        CoreServices.shared.updateSpeakerOrder(with: speakingOrder)
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

