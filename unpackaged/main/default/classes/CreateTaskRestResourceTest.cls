/**
 * @description Test class for CreateTaskRestResource.cls
 * @author Eugene
 * @date 08.11.2024
**/
@IsTest
private class CreateTaskRestResourceTest {

    @IsTest
    private static void restResourceTest() {
        List<Task> tasks = [
                SELECT WhatId, Subject, Priority, SF_Source_Id__c
                FROM Task];

        tasks.get(0).Priority = TaskConstants.PRIORITY_HIGH;
        tasks.get(1).Priority = TaskConstants.PRIORITY_NORMAL;

        List<CreateTaskRestResource.TaskDto> tasksToSync = new List<CreateTaskRestResource.TaskDto>();
        tasksToSync.add(new CreateTaskRestResource.TaskDto(tasks.get(0), ''));
        tasksToSync.get(0).sourceId = tasks.get(0).Id;

        tasksToSync.add(new CreateTaskRestResource.TaskDto(tasks.get(1), ''));
        tasksToSync.get(1).sourceId = tasks.get(1).Id;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sync-task';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(JSON.serialize(tasksToSync));
        RestContext.request = req;

        RestContext.response = new RestResponse();

        System.Test.startTest();

        CreateTaskRestResource.doPost();

        System.Test.stopTest();

        CreateTaskRestResource.ResultDto result = (CreateTaskRestResource.ResultDto)JSON.deserialize(
            RestContext.response.responseBody.toString(), CreateTaskRestResource.ResultDto.class);

        Assert.isTrue(result.success, 'As we pretend it is success call.');
        Assert.areEqual(2, result.recordResults.size(), 'As we send two records and shall get result for two as well.');

        Assert.isTrue(result.recordResults.get(0).success, 'As we pretend it is success call.');
        Assert.isTrue(result.recordResults.get(0).success, 'As we pretend it is success call.');
    }

    @TestSetup
    private static void setupData() {
        Case billingCase = new Case(
                RecordTypeId = CaseConstants.CASE_BILLING_RT_ID,
                Type = 'Financial Rules',
                Status = 'New',
                Subject = 'SF2SF Sync');
        Database.insert(billingCase);

        List<Task> tasksToSync = new List<Task> {
                new Task(
                        WhatId = billingCase.Id,
                        Subject = 'SF2SF Sync'),
                new Task(
                        WhatId = billingCase.Id,
                        Subject = 'SF2SF Sync One More')
        };
        Database.insert(tasksToSync);
    }
}