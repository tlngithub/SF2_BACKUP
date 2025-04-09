/**
 * Created by maximelets on 02/08/2024.
 */

public without sharing class ContactTriggerHandler {
    public static void handleBeforeInsertUpdate(List<Contact> newRecords, Map<Id, Contact> oldRecordsMap) {
        for (Contact record : newRecords) {
            Contact oldRecord = oldRecordsMap != null ? oldRecordsMap.get(record.Id) : null;
            setPendingDeactivationTimestamp(record, oldRecord);
        }
    }

    private static void setPendingDeactivationTimestamp(Contact record, Contact oldRecord) {
        Boolean statusChangedToPendingDeactivation = oldRecord?.Status__c != record.Status__c;
        if (statusChangedToPendingDeactivation) {
            if (record.Status__c == GlobalConstants.LC_STATUS_PENDING_DISABLEMENT) {
                record.Pending_Deactivation_Since__c = System.now();
            } else if (record.Status__c != GlobalConstants.LC_STATUS_PENDING_DISABLEMENT) {
                record.Pending_Deactivation_Since__c = null;
            }
        }
    }
}