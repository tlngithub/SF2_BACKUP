/**
 * @description Test class for SyncTaskBatch.cls
 * @author Eugene
 * @date 07.11.2024
**/
@IsTest
private class SyncTaskBatchTest {

    @IsTest
    private static void syncTest() {
        Case billingCase = [SELECT Id FROM Case WHERE RecordTypeId = :CaseConstants.CASE_BILLING_RT_ID LIMIT 1];
        Case intakeCase = [SELECT Id FROM Case WHERE RecordTypeId = :CaseConstants.CASE_INTAKE_RT_ID LIMIT 1];

        List<Task> tasksToSync = new List<Task> {
                new Task(
                        WhatId = billingCase.Id,
                        Subject = 'SF2SF Sync'),
                new Task(
                        WhatId = intakeCase.Id,
                        Subject = 'SF2SF Not to Sync')
        };
        Database.insert(tasksToSync);

        Map<Id, Task> tasksToCheck = new Map<Id, Task>([
                SELECT Sync_Status__c
                FROM Task]);

        Assert.areEqual(TaskConstants.SYNC_STATUS_NEED_SYNC, tasksToCheck.get(tasksToSync.get(0).Id).Sync_Status__c,
            'As it is new task and linked to billing case.');
        Assert.areEqual(NULL, tasksToCheck.get(tasksToSync.get(1).Id).Sync_Status__c,
            'As task linked to intake case which we do not sync.');

        CreateTaskRestResource.ResultDto result = new CreateTaskRestResource.ResultDto();
        CreateTaskRestResource.RecordResultDto recordResult = new CreateTaskRestResource.RecordResultDto();
        recordResult.recordId = tasksToSync.get(0).Id;
        recordResult.success = true;
        recordResult.message = '';
        result.recordResults.add(recordResult);

        Test.setMock(HttpCalloutMock.class, new SyncMock(JSON.serialize(result)));

        System.Test.startTest();


        Database.executeBatch(new SyncTaskBatch());

        System.Test.stopTest();

        tasksToCheck = new Map<Id, Task>([
                SELECT Sync_Status__c
                FROM Task]);

        Assert.areEqual(TaskConstants.SYNC_STATUS_SYNCED, tasksToCheck.get(tasksToSync.get(0).Id).Sync_Status__c,
            'As we mocked in response successful sync.');
        Assert.areEqual(NULL, tasksToCheck.get(tasksToSync.get(1).Id).Sync_Status__c,
            'No changes as it is ignored by batch.');
    }

    @TestSetup
    private static void setupData() {
        List<Case> cases = new List<Case> {
                new Case(
                        RecordTypeId = CaseConstants.CASE_BILLING_RT_ID,
                        Type = 'Financial Rules',
                        Status = 'New',
                        Subject = 'SF2SF Sync'),
                new Case(
                        RecordTypeId = CaseConstants.CASE_INTAKE_RT_ID,
                        Type = 'Financial Rules',
                        Status = 'New',
                        Subject = 'SF2SF Not to Sync')
        };
        Database.insert(cases);
    }

    private class SyncMock implements HttpCalloutMock {
        private String responseBody;

        public SyncMock(String responseBody) {
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest request) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(this.responseBody);
            return res;
        }
    }
}