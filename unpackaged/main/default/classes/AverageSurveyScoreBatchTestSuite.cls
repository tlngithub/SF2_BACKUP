/**
 * Created by maximelets on 10/07/2024.
 */
@IsTest
private class AverageSurveyScoreBatchTestSuite {
    private static final Id LC_ACCOUNT_RT = Account.getSObjectType()
        .getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get('Clinical_Practice')
        .getRecordTypeId();
    private static final Id LC_CONTACT_RT = Contact.getSObjectType()
        .getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get('Lactation_Consultant')
        .getRecordTypeId();
    @TestSetup
    private static void setupData() {
        Account LCPAccount = new Account(Name = 'LCP', RecordTypeId = LC_ACCOUNT_RT);
        insert LCPAccount;
        List<Contact> consultants = new List<Contact>{
            new Contact(FirstName = '1', LastName = '1', RecordTypeId = LC_CONTACT_RT, AccountId = LCPAccount.Id),
            new Contact(FirstName = '2', LastName = '2', RecordTypeId = LC_CONTACT_RT, AccountId = LCPAccount.Id),
            new Contact(FirstName = '3', LastName = '3', RecordTypeId = LC_CONTACT_RT, AccountId = LCPAccount.Id)
        };
        insert consultants;
        List<Patient_Visit_Survey__c> surveys = new List<Patient_Visit_Survey__c>{
            // LC 1 - 60 percents
            new Patient_Visit_Survey__c(NPS_Score__c = 10, LC__c = consultants.get(0).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 10, LC__c = consultants.get(0).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 10, LC__c = consultants.get(0).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 10, LC__c = consultants.get(0).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 10, LC__c = consultants.get(0).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 10, LC__c = consultants.get(0).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 10, LC__c = consultants.get(0).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 10, LC__c = consultants.get(0).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 6, LC__c = consultants.get(0).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 6, LC__c = consultants.get(0).Id, LCP__c = LCPAccount.Id),
            // LC 2
            new Patient_Visit_Survey__c(NPS_Score__c = 10, LC__c = consultants.get(1).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 10, LC__c = consultants.get(1).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 6, LC__c = consultants.get(1).Id, LCP__c = LCPAccount.Id),
            // LC 3
            new Patient_Visit_Survey__c(NPS_Score__c = null, LC__c = consultants.get(2).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 0, LC__c = consultants.get(2).Id, LCP__c = LCPAccount.Id),
            new Patient_Visit_Survey__c(NPS_Score__c = 6, LC__c = consultants.get(2).Id, LCP__c = LCPAccount.Id)
        };

        insert surveys;
    }
    @IsTest
    private static void calculateNPS() {
        System.Test.startTest();
        Database.executeBatch(new AverageSurveyScoreBatch());
        System.Test.stopTest();

        Account LCPAccount = [SELECT Average_NPS_Score__c FROM Account LIMIT 1];
        Assert.isTrue(LCPAccount.Average_NPS_Score__c != null, 'Average Score was updated');
        List<Contact> consultants = [SELECT LastName, Average_NPS_Score__c FROM Contact WHERE AccountId = :LCPAccount.Id];
        for (Contact lc : consultants) {
            System.debug(lc);
            switch on lc.LastName {
                when '1' {
                    Assert.areEqual(60, lc.Average_NPS_Score__c, 'Average Score was updated');
                }
                when '2' {
                    Assert.areEqual(33, lc.Average_NPS_Score__c.intValue(), 'Average Score was updated');
                }
                when '3' {
                    Assert.areEqual(-100, lc.Average_NPS_Score__c, 'Average Score was updated');
                }
                when else {
                    Assert.isFalse(1 == 1, 'Something gone wrong');
                }
            }
        }
    }
}