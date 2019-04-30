import Foundation

enum TableKeys: String {
    case MeetingState = "meeting_state"
    case Suspended = "suspended"
    /**
     Key ONLY to be written by the HOST,
     Never to be written to by the PARTICIPANT
     */
    case SpeakerOrder = "speaker_order"
    case Participants = "participants"
    case MeetingParams = "meeting_params"
    // Meeting Params
    case MeetingTime = "meeting_time"
    case Agenda = "agenda"
    case MaxTalkTime = "max_talk_time"
}

