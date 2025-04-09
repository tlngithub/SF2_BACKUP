/**
 * Unit tests for the Lead trigger handler.
 */
@isTest
public class LeadTriggerHandlerTest {
    @isTest
    public static void leadConversionAddressMappingTest() {
        insert new Flow_Settings__c(SetupOwnerId = UserInfo.getUserId(), Accounts_Enabled__c = false, Contacts_Enabled__c = false);
        Lead lead = TestDataFactory.createLead();
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        lead.LCP_Business_Location__PostalCode__s = 'CO';
        insert lead;
        
        Test.startTest();
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(lead.Id);
        leadConvert.setDoNotCreateOpportunity(true);
        leadConvert.setConvertedStatus('Qualified');
        Database.convertLead(leadConvert);
        Test.stopTest();

        Contact contact = [SELECT LCP_Business_Location__c FROM Contact];
        System.assertEquals(lead.LCP_Business_Location__PostalCode__s, contact.LCP_Business_Location__c.getPostalCode(), 'Wrong Postal Code.');
    }
    
    @isTest
    public static void eligibleLeadConversionTest() {
        insert new Flow_Settings__c(SetupOwnerId = UserInfo.getUserId(), Accounts_Enabled__c = false, Contacts_Enabled__c = false);
        Lead lead = TestDataFactory.createLead();
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        insert lead;
        
        Case eligibilityCase = TestDataFactory.createCase();
        eligibilityCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(LeadTriggerHandler.ELIGIBILITY_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        eligibilityCase.Patient_Lead__c = lead.Id;
        insert eligibilityCase;
        
        Test.startTest();
        lead.Eligibility_Status__c = LeadTriggerHandler.ELIGIBILITY_STATUS_ELIGIBLE;
        update lead;
        Test.stopTest();

        lead = [SELECT ConvertedAccountId, Status FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(LeadTriggerHandler.LEAD_STATUS_CONVERTED, lead.Status, 'Wrong Lead Status.');
        eligibilityCase = [SELECT AccountId, Status FROM Case WHERE Id = :eligibilityCase.Id];
        System.assertEquals(LeadTriggerHandler.ELIGIBILITY_CASE_STATUS_CLOSED, eligibilityCase.Status, 'Wrong Case Status.');
        System.assertEquals(lead.ConvertedAccountId, eligibilityCase.AccountId, 'Eligibility Case is not linked to the Patient Account after converting the lead.');
    }

    @isTest
    public static void ineligibleLeadTest() {
        Lead lead = TestDataFactory.createLead();
        lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
        insert lead;
        
        Case eligibilityCase = TestDataFactory.createCase();
        eligibilityCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(LeadTriggerHandler.ELIGIBILITY_CASE_RECORD_TYPE_NAME).getRecordTypeId();
        eligibilityCase.Patient_Lead__c = lead.Id;
        insert eligibilityCase;
        
        Test.startTest();
        lead.Eligibility_Status__c = LeadTriggerHandler.ELIGIBILITY_STATUS_INELIGIBLE;
        update lead;
        Test.stopTest();

        lead = [SELECT Status FROM Lead WHERE Id = :lead.Id];
        System.assertNotEquals(LeadTriggerHandler.LEAD_STATUS_CONVERTED, lead.Status, 'Wrong Lead Status.');
        eligibilityCase = [SELECT Status FROM Case WHERE Id = :eligibilityCase.Id];
        System.assertEquals(LeadTriggerHandler.ELIGIBILITY_CASE_STATUS_CLOSED, eligibilityCase.Status, 'Wrong Case Status.');
    }

    @IsTest
    private static void beforeInsertUpdateGrantApplicant() {
        Lead lead = TestDataFactory.createLead();
        lead.RecordTypeId = LeadTriggerHandler.LEAD_GRANT_APPLICANT_RT;
        lead.Company = 'Test Company populated from flow';
        lead.Email = 'test@test.com';

        System.Test.startTest();
        insert lead;
        lead = [SELECT Employer_Name__c, Company FROM Lead WHERE Id = :lead.Id];
        Assert.areEqual(lead.Company, lead.Employer_Name__c, 'Employer_Name__c has same value as Company field');
        lead.Company = 'Company updated';
        lead.Employer_Name__c = null;
        update lead;
        lead = [SELECT Employer_Name__c, Company FROM Lead WHERE Id = :lead.Id];
        Assert.areEqual(lead.Company, lead.Employer_Name__c, 'Employer_Name__c has same value as Company field');
        System.Test.stopTest();
    }
}