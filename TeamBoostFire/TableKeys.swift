import Foundation

enum TableKeys: String {
    case MeetingState = "meeting_state"

    /**
     Moderator interjects in the meeting and has asked for control
     */
    case ModeratorHasControl = "moderator_has_control"

    case Suspended = "suspended"
    /*
     Order in which the participants can speak
     */
    case SpeakerOrder = "speaker_order"
    case Participants = "participants"
    case MeetingParams = "meeting_params"
    // Meeting Params
    case MeetingTime = "meeting_time"
    case Agenda = "agenda"
    case MaxTalkTime = "max_talk_time"
    /*
     Participant says - I am done and the meeting moves on to the next participant
     */
    case IAmDoneInterrupt = "i_am_done_interrupt"
    /*
     Maximum allowed speaking time for the current speaker
     */
    case CurrentSpeakerMaxSpeakingTime = "current_speaker_speaking_time"
    /*
     Call to speaker Queue
     */
    case CallToSpeakerInterrupt = "call_to_speaker_interrupt"
}

