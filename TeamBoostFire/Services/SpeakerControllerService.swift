import Foundation

protocol SpeakerControllerOrderObserver: class {
    /**
     Method to indicate that the speaker order has changed and the observer can fetch the new order from CoreServices
     */
    func speakingOrderUpdated()
}

class SpeakerControllerService {
    let meetingParams: MeetingsParams
    weak var orderObserver: SpeakerControllerOrderObserver?
    var speakerTimer: Timer?
    var secondTickTimer: Timer?

    init(meetingParams: MeetingsParams,
         orderObserver: SpeakerControllerOrderObserver) {
        self.meetingParams = meetingParams
        self.orderObserver = orderObserver

        shuffleSpeakerOrder()
        startSpeakerTimer()
    }

    @objc func rotateSpeakerOrder() {
        stopSpeakerTimer()

        guard var speakingOrder = CoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.circularRotate()
        CoreServices.shared.updateSpeakerOrder(with: speakingOrder)
        orderObserver?.speakingOrderUpdated()

        startSpeakerTimer()

    }

    private func shuffleSpeakerOrder() {
        guard var speakingOrder = CoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.shuffled()
        CoreServices.shared.updateSpeakerOrder(with: speakingOrder)
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

