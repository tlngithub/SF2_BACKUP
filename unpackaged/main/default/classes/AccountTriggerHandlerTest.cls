/** 
 * @Author: gleb.demidchik@mavenmule.com 
 * @Date: 2025-01-15 
 * @Desc: Unit tests for the Lead trigger handler.
*/
@isTest
public class AccountTriggerHandlerTest {
    public static final String ELIGIBILITY_STATUS_INELIGIBLE = 'Ineligible';
    public static final String ELIGIBILITY_STATUS_ELIGIBLE = 'Eligible';

    @isTest
    public static void ineligibleAccountTest() {
        insert new Flow_Settings__c(SetupOwnerId = UserInfo.getUserId(), Accounts_Enabled__c = false, Contacts_Enabled__c = false);
        Lead lead = TestDataFactory.createLead();
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        insert lead;

        lead.Eligibility_Status__c = ELIGIBILITY_STATUS_ELIGIBLE;
        update lead;
        lead = [SELECT ConvertedAccountId FROM Lead WHERE Id = :lead.Id];
        
        Case eligibilityCase = TestDataFactory.createCase();
        eligibilityCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(AccountTriggerHandler.ELIGIBILITY_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        eligibilityCase.AccountId = lead.ConvertedAccountId;
        insert eligibilityCase;

        Account accountRecord = [SELECT Eligibility_Status__pc, RecordTypeId FROM Account WHERE Id = :eligibilityCase.AccountId];
        accountRecord.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        update accountRecord;
        
        Test.startTest();  
        accountRecord.Eligibility_Status__pc = ELIGIBILITY_STATUS_INELIGIBLE;
        update accountRecord;
        Test.stopTest();

        eligibilityCase = [SELECT Status FROM Case WHERE Id = :eligibilityCase.Id];
        Assert.areEqual(AccountTriggerHandler.ELIGIBILITY_CASE_STATUS_INSURANCE_FINALIZED, eligibilityCase.Status, 'Case must be closed after changing eligibility status on related account');
    }
}