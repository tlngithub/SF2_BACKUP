/**
 * Created by maximelets on 02/08/2024.
 */

@IsTest
private class ContactTriggerHandlerTestSuite {
    @IsTest
    private static void testBehavior() {
        List<Contact> contacts = new List<Contact>{
            new Contact(LastName = 'To NULL Field', Pending_Deactivation_Since__c = System.now(), Status__c = GlobalConstants.LC_STATUS_DISABLED),
            new Contact(LastName = 'To SET Field', Status__c = GlobalConstants.LC_STATUS_PENDING_DISABLEMENT)
        };
        insert contacts;

        System.Test.startTest();
        contacts = [SELECT Id, LastName, Pending_Deactivation_Since__c, Status__c FROM Contact];
        for (Contact record : contacts) {
            if (record.LastName == 'To NULL Field') {
                Assert.areEqual(null, record.Pending_Deactivation_Since__c, 'Field updated to NULL, as not relevant status was used');
                record.Status__c = GlobalConstants.LC_STATUS_PENDING_DISABLEMENT;
            } else {
                Assert.isTrue(timeAlmostEqual(System.now(), record.Pending_Deactivation_Since__c), 'Field updated to NOW, as Contact status was set to PD');
                record.Status__c = GlobalConstants.LC_STATUS_DISABLED;
            }
        }
        update contacts;
        System.Test.stopTest();

        contacts = [SELECT Id, LastName, Pending_Deactivation_Since__c, Status__c FROM Contact];
        for (Contact record : contacts) {
            if (record.LastName == 'To NULL Field') {
                Assert.isTrue(timeAlmostEqual(System.now(), record.Pending_Deactivation_Since__c), 'Field updated to NOW, as Contact status was set to PD');
            } else {
                Assert.areEqual(null, record.Pending_Deactivation_Since__c, 'Field updated to NULL, as not relevant status was used');
            }
        }
    }

    private static Boolean timeAlmostEqual(Datetime datetime1, Datetime datetime2) {
        Long time1 = datetime1.getTime();
        Long time2 = datetime2.getTime();
        return Math.abs(time1 - time2) < 10000;
    }
}