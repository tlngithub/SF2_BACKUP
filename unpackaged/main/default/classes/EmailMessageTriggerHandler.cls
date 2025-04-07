/**
 * @description Trigger handler for EmailMessage trigger.
 * @author Eugene
 * @date 13.01.2024
**/
public without sharing class EmailMessageTriggerHandler {

    @TestVisible
    private static final String AUTO_REPLY_SUBJECT_KEY = 'Auto Reply Email Sent';

    public static void handleAfterInsert(List<EmailMessage> newRecords) {
        captureInitialResponseTime(newRecords);
    }

    private static void captureInitialResponseTime(List<EmailMessage> newRecords) {
        List<Id> caseIds = new List<Id>();
        for(EmailMessage record : newRecords) {
            if( ! record.Incoming && String.isNotBlank(record.ParentId) && ! record.Subject.contains(AUTO_REPLY_SUBJECT_KEY)) {
                caseIds.add(record.ParentId);
            }
        }

        List<Case> casesToUpdate = [
                SELECT CreatedDate, Initial_Response_Time__c
                FROM Case
                WHERE Id IN :caseIds
                AND Initial_Response_Time__c = NULL];

        for(Case record : casesToUpdate) {
            // Calculated in hours
            record.Initial_Response_Time__c = (Decimal.valueOf(System.now().getTime() - record.CreatedDate.getTime()) / 1000 / 60 / 60);
        }
        Database.update(casesToUpdate);
    }
}