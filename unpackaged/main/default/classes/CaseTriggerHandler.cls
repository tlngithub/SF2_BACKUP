/**
 * @description Trigger handler for case trigger.
 * @author Eugene
 * @date 04.11.2024
**/
public without sharing class CaseTriggerHandler {

    public static void handleBeforeInsert(List<Case> newRecords) {
        if(FeatureFlag.isActive('TLN_29077_SHARENEEDEDCASESANDTASKSACROSS')) {
            rememberRecordType(newRecords);
        }

        for(Case record : newRecords) {
            setStoppedSince(record, NULL);
        }
    }

    public static void handleAfterInsert(List<Case> newRecords) {
        rememberRecordId(newRecords);
    }

    public static void handleBeforeUpdate(List<Case> newRecords, Map<Id, Case> oldRecords) {
        if(FeatureFlag.isActive('TLN_29077_SHARENEEDEDCASESANDTASKSACROSS')) {
            rememberRecordType(newRecords);
        }

        for(Case record : newRecords) {
            calculateWaitingTime(record, oldRecords.get(record.Id));
            setStoppedSince(record, oldRecords.get(record.Id));
            calculateResolutionTime(record, oldRecords.get(record.Id));
            checkCaseOwner(record, oldRecords.get(record.Id));
        }
    }

    // We need as text field because that is the only way to use it with SF2SF
    private static void rememberRecordType(List<Case> newRecords) {
        Set<Id> recordTypeIds = new Set<Id>();
        for(Case record : newRecords) {
            if(String.isBlank(record.SF_Source_Id__c) && String.isNotBlank(record.RecordTypeId)) {
                recordTypeIds.add(record.RecordTypeId);
            }
        }

        Map<Id, RecordType> recordTypesByIds = new Map<Id, RecordType>([
                SELECT DeveloperName
                FROM RecordType
                WHERE Id IN :recordTypeIds]);

        for(Case record : newRecords) {
            if(recordTypesByIds.containsKey(record.RecordTypeId)) {
                record.Record_Type_Name__c = recordTypesByIds.get(record.RecordTypeId).DeveloperName;
            }
        }
    }

    // We need id as text field because that is the only way to use it with SF2SF
    private static void rememberRecordId(List<Case> newRecords) {
        List<Case> casesToUpdate = new List<Case>();
        for(Case record : newRecords) {
            casesToUpdate.add(new Case(
                    Id = record.Id,
                    Record_Id__c = record.Id));
        }
        Database.update(casesToUpdate);
    }

    // Capture when case is resolved or waiting for customer response
    private static void setStoppedSince(Case record, Case oldRecord) {
        if(CaseConstants.STOPPED_STATUSES.contains(record.Status) && (oldRecord == NULL || record.Status != oldRecord.Status)) {
            record.Stopped_Since__c = System.now();
        }
    }

    // Calculate time when case is in resolved or waiting for external response state
    private static void calculateWaitingTime(Case record, Case oldRecord) {
        if(record.Status != oldRecord.Status && CaseConstants.STOPPED_STATUSES.contains(oldRecord.Status)) {
            record.Time_Spent_Waiting__c = record.Time_Spent_Waiting__c == NULL ? 0 : record.Time_Spent_Waiting__c;
            if(record.Stopped_Since__c != NULL) {
                record.Time_Spent_Waiting__c += (Decimal.valueOf(System.now().getTime() - record.Stopped_Since__c.getTime()) / 1000 / 60 / 60);
            }
        }
    }

    // Calculate resolution time
    private static void calculateResolutionTime(Case record, Case oldRecord) {
        if(record.Status == CaseConstants.STATUS_RESOLVED && oldRecord.Status != CaseConstants.STATUS_RESOLVED) {
            record.Time_Spent_Waiting__c = record.Time_Spent_Waiting__c == NULL ? 0 : record.Time_Spent_Waiting__c;
            record.Resolution_Time__c = ((Decimal.valueOf(System.now().getTime() - record.CreatedDate.getTime()) / 1000 / 60 / 60) -
                record.Time_Spent_Waiting__c);
        }
    }
    
    // BUG-30799 Patient Integration changes the Case Owner when it's Closed
    private static final String INTEGRATION_USER_NAME = 'Integration';
    public static void checkCaseOwner(Case record, Case oldRecord) {
        // SF reassigns the case using Case Assignment Rules or to the Automated Case User in Prod, so we have to assign it back to the original user
        if(UserInfo.getName().contains(INTEGRATION_USER_NAME)) {
            if(record.OwnerId != oldRecord.OwnerId) {
                record.OwnerId = oldRecord.OwnerId;
            }
        }
    }
}