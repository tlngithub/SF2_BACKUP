/**
 * @description Rest resource to create/update tasks coming from sf2.
 * @author Eugene
 * @date 04.11.2024
**/
@RestResource(urlMapping='/sync-task/*')
global with sharing class CreateTaskRestResource {

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            System.debug(LoggingLevel.ERROR, '::::: body = ' + req.requestBody.toString());
            List<TaskDto> taskDtos = (List<TaskDto>)JSON.deserialize(req.requestBody.toString(), List<TaskDto>.class);
            Set<String> caseIds = new Set<String>();
            for(TaskDto dto : taskDtos) {
                caseIds.add(dto.sourceCaseId);
            }

            Map<String, Case> casesByExternalId = new Map<String, Case>();
            for(Case record : [SELECT SF_Source_Id__c FROM Case WHERE SF_Source_Id__c IN :caseIds OR Id IN :caseIds]) {
                casesByExternalId.put(record.SF_Source_Id__c, record);
                casesByExternalId.put(record.Id, record);
            }

            List<Task> originalTasks = new List<Task>();
            List<Task> externalTasks = new List<Task>();
            for(TaskDto dto : taskDtos) {
                if(casesByExternalId.containsKey(dto.sourceCaseId)) {
                    Task record = dto.record;
                    record.WhatId = casesByExternalId.get(dto.sourceCaseId).Id;
                    if(String.isNotBlank(dto.sourceId)) {
                        record.Id = dto.sourceId;
                        // Fix to prevent setting wrong id for edge case scenarios
                        if(String.isNotBlank(record.SF_Source_Id__c) && record.Id == Id.valueOf(record.SF_Source_Id__c)) {
                            record.SF_Source_Id__c = NULL;
                        }
                        originalTasks.add(record);
                    } else {
                        record.Id = NULL;
                        record.SF_Source_Id__c = dto.originalId;
                        externalTasks.add(record);
                    }
                }
            }

            ResultDto responseResult = new ResultDto();
            TaskTriggerHandler.disableSyncCheck = true;
            System.debug(LoggingLevel.ERROR, '::::: originalTasks = ' + JSON.serialize(originalTasks));
            responseResult.recordResults.addAll(upsertTasks(originalTasks, false));

            System.debug(LoggingLevel.ERROR, '::::: externalTasks = ' + JSON.serialize(externalTasks));
            responseResult.recordResults.addAll(upsertTasks(externalTasks, true));
            TaskTriggerHandler.disableSyncCheck = false;

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(responseResult));
        } catch(Exception exc) {
            ResultDto responseResult = new ResultDto();
            responseResult.success = false;
            responseResult.message = 'Exc: ' + exc.getMessage() + ' stack: ' + exc.getStackTraceString();

            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(responseResult));
        }
    }

    private static List<RecordResultDto> upsertTasks(List<Task> recordsToUpsert, Boolean isExternal) {
        List<Database.UpsertResult> saveResults;
        if(isExternal) {
            saveResults = Database.upsert(recordsToUpsert, Task.SF_Source_Id__c, false);
        } else {
            saveResults = Database.upsert(recordsToUpsert, false);
        }

        List<RecordResultDto> results = new List<RecordResultDto>();
        for(Integer i = 0; i < saveResults.size(); i++) {
            RecordResultDto dto = new RecordResultDto();
            dto.recordId = recordsToUpsert.get(i).SF_Source_Id__c;
            if(String.isBlank(dto.recordId)) {
                dto.recordId = recordsToUpsert.get(i).Id;
            }

            dto.success = saveResults.get(i).isSuccess();
            if( ! dto.success) {
                dto.message = saveResults.get(i).getErrors().get(0).getMessage();
            }
            results.add(dto);
        }
        return results;
    }

    public class TaskDto {
        public String originalId { get; set; }
        public String sourceId { get; set; }
        public String sourceCaseId { get; set; }

        public Task record { get; set; }

        public TaskDto(Task record, String sourceCaseId) {
            this.originalId = record.Id;
            this.sourceId = record.SF_Source_Id__c;
            this.sourceCaseId = String.isNotBlank(sourceCaseId) ? sourceCaseId : record.WhatId;
            this.record = record;
        }
    }

    public class ResultDto {
        public String message;
        public Boolean success;

        public List<RecordResultDto> recordResults;

        public ResultDto() {
            this.success = true;
            this.message = 'See Record Results';
            this.recordResults = new List<RecordResultDto>();
        }
    }

    public class RecordResultDto {
        public String recordId;
        public String message;
        public Boolean success;
    }
}