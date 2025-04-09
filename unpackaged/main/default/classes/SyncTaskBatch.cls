/**
 * @description Batch to forward tasks created/updated in sf2 to sf1.
 * @author Eugene
 * @date 04.11.2024
**/
public with sharing class SyncTaskBatch implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts {

    public void execute(SchedulableContext context) {
        Database.executeBatch(new SyncTaskBatch());
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
                SELECT CallDisposition, Description, Status, Subject, Type, Priority, WhatId, Team__c, SF_Source_Id__c,
                    Queue_Override__c
                FROM Task
                WHERE Sync_Status__c = :TaskConstants.SYNC_STATUS_NEED_SYNC
                AND TaskSubtype = :TaskConstants.TYPE_TASK]);
    }

    public void execute(Database.BatchableContext context, List<Task> scope) {
        Set<Id> caseIds = new Set<Id>();
        for(Task record : scope) {
            caseIds.add(record.WhatId);
        }

        Map<Id, Case> casesByIds = new Map<Id, Case>([
                SELECT SF_Source_Id__c
                FROM Case
                WHERE Id IN :caseIds]);

        List<CreateTaskRestResource.TaskDto> taskDtos = new List<CreateTaskRestResource.TaskDto>();
        for(Task record : scope) {
            taskDtos.add(new CreateTaskRestResource.TaskDto(record, casesByIds.get(record.WhatId).SF_Source_Id__c));
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SFDCOrgDev1/services/apexrest/sync-task');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setBody(JSON.serialize(taskDtos));
        Http http = new Http();

        HttpResponse response = http.send(req);

        // Update sync status
        System.debug(LoggingLevel.ERROR, '::::: body = ' + response.getBody());
        CreateTaskRestResource.ResultDto result = (CreateTaskRestResource.ResultDto)JSON.deserialize(
            response.getBody(), CreateTaskRestResource.ResultDto.class);

        if(result.success) {
            Map<Id, Boolean> statusByTaskId = new Map<Id, Boolean>();
            for(CreateTaskRestResource.RecordResultDto recordResult : result.recordResults) {
                statusByTaskId.put(recordResult.recordId, recordResult.success);
            }

            for(Task record : scope) {
                String keyId = String.isNotBlank(record.SF_Source_Id__c) ? record.SF_Source_Id__c : record.Id;
                if(statusByTaskId.containsKey(keyId) && statusByTaskId.get(keyId)) {
                    record.Sync_Status__c = TaskConstants.SYNC_STATUS_SYNCED;
                } else {
                    record.Sync_Status__c = TaskConstants.SYNC_STATUS_ERROR;
                }
            }
        } else {
            for(Task record : scope) {
                record.Sync_Status__c = TaskConstants.SYNC_STATUS_ERROR;
            }
        }
        TaskTriggerHandler.disableSyncCheck = true;
        Database.update(scope);
        TaskTriggerHandler.disableSyncCheck = false;
    }

    public void finish(Database.BatchableContext context) {}
}