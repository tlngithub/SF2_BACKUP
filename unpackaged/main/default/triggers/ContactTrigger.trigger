/**
 * Created by maximelets on 02/08/2024.
 */

trigger ContactTrigger on Contact(before insert, before update) {
    if (GlobalConstants.areTriggersEnabled()) {
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            ContactTriggerHandler.handleBeforeInsertUpdate(Trigger.new, Trigger.oldMap);
            if(Trigger.isUpdate){
                ContactTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }
}