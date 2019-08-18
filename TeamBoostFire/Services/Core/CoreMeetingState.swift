enum CoreMeetingState: String {
    case MeetingSuspended = "suspended"
    case MeetingStarted = "started"
    case MeetingEnded = "ended"
    func state() -> String { return self.rawValue }
}
