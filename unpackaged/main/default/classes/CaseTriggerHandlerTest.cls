/**
 * @description Test class for CaseTriggerHandler.cls
 * @author Eugene
 * @date 17.01.2025
**/
@IsTest
private class CaseTriggerHandlerTest {

    @IsTest
    private static void calculateWaitingAndResolutionTimeTest() {
        List<Case> cases = [
                SELECT Status, Time_Spent_Waiting__c, Stopped_Since__c
                FROM Case ORDER BY Subject];

        // Pretend we have cases in waiting status and set some buffer time
        cases.get(1).Status = CaseConstants.STATUS_WAITING_ON_EXTERNAL_RESPONSE;
        cases.get(1).Time_Spent_Waiting__c = 4.50;
        cases.get(2).Status = CaseConstants.STATUS_WAITING_ON_EXTERNAL_RESPONSE;
        cases.get(2).Time_Spent_Waiting__c = 5.50;
        cases.get(3).Status = CaseConstants.STATUS_WAITING_ON_EXTERNAL_RESPONSE;
        cases.get(3).Time_Spent_Waiting__c = 12.30;
        cases.get(4).Status = CaseConstants.STATUS_WAITING_ON_EXTERNAL_RESPONSE;
        cases.get(4).Time_Spent_Waiting__c = 20.20;
        Database.update(cases);

        // Need second update to bypass triggers to set stopped time in the past
        cases.get(2).Stopped_Since__c = System.now().addHours(-8);
        cases.get(3).Stopped_Since__c = System.now().addHours(-2);
        cases.get(4).Stopped_Since__c = System.now().addHours(-1);
        Database.update(cases);

        System.Test.startTest();

        for(Case record : cases) {
            record.Status = CaseConstants.STATUS_RESOLVED;
        }
        Database.update(cases);

        System.Test.stopTest();

        Map<Id, Case> casesByIds = new Map<Id, Case>([
                SELECT Subject, Time_Spent_Waiting__c, Resolution_Time__c
                FROM Case
                WHERE Id IN :cases]);

        Assert.areEqual(24, casesByIds.get(cases.get(0).Id).Resolution_Time__c.intValue(),
            'As we created case 24 hrs ago and resolving it right away.');
        Assert.areEqual(0, casesByIds.get(cases.get(0).Id).Time_Spent_Waiting__c.intValue(),
            'As we never set or moved to waiting.');

        Assert.areEqual(19, casesByIds.get(cases.get(1).Id).Resolution_Time__c.intValue(),
            'As we pretended case was waiting for 4.5 hrs so this time is deducted.');
        Assert.areEqual(4, casesByIds.get(cases.get(1).Id).Time_Spent_Waiting__c.intValue(),
            'As we pretended case was waiting for few hrs.');

        Assert.areEqual(34, casesByIds.get(cases.get(2).Id).Resolution_Time__c.intValue(),
            'As we pretended case was waiting for 5.5 hrs and waiting in external another 8 hrs before resolution.');
        Assert.areEqual(13, casesByIds.get(cases.get(2).Id).Time_Spent_Waiting__c.intValue(),
            'Original 5.5 + 8 waiting = 13 hrs.');

        Assert.areEqual(33, casesByIds.get(cases.get(3).Id).Resolution_Time__c.intValue(),
            'As we pretended case was waiting for 12.3 hrs and waiting in external another 2 hrs before resolution.');
        Assert.areEqual(14, casesByIds.get(cases.get(3).Id).Time_Spent_Waiting__c.intValue(),
            'Original 12.3 + 2 waiting = 14 hrs.');

        Assert.areEqual(26, casesByIds.get(cases.get(4).Id).Resolution_Time__c.intValue(),
            'As we pretended case was waiting for 20.20 hrs and waiting in external another 1 hr before resolution.');
        Assert.areEqual(21, casesByIds.get(cases.get(4).Id).Time_Spent_Waiting__c.intValue(),
            'Original 20.20 + 1 waiting = 21 hrs.');
    }

    @IsTest
    private static void rememberRecordTypeTest() {
        Case record = [SELECT Record_Type_Name__c FROM Case WHERE RecordTypeId = :CaseConstants.CASE_INTAKE_RT_ID LIMIT 1];

        Assert.areEqual('Intake', record.Record_Type_Name__c, 'As we shall populate in before logic.');
    }

    @IsTest
    private static void testCheckCaseOwner() {
        User integrationUser = new User(FirstName = 'Patient', LastName ='Integration', UserName = 'integrationtest@tln.care', Alias = 'intuser', Email = 'integration@test.com',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey ='en_US', ProfileId = UserInfo.getProfileId(), TimeZoneSidKey = 'America/Los_Angeles');
        insert integrationUser;
        Case eligibilityCase = [SELECT OwnerId FROM Case LIMIT 1];
        Id originalOwnerId = eligibilityCase.OwnerId;

        Test.startTest();
        System.runAs(integrationUser) {
            eligibilityCase.Status = CaseConstants.STATUS_INSURANCE_FINALIZED;
            eligibilityCase.OwnerId = integrationUser.Id;
            update eligibilityCase;
        }
        Test.stopTest();

        eligibilityCase = [SELECT OwnerId FROM Case WHERE Id = :eligibilityCase.Id];
        System.assertEquals(originalOwnerId, eligibilityCase.OwnerId, 'Wrong Owner.');
    }


    @TestSetup
    private static void setupData() {
        List<Case> cases = new List<Case>();
        for(Integer i = 0; i < 5; i++) {
            cases.add(new Case(
                    RecordTypeId = CaseConstants.CASE_INTAKE_RT_ID,
                    Type = 'Other',
                    Status = 'New',
                    Subject = 'Support Request ' + i));
        }
        cases.get(0).RecordTypeId = CaseConstants.CASE_USER_SUPPORT_RT_ID;
        Database.insert(cases);

        Test.setCreatedDate(cases.get(0).Id, System.now().addDays(-1));
        Test.setCreatedDate(cases.get(1).Id, System.now().addDays(-1));
        Test.setCreatedDate(cases.get(2).Id, System.now().addDays(-2));
        Test.setCreatedDate(cases.get(3).Id, System.now().addDays(-2));
        Test.setCreatedDate(cases.get(4).Id, System.now().addDays(-2));
    }
}