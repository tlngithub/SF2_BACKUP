public with sharing class SubmissionDataController {

    @AuraEnabled(Cacheable=false)
    public static ExternalData fetchData(Id recordId) {
        ExternalData output = new ExternalData();
        try {
            String externalId = getExternalIdFromRecordId(recordId);
            if(String.isNotBlank(externalId)) {
                output.submissions = SubmissionService.getSubmissions(externalId);

                EligibilityService.PersonWrapper person;
                if( ! System.Test.isRunningTest()) {
                    person = EligibilityService.getEligibility(externalId);
                } else {
                    person = (EligibilityService.PersonWrapper)JSON.deserialize(EligibilityMock.generateResponse(), EligibilityService.PersonWrapper.class);
                }

                Set<String> eligibilityIds = new Set<String>();
                for(SubmissionService.Submission submission : output.submissions) {
                    if(String.isNotBlank(submission.eligibilityId)) {
                        eligibilityIds.add(submission.eligibilityId);
                    }
                    submission.intakeViewerUrl = GlobalConstants.GLOBAL_SETTINGS?.Intake_Viewer_Url__c + submission.Id;
                    submission.initEmptyProperties();
                    submission.populateClinicalPractice();
                    submission.eligibilities = new List<EligibilityService.Eligibility>();
                }

                for(SubmissionService.Submission submission : output.submissions) {
                    if(person?.eligibilities != NULL) {
                        for(EligibilityService.Eligibility eligibility : person.eligibilities) {
                            if(String.isNotBlank(eligibility.eligibilityID) && eligibilityIds.contains(eligibility.eligibilityID)) {
                                if(submission.eligibilityId == eligibility.eligibilityID) {
                                    submission.eligibilities.add(eligibility);
                                }
                            } else {
                                submission.eligibilities.add(eligibility);
                            }
                        }
                    }
                    submission.checkEligibility();
                }
            }
        } catch (Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return output;
    }

    private static String getExternalIdFromRecordId(Id recordId) {
        String externalId;
        if(recordId.getSobjectType() == Schema.Account.SObjectType) {
            externalId = [SELECT External_ID__pc FROM Account WHERE Id = :recordId LIMIT 1].External_ID__pc;
        }
        if(recordId.getSobjectType() == Schema.Contact.SObjectType) {
            externalId = [SELECT External_ID__c FROM Contact WHERE Id = :recordId LIMIT 1].External_ID__c;
        }
        if(recordId.getSobjectType() == Schema.Lead.SObjectType) {
            externalId = [SELECT External_ID__c FROM Lead WHERE Id = :recordId LIMIT 1].External_ID__c;
        }
        return externalId;
    }

    public class ExternalData {
        @AuraEnabled
        public Boolean isVisible = UserUtils.userIsInPublicGroupByName(UserInfo.getUserId(), 'Submission_and_Eligibility_Viewers');
        @AuraEnabled
        public List<SubmissionService.Submission> submissions { get; set; }

        public ExternalData() {
            this.submissions = new List<SubmissionService.Submission>();
        }
    }
}