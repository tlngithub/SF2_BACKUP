/**
 * Lead trigger.
 * @ticket User Story 18685: SF2 Create lead and contact fields for grant applicants/recipients
 */
trigger LeadTrigger on Lead (before insert, before update, after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        LeadTriggerHandler.handleAfterUpdate(Trigger.old, Trigger.new);
    } else if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        LeadTriggerHandler.handleBeforeInsertUpdate(Trigger.new);
    }
}