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
    var timer: Timer?

    init(meetingParams: MeetingsParams,
         orderObserver: SpeakerControllerOrderObserver) {
        self.meetingParams = meetingParams
        self.orderObserver = orderObserver
        setupTimer()
    }

    private func setupTimer() {
        let meetingParams = CoreServices.shared.meetingParams
        timer = Timer.scheduledTimer(timeInterval: Double(meetingParams!.maxTalkTime), target: self,
                                     selector: #selector(rotateSpeakerOrder),
                                     userInfo: nil, repeats: true)
    }

    @objc func rotateSpeakerOrder() {
        guard var speakingOrder = CoreServices.shared.speakerOrder else {
            assertionFailure("No speaker order available in CoreServices")
            return
        }
        speakingOrder = speakingOrder.circularRotate()
        CoreServices.shared.updateSpeakerOrder(with: speakingOrder)
        orderObserver?.speakingOrderUpdated()

    }
}

