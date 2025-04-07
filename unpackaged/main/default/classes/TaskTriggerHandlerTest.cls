/**
 * @description Test class for TaskTriggerHandler.cls
 * @author Eugene
 * @date 31.01.2025
**/
@IsTest
private class TaskTriggerHandlerTest {

    @IsTest
    private static void assignToQueueTest() {
        Case billingCase = [SELECT Id FROM Case WHERE RecordTypeId = :CaseConstants.CASE_BILLING_RT_ID LIMIT 1];
        Case intakeCase = [SELECT Id FROM Case WHERE RecordTypeId = :CaseConstants.CASE_INTAKE_RT_ID LIMIT 1];

        List<Task> tasksToInsert = new List<Task> {
                new Task(
                        WhatId = billingCase.Id,
                        Team__c = TaskConstants.TEAM_RCM,
                        SF_Source_Id__c = '1',
                        Queue_Override__c = TaskConstants.QUEUE_OVERRIDE_ELIGIBILITY,
                        Subject = 'SF2SF Sync'),
                new Task(
                        WhatId = billingCase.Id,
                        Team__c = TaskConstants.TEAM_RCM,
                        SF_Source_Id__c = '3',
                        Subject = 'SF2SF Sync'),
                new Task(
                        WhatId = intakeCase.Id,
                        Team__c = TaskConstants.TEAM_RCM,
                        Subject = 'SF2SF Not to Sync')
        };

        System.Test.startTest();

        Database.insert(tasksToInsert);

        System.Test.stopTest();

        Map<Id, Task> tasksToCheck = new Map<Id, Task>([
                SELECT OwnerId, Sync_Status__c
                FROM Task
                WHERE Id IN :tasksToInsert]);

        Assert.areEqual(GroupConstants.QUEUES_BY_NAMES.get(GroupConstants.QUEUE_ELIGIBILITY).Id,
            tasksToCheck.get(tasksToInsert.get(0).Id).OwnerId, 'As it is assigned to RCM team and Eligibility queue override.');

        Assert.isFalse(String.valueOf(tasksToCheck.get(tasksToInsert.get(1).Id).OwnerId).startsWith('00G'),
            'As we do not assign tasks if override is not specified.');

        Assert.isFalse(String.valueOf(tasksToCheck.get(tasksToInsert.get(2).Id).OwnerId).startsWith('00G'),
            'As we do not assign tasks that are not coming from SF1 to queues.');
        Assert.areEqual(TaskConstants.SYNC_STATUS_NEED_SYNC, tasksToCheck.get(tasksToInsert.get(2).Id).Sync_Status__c,
            'As it is Intake Case and Task is assigned to RCM team.');
    }

    @TestSetup
    private static void setupData() {
        List<Case> cases = new List<Case> {
                new Case(
                        RecordTypeId = CaseConstants.CASE_BILLING_RT_ID,
                        Type = 'Financial Rules',
                        Status = 'New',
                        Subject = 'SF2SF Sync'),
                new Case(
                        RecordTypeId = CaseConstants.CASE_INTAKE_RT_ID,
                        Type = 'Financial Rules',
                        Status = 'New',
                        Subject = 'SF2SF Not to Sync')
        };
        Database.insert(cases);
    }
}