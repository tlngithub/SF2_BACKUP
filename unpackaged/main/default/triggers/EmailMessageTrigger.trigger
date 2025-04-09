/**
 * @description Trigger handler for EmailMessage.
 * @author Eugene
 * @date 13.01.2024
**/
trigger EmailMessageTrigger on EmailMessage (after insert) {
    if(GlobalConstants.areTriggersEnabled()) {
        if(Trigger.isAfter && Trigger.isInsert) {
            EmailMessageTriggerHandler.handleAfterInsert(Trigger.new);
        }
    }
}