/**
 * Created by maximelets on 10/07/2024.
 */

public with sharing class AverageSurveyScoreBatch implements Database.Batchable<SObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id, Patient__c, LC__c, LCP__c, NPS_Score__c FROM Patient_Visit_Survey__c WHERE CreatedDate = LAST_N_DAYS:5]);
    }

    public void execute(Database.BatchableContext context, List<Patient_Visit_Survey__c> scope) {
        Set<Id> relatedRecordsIds = new Set<Id>();
        for (Patient_Visit_Survey__c pvs : scope) {
            if (String.isNotBlank(pvs.LC__c)) {
                relatedRecordsIds.add(pvs.LC__c);
            }
            if (String.isNotBlank(pvs.LCP__c)) {
                relatedRecordsIds.add(pvs.LCP__c);
            }
        }

        Map<Id, AverageNPS> recordAverageNPS = new Map<Id, AverageSurveyScoreBatch.AverageNPS>();
        for (Patient_Visit_Survey__c pvs : [
            SELECT Id, Patient__c, LC__c, LCP__c, NPS_Score__c
            FROM Patient_Visit_Survey__c
            WHERE LC__c IN :relatedRecordsIds OR LCP__c IN :relatedRecordsIds
        ]) {
            AverageNPS forLC = this.getByRecordId(pvs.LC__c, recordAverageNPS);
            forLC.add(pvs);
            recordAverageNPS.put(pvs.LC__c, forLC);

            AverageNPS forLCP = this.getByRecordId(pvs.LCP__c, recordAverageNPS);
            forLCP.add(pvs);
            recordAverageNPS.put(pvs.LCP__c, forLCP);
        }

        Map<Id, SObject> recordsToUpdate = new Map<Id, SObject>();
        for (Id recordId : recordAverageNPS.keySet()) {
            AverageNPS average = recordAverageNPS.get(recordId);
            SObject record = recordsToUpdate.get(recordId);
            if (record == null) {
                record = recordId.getSobjectType().newSObject(recordId);
            }
            record.put('Average_NPS_Score__c', average.getAverageNPS());
            recordsToUpdate.put(recordId, record);
        }

        Database.update(recordsToUpdate.values());
    }

    public void finish(Database.BatchableContext context) {
    }

    public void execute(SchedulableContext context) {
        Database.executeBatch(new AverageSurveyScoreBatch());
    }

    public static void schedule() {
        System.schedule('Average NPS Score Batch', '0 0 00 * * ? *', new AverageSurveyScoreBatch());
    }

    public AverageNPS getByRecordId(Id recordId, Map<Id, AverageNPS> averageNPSMap) {
        AverageNPS average = averageNPSMap.get(recordId);
        if (average == null) {
            average = new AverageNPS();
        }
        return average;
    }
    public class AverageNPS {
        //9-10
        public List<Patient_Visit_Survey__c> promoters { get; set; }
        //6 and below
        public List<Patient_Visit_Survey__c> detractors { get; set; }
        //7-8
        public List<Patient_Visit_Survey__c> passives { get; set; }

        public AverageNPS() {
            this.promoters = new List<Patient_Visit_Survey__c>();
            this.detractors = new List<Patient_Visit_Survey__c>();
            this.passives = new List<Patient_Visit_Survey__c>();
        }

        public void add(Patient_Visit_Survey__c pvs) {
            if (pvs.NPS_Score__c >= 9) {
                this.promoters.add(pvs);
            } else if (pvs.NPS_Score__c > 6) {
                this.passives.add(pvs);
            } else {
                this.detractors.add(pvs);
            }
        }

        public Decimal getAverageNPS() {
            Decimal total = this.promoters.size() + this.detractors.size() + this.passives.size();
            Decimal promotersPercentage = this.promoters.size() / total * 100;
            Decimal detractorsPercentage = this.detractors.size() / total * 100;
            return (promotersPercentage - detractorsPercentage).setScale(2);
        }
    }
}