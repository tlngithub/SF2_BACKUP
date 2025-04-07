/**
 * @description Trigger handler for task trigger.
 * @author Eugene
 * @date 05.11.2024
**/
public without sharing class TaskTriggerHandler {

    public static Boolean disableSyncCheck = false;

    private static final Date CONTROL_DATE = Date.newInstance(2024, 11, 1);
    private static final Set<String> SYNC_CASE_RTS = new Set<String> {
            CaseConstants.CASE_BILLING_RT_ID,
            CaseConstants.CASE_ELIGIBILITY_RT_ID,
            CaseConstants.CASE_SUBMISSIONS_RT_ID, // US-29078
            CaseConstants.CASE_SUPPORT_ISSUE_RT_ID
    };
    private static final Set<SObjectField> FIELDS_TO_TRACK = new Set<SObjectField> {
            Task.CallDisposition,
            Task.Description,
            Task.Priority,
            Task.Status,
            Task.Subject,
            Task.Team__c,
            Task.Type
    };

    public static void handleBeforeInsert(List<Task> newRecords) {
        if(FeatureFlag.isActive('TLN_29077_SHARENEEDEDCASESANDTASKSACROSS') || System.Test.isRunningTest()) {
            assignToQueue(newRecords);
        }

        if( ! disableSyncCheck) {
            setSyncStatus(newRecords, new Map<Id, Task>());
        }
    }

    public static void handleAfterInsert(List<Task> newRecords) {
        rememberRecordId(newRecords);
    }

    public static void handleBeforeUpdate(List<Task> newRecords, Map<Id, Task> oldRecordsMap) {
        if( ! disableSyncCheck) {
            setSyncStatus(newRecords, oldRecordsMap);
        }
    }

    // We need to assign correct queue for tasks coming from SF1
    private static void assignToQueue(List<Task> newRecords) {
        for(Task record : newRecords) {
            if(String.isNotBlank(record.Team__c) && String.isNotBlank(record.SF_Source_Id__c)) {
                if(record.Queue_Override__c == TaskConstants.QUEUE_OVERRIDE_ELIGIBILITY) {
                    record.OwnerId = GroupConstants.QUEUES_BY_NAMES.get(GroupConstants.QUEUE_ELIGIBILITY).Id;
                }
            }
        }
    }

    // We need id as text field because that is the only way to use it with SF2SF
    private static void rememberRecordId(List<Task> newRecords) {
        List<Task> tasksToUpdate = new List<Task>();
        for(Task record : newRecords) {
            tasksToUpdate.add(new Task(
                    Id = record.Id,
                    Record_Id__c = record.Id));
        }
        disableSyncCheck = true;
        Database.update(tasksToUpdate);
        disableSyncCheck = false;
    }

    private static void setSyncStatus(List<Task> newRecords, Map<Id, Task> oldRecordsMap) {
        Set<Id> caseIds = new Set<Id>();
        for(Task record : newRecords) {
            if(record.Sync_Status__c != TaskConstants.SYNC_STATUS_IGNORE) {
                if(record.WhatId != NULL && record.WhatId.getSobjectType() == Case.SObjectType) {
                    caseIds.add(record.WhatId);
                }
            }
        }

        Map<Id, Case> casesByIds = new Map<Id, Case>([
                SELECT CreatedDate, RecordTypeId
                FROM Case
                WHERE Id IN :caseIds]);

        for(Task record : newRecords) {
            if(casesByIds.containsKey(record.WhatId)) {
                Case parentCase = casesByIds.get(record.WhatId);
                if(isTaskSync(parentCase, record)) {
                    if(oldRecordsMap == NULL || oldRecordsMap.isEmpty()) {
                        record.Sync_Status__c = TaskConstants.SYNC_STATUS_NEED_SYNC;
                    } else {
                        for(SObjectField field : FIELDS_TO_TRACK) {
                            if(record.get(field) != oldRecordsMap.get(record.Id).get(field)) {
                                record.Sync_Status__c = TaskConstants.SYNC_STATUS_NEED_SYNC;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    private static Boolean isTaskSync(Case parentCase, Task record) {
        return (parentCase.CreatedDate >= CONTROL_DATE && (SYNC_CASE_RTS.contains(parentCase.RecordTypeId) ||
            (parentCase.RecordTypeId == CaseConstants.CASE_INTAKE_RT_ID && record.Team__c == TaskConstants.TEAM_RCM &&
            (FeatureFlag.isActive('TLN_29077_SHARENEEDEDCASESANDTASKSACROSS') || System.Test.isRunningTest()))));
    }
}