# TeamBoostFire
TeamBoost with Firebase implementation

# TeamBoostFire Database Schema

```
{
  "123456" : {
    "call_to_speaker_interrupt" : "",
    "current_speaker_speaking_time" : 0,
    "i_am_done_interrupt" : 5.9528858132653E8,
    "meeting_params" : {
      "agenda" : "TEST MEETING AGENDA",
      "max_talk_time" : 15,
      "meeting_time" : 60
    },
    "meeting_state" : "ended",
    "participants" : {
      "5A8A0D7D-B901-46ED-9F34-99AC8060B8E5" : {
        "id" : "5A8A0D7D-B901-46ED-9F34-99AC8060B8E5",
        "name" : "Dewey"
      },
      "63A26E91-5260-4411-9795-91D5EA632B69" : {
        "id" : "63A26E91-5260-4411-9795-91D5EA632B69",
        "name" : "Jon Snow"
      },
      "82C2E4E1-F018-4F4A-B8F0-10CB42DBB841" : {
        "id" : "82C2E4E1-F018-4F4A-B8F0-10CB42DBB841",
        "name" : "Cersei Lannister"
      },
      "DD43DE1C-54CF-4F69-B4F8-16A6FCF80898" : {
        "id" : "DD43DE1C-54CF-4F69-B4F8-16A6FCF80898",
        "name" : "Ned Stark"
      }
    },
    "speaker_order" : [ "82C2E4E1-F018-4F4A-B8F0-10CB42DBB841", "DD43DE1C-54CF-4F69-B4F8-16A6FCF80898", "5A8A0D7D-B901-46ED-9F34-99AC8060B8E5", "63A26E91-5260-4411-9795-91D5EA632B69" ]
  }
}
```

# Use Cases

## Host Brute forces selection of a participant

![](/Documentation/BruteSelectParticipant.png)



