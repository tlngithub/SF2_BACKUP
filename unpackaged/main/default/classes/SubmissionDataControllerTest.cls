/**
 * @description Unit tests for the SubmissionDataController.cls
**/
@IsTest
private class SubmissionDataControllerTest {

    @IsTest
    private static void fetchDataTest() {
        Lead peterParker = new Lead(
                FirstName = 'Peter',
                LastName = 'Parker',
                External_ID__c = 'peter-parker-external-id',
                RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId());
        Database.insert(peterParker);

        SubmissionService.accessToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIs';
        SubmissionMock submissionMock = new SubmissionMock();
        System.Test.setMock(HttpCalloutMock.class, submissionMock);

        System.Test.startTest();

        SubmissionDataController.ExternalData output = SubmissionDataController.fetchData(peterParker.Id);

        System.Test.stopTest();

        Assert.isFalse(output.submissions.isEmpty(), 'As we mocked data in response.');
    }
}