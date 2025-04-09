/**
 * @description Test class for EmailMessageTriggerHandler.cls
 * @author Eugene
 * @date 20.01.2025
**/
@IsTest
private class EmailMessageTriggerHandlerTest {

    @IsTest
    private static void setCaseInitialResponseTimeTest() {
        List<Case> cases = [
                SELECT Id
                FROM Case ORDER BY Subject];

        System.Test.startTest();

        List<EmailMessage> replyMessages = new List<EmailMessage> {
                new EmailMessage(
                        FromAddress = 'care@tln.care',
                        ParentId = cases.get(0).Id,
                        Status = '1',
                        Subject = 'Re: Reply Message',
                        ToAddress = 'test@test.com'),
                new EmailMessage(
                        FromAddress = 'care@tln.care',
                        ParentId = cases.get(1).Id,
                        Status = '1',
                        Subject = 'Re: ' + EmailMessageTriggerHandler.AUTO_REPLY_SUBJECT_KEY,
                        ToAddress = 'test@test.com')
        };
        Database.insert(replyMessages);

        System.Test.stopTest();

        Map<Id, Case> casesByIds = new Map<Id, Case>([
                SELECT Initial_Response_Time__c
                FROM Case
                WHERE Id IN :cases]);

        Assert.areEqual(24, casesByIds.get(cases.get(0).Id).Initial_Response_Time__c.intValue(),
            'As we pretend someone replied to a case.');
        Assert.isTrue(casesByIds.get(cases.get(1).Id).Initial_Response_Time__c == NULL,
            'As we pretend it was an auto-reply.');
    }

    @TestSetup
    private static void setupData() {
        List<Case> cases = new List<Case>();
        for(Integer i = 0; i < 2; i++) {
            cases.add(new Case(
                    RecordTypeId = CaseConstants.CASE_INTAKE_RT_ID,
                    Type = 'Other',
                    Status = 'New',
                    Subject = 'Support Request ' + i));
        }
        Database.insert(cases);

        Test.setCreatedDate(cases.get(0).Id, System.now().addDays(-1));
        Test.setCreatedDate(cases.get(1).Id, System.now().addDays(-1));
    }
}