/**
 * @description Trigger handler for tasks.
 * @author Eugene
 * @date 04.11.2024
**/
trigger TaskTrigger on Task (before insert, after insert, before update) {
    if(GlobalConstants.areTriggersEnabled()) {
        if(Trigger.isBefore && Trigger.isInsert) {
            TaskTriggerHandler.handleBeforeInsert(Trigger.new);
        } else if(Trigger.isAfter && Trigger.isInsert) {
            TaskTriggerHandler.handleAfterInsert(Trigger.new);
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            TaskTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}