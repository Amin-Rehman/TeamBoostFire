import Foundation

protocol SpeakerControllerOrderObserver: class {
    /**
     Method to indicate that the speaker order has changed and the observer can fetch the new order from CoreServices
     */
    func speakingOrderUpdated()
}


protocol SpeakerControllerSecondTickObserver: class {
    func speakerSecondTicked()
}

class SpeakerControllerService {
    let meetingParams: MeetingsParams
    weak var orderObserver: SpeakerControllerOrderObserver?
    weak var speakerSecondTickObserver: SpeakerControllerSecondTickObserver?

    var speakerTimer: Timer?
    var secondTickTimer: Timer?

    var secondTicker = 0

    init(meetingParams: MeetingsParams,
         orderObserver: SpeakerControllerOrderObserver) {
        self.meetingParams = meetingParams
        self.orderObserver = orderObserver

        shuffleSpeakerOrder()
        startSpeakerTimer()
        startSecondTickerTimer()
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
        secondTicker = secondTicker + 1
        speakerSecondTickObserver?.speakerSecondTicked()
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
        secondTicker = 0
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

