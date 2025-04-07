/**
 * Created by maximelets on 02/08/2024.
 */

public without sharing class LCDeactivationBatch implements Database.Batchable<SObject>, Schedulable {
    private final Integer MAX_DAYS = GlobalConstants.GLOBAL_SETTINGS?.LC_Pending_Deactivation_Max_Days__c != null
        ? GlobalConstants.GLOBAL_SETTINGS?.LC_Pending_Deactivation_Max_Days__c.intValue()
        : 30;
    private final Date DISABLEMENT_DATE_LIMIT = System.today().addDays(-MAX_DAYS);
    @TestVisible
    private static final Id CONTACT_LACTATION_CONSULTANT_RT = Contact.SObjectType.getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get('Lactation_Consultant')
        .getRecordTypeId();

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [
                SELECT Id, Status__c, Pending_Deactivation_Since__c
                FROM Contact
                WHERE
                    Status__c = :GlobalConstants.LC_STATUS_PENDING_DISABLEMENT
                    AND Pending_Deactivation_Since__c <= :this.DISABLEMENT_DATE_LIMIT
                    AND RecordTypeId = :CONTACT_LACTATION_CONSULTANT_RT
            ]
        );
    }

    public void execute(Database.BatchableContext context, List<Contact> scope) {
        for (Contact record : scope) {
            record.Pending_Deactivation_Since__c = null;
            record.Status__c = GlobalConstants.LC_STATUS_DISABLED;
        }

        Database.update(scope, false);
    }

    public void finish(Database.BatchableContext context) {
    }

    public void execute(SchedulableContext context) {
        Database.executeBatch(new LCDeactivationBatch());
    }
}