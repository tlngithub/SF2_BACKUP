/** 
 * @Author: gleb.demidchik@mavenmule.com 
 * @Date: 2025-01-15 
 * @Desc: Account trigger handler
*/
public with sharing class AccountTriggerHandler {
    public static final String ELIGIBILITY_CASE_RECORD_TYPE_NAME = 'Eligibility';
    public static final String ELIGIBILITY_CASE_STATUS_INSURANCE_FINALIZED = 'Insurance Finalized';

    public static void handleAfterUpdate(Map<Id, Account> oldRecordsMap, List<Account> newRecords) {
        //BUG 29933: If either lead or account eligibility status is changed, auto-close any associated cases with a record type of "Eligibility"
        //accounts with Eligibility status changed
        Set<Id> accountIds = new Set<Id>();
        for (Account accountRecord : newRecords) {
            // if the Eligibility Status has changed, tag it to close the related Eligibility Case
            if (accountRecord.Eligibility_Status__pc != oldRecordsMap.get(accountRecord.Id).Eligibility_Status__pc) {
                accountIds.add(accountRecord.Id);
            }
        }

        if (! accountIds.isEmpty()) {
            List<Case> relatedCases = [
                SELECT Id, Status
                FROM Case
                WHERE RecordType.Name = :ELIGIBILITY_CASE_RECORD_TYPE_NAME
                AND Status != :ELIGIBILITY_CASE_STATUS_INSURANCE_FINALIZED
                AND AccountId IN :accountIds];

            for (Case caseRecord : relatedCases) {
                caseRecord.Status = ELIGIBILITY_CASE_STATUS_INSURANCE_FINALIZED;
            }
            if (! relatedCases.isEmpty()) {
                Database.update(relatedCases);
            }
        }
    }
}