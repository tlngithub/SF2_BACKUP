/**
 * Lead trigger handler.
 */
public with sharing class LeadTriggerHandler {
    public static final Id LEAD_GRANT_APPLICANT_RT = Lead.SObjectType.getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get('Grant_Applicant')
        .getRecordTypeId();
    public static final String ELIGIBILITY_STATUS_ELIGIBLE = 'Eligible';
    public static final String ELIGIBILITY_STATUS_INELIGIBLE = 'Ineligible';
    public static final String LEAD_STATUS_CONVERTED = 'Qualified';
    public static final String ELIGIBILITY_CASE_RECORD_TYPE_NAME = 'Eligibility';
    public static final String ELIGIBILITY_CASE_STATUS_CLOSED = 'Insurance Finalized';

    public static void handleBeforeInsertUpdate(List<Lead> newRecords) {
        for (Lead lead : newRecords) {
            if (!lead.IsConverted && lead.RecordTypeId == LEAD_GRANT_APPLICANT_RT && String.isBlank(lead.Employer_Name__c) && String.isNotBlank(lead.Company)) {
                // lead company populated in the SCR Flow, different behaviour between BLACK AND TLN Grant screens
                // there is no way to know in the trigger which type of Lead is that
                lead.Employer_Name__c = lead.Company;
            }
        }
    }
    public static void handleAfterUpdate(List<Lead> oldRecords, List<Lead> newRecords) {
        Set<Id> convertedLeadIds = new Set<Id>();
        List<Lead> eligibleLeads = new List<Lead>();
        List<Lead> ineligibleLeads = new List<Lead>();
        Set<Id> convertedAccountIds = new Set<Id>();
        for (Lead lead : newRecords != null ? newRecords : oldRecords) {
            // if the Lead has just been converted, tag it for Address mapping
            if (lead.IsConverted && lead.ConvertedContactId != null) {
                convertedLeadIds.add(lead.Id);
            }
            // if the Eligibility Status has changed, tag it to close the related Eligibility Case
            else if (lead.Eligibility_Status__c != null && oldRecords != null) {
                Lead oldLead = new Map<Id, Lead>(oldRecords).get(lead.Id);
                if (lead.Eligibility_Status__c != oldLead?.Eligibility_Status__c) {
                    if (lead.Eligibility_Status__c == ELIGIBILITY_STATUS_ELIGIBLE) {
                        eligibleLeads.add(lead);
                    } else {
                        ineligibleLeads.add(lead);
                    }
                }
            }
        }

        // User Story 18685: SF2 Create lead and contact fields for grant applicants/recipients
        // User Story 28756: SF2 Patient Accounts show all related eligibility cases
        if (!convertedLeadIds.isEmpty()) {
            List<Lead> leads = [
                SELECT ConvertedAccountId, ConvertedContactId, LCP_Business_Location__c, (SELECT Id FROM Eligibility_Cases__r)
                FROM Lead
                WHERE Id IN :convertedLeadIds
            ];

            List<Contact> contacts = new List<Contact>();
            List<Case> cases = new List<Case>();
            // map the Address from the Lead to the Contact
            for (Lead lead : leads) {
                if (lead.LCP_Business_Location__c != null) {
                    contacts.add(
                        new Contact(
                            Id = lead.ConvertedContactId,
                            LCP_Business_Location__Street__s = lead.LCP_Business_Location__c.getStreet(),
                            LCP_Business_Location__City__s = lead.LCP_Business_Location__c.getCity(),
                            LCP_Business_Location__StateCode__s = lead.LCP_Business_Location__c.getStateCode(),
                            LCP_Business_Location__PostalCode__s = lead.LCP_Business_Location__c.getPostalCode(),
                            LCP_Business_Location__CountryCode__s = lead.LCP_Business_Location__c.getCountryCode()
                        )
                    );
                }
                // link the Eligibility Cases from the Lead to the Patient Account
                if (!lead.Eligibility_Cases__r.isEmpty()) {
                    for (Case eligibilityCase : lead.Eligibility_Cases__r) {
                        cases.add(new Case(Id = eligibilityCase.Id, AccountId = lead.ConvertedAccountId));
                        convertedAccountIds.add(lead.ConvertedAccountId);
                    }
                }
            }
            update contacts;
            update cases;
        }
        // User Story 20038: SF2: Eligibility Status Change Triggers
        if (!eligibleLeads.isEmpty()) {
            List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
            for (Lead eligibleLead : eligibleLeads) {
                Database.LeadConvert leadConvert = new Database.LeadConvert();
                leadConvert.setLeadId(eligibleLead.Id);
                leadConvert.setConvertedStatus(LEAD_STATUS_CONVERTED);
                leadConvert.setDoNotCreateOpportunity(true);
                leadConverts.add(leadConvert);
            }
            Database.convertLead(leadConverts);
        }
        if (!eligibleLeads.isEmpty() || !ineligibleLeads.isEmpty()) {
            List<Case> eligibilityCases = [
                SELECT OwnerId
                FROM Case
                WHERE
                    RecordType.Name = :ELIGIBILITY_CASE_RECORD_TYPE_NAME
                    AND Status != :ELIGIBILITY_CASE_STATUS_CLOSED
                    AND (Patient_Lead__c IN :eligibleLeads
                    OR Patient_Lead__c IN :ineligibleLeads
                    OR AccountId IN :convertedAccountIds)
            ];

            for (Case eligibilityCase : eligibilityCases) {
                eligibilityCase.Status = ELIGIBILITY_CASE_STATUS_CLOSED;
            }
            if (!eligibilityCases.isEmpty()) {
                update eligibilityCases;
            }
        }
    }
    
}