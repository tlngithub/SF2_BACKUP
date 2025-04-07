/**
 * Created by maximelets on 02/08/2024.
 */

@IsTest
private class LCDeactivationBatchTestSuite {
    @IsTest
    private static void testBehavior() {
        System.Test.startTest();
        Database.executeBatch(new LCDeactivationBatch());
        System.Test.stopTest();

        for (Contact record : [SELECT Id, LastName, Status__c, Pending_Deactivation_Since__c, RecordTypeId FROM Contact]) {
            if (record.RecordTypeId == LCDeactivationBatch.CONTACT_LACTATION_CONSULTANT_RT) {
                if (record.LastName == 'Deactivation') {
                    Assert.areEqual(GlobalConstants.LC_STATUS_DISABLED, record.Status__c, 'Record was deactivated, conditions met.');
                    Assert.areEqual(null, record.Pending_Deactivation_Since__c, 'Record was deactivated, conditions met.');
                } else {
                    Assert.areEqual(GlobalConstants.LC_STATUS_PENDING_DISABLEMENT, record.Status__c, 'No changes to record.');
                    Assert.areNotEqual(null, record.Pending_Deactivation_Since__c, 'Record was deactivated, conditions met.');
                }
            } else {
                //not LC RT
                Assert.isTrue(record.Pending_Deactivation_Since__c != null, 'No changes to record as it is for different record type.');
            }
        }
    }

    @TestSetup
    private static void setupData() {
        insert new General_Settings__c(Triggers_Disabled__c = true);
        List<Contact> contacts = new List<Contact>{
            new Contact(
                LastName = 'Deactivation',
                RecordTypeId = LCDeactivationBatch.CONTACT_LACTATION_CONSULTANT_RT,
                Status__c = GlobalConstants.LC_STATUS_PENDING_DISABLEMENT,
                Pending_Deactivation_Since__c = System.today().addDays(-300)
            ),
            new Contact(
                LastName = 'Not Deactivated Yet',
                RecordTypeId = LCDeactivationBatch.CONTACT_LACTATION_CONSULTANT_RT,
                Status__c = GlobalConstants.LC_STATUS_PENDING_DISABLEMENT,
                Pending_Deactivation_Since__c = System.today().addDays(-1)
            ),
            new Contact(
                LastName = 'Not LC', 
                RecordTypeId = Contact.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Grant_Applicant').getRecordTypeId(),
                Pending_Deactivation_Since__c = System.today().addDays(-300)
            )
        };
        insert contacts;

        General_Settings__c settings = General_Settings__c.getOrgDefaults();
        settings.LC_Pending_Deactivation_Max_Days__c = 30;
        upsert settings;
    }
}