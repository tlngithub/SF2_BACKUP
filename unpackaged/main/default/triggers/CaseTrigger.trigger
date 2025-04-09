/**
 * @description Trigger handler for cases.
 * @author Eugene
 * @date 04.11.2024
**/
trigger CaseTrigger on Case (before insert, after insert, before update) {
    if(GlobalConstants.areTriggersEnabled()) {
        if(Trigger.isBefore && Trigger.isInsert) {
            CaseTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if(Trigger.isAfter && Trigger.isInsert) {
            CaseTriggerHandler.handleAfterInsert(Trigger.new);
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            CaseTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}