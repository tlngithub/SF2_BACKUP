/**
 * Manages REST callouts to the TLN Submission microservice.
 * @ticket User Story 18169: SF2 Call out to Submission service to get records associated to leads/patients
 */
public class SubmissionService {

    private static Credential__mdt credential;
    public static String accessToken;

    /**
     * Get Submissions for the specified Patient.
     * @param patientId Patient Submission Id.
     * @return List<Submission> Submissions.
     */
    @AuraEnabled
    public static List<Submission> getSubmissions(String patientId) {
        List<Submission> submissions = new List<Submission>();
        HttpRequest httpRequest = new HttpRequest();
 
        httpRequest.setEndpoint(getCredentials().Service_Endpoint__c + '?' + 'PersonId=' + EncodingUtil.urlEncode(patientId, 'UTF-8'));
        httpRequest.setMethod('GET');
        httpRequest.setHeader('Authorization', 'Bearer ' + getAccessToken());
        httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpRequest.setTimeout(120000);

        try {
            Http http = new Http();
            HttpResponse response = http.send(httpRequest);
            System.debug('getSubmissions response = ' + response.getBody());
            // parse the access token from the response body
            submissions = (List<Submission>)JSON.deserialize(response.getBody(), List<Submission>.class);
        } catch(Exception e) {
            System.debug('getSubmissions exception = ' + e);
            throw e;
        }
        return submissions;
    }

    /**
     * Get the Access Token.
     * @return String Access Token.
     */
    public static String getAccessToken() {
        if (accessToken == null) {
            HttpRequest httpRequest = new HttpRequest();

            httpRequest.setEndpoint(getCredentials().Token_Endpoint__c);
            httpRequest.setMethod('POST');
            httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            httpRequest.setBody(
                'client_id=' + EncodingUtil.urlEncode(getCredentials().Client_ID__c, 'UTF-8') +
                '&client_secret=' + EncodingUtil.urlEncode(getCredentials().Client_Secret__c, 'UTF-8') +
                '&scope=' + EncodingUtil.urlEncode(getCredentials().Scope__c, 'UTF-8') +
                '&grant_type=' + EncodingUtil.urlEncode(getCredentials().Grant_Type__c, 'UTF-8')
            );
            httpRequest.setTimeout(120000);
            
            try {
                Http http = new Http();
                HttpResponse response = http.send(httpRequest);
                System.debug('getAccessToken response = ' + response.getBody());
                // parse the access token from the response body
                accessToken = String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('access_token'));
            } catch(Exception e) {
                System.debug('getAccessToken exception = ' + e);
                throw e;
            }
        }
        return accessToken;
    }

    /**
     * Get the Credentials.
     * @return Credential metadata type.
     */
    public static Credential__mdt getCredentials() {
        if (credential == null) {
            credential = Credential__mdt.getInstance('Submission');
        }
        return credential;
    }

    public class Submission {
        @AuraEnabled
        public Boolean hasInsurance { get; set; }
        @AuraEnabled
        public Boolean hasEligibility { get; set; }
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String eligibilityId { get; set; }
        @AuraEnabled
        public String submissionOperationStatus { get; set; }
        @AuraEnabled
        public String vanityIdentifier { get; set; }
        @AuraEnabled
        public String relationshipToSubscriber { get; set; }
        @AuraEnabled
        public String veteransAffairsAuthorizationReferralNumber { get; set; }
        @AuraEnabled
        public String referralNumber { get; set; }
        @AuraEnabled
        public String intakeViewerUrl;
        @AuraEnabled
        public String clinicalPractice;
        @AuraEnabled
        public Datetime dateCreated { get; set; }
        @AuraEnabled
        public Employer employer { get; set; }
        @AuraEnabled
        public List<Doctor> doctors { get; set; }
        @AuraEnabled
        public List<Baby> babies { get; set; }
        @AuraEnabled
        public List<Insurance> insurances { get; set; }
        @AuraEnabled
        public List<EligibilityService.Eligibility> eligibilities { get; set; }

        public void initEmptyProperties() {
            this.hasInsurance = this.insurances != NULL && ! this.insurances.isEmpty();
            if(this.employer == NULL) {
                this.employer = new Employer();
            }
            if(this.babies != NULL) {
                for(Baby record : this.babies) {
                    record.checkInsurance();
                }
            }
        }

        public void populateClinicalPractice() {
            if(this.doctors != NULL && ! this.doctors.isEmpty()) {
                Set<String> associatedHospitals = new Set<String>();
                for(Doctor record : this.doctors) {
                    if(String.isNotBlank(record.associatedHospital)) {
                        associatedHospitals.add(record.associatedHospital);
                    }
                }
                this.clinicalPractice = String.join(associatedHospitals, ', ');
            }
        }

        public void checkEligibility() {
            this.hasEligibility = this.eligibilities != NULL && ! this.eligibilities.isEmpty();
        }
    }

    public class Insurance {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String insurerName { get; set; }
        @AuraEnabled
        public String companyName { get; set; }
        @AuraEnabled
        public String groupNumber { get; set; }
        @AuraEnabled
        public String insuranceType { get; set; }
        @AuraEnabled
        public String relationshipToPolicyHolder { get; set; }
    }

    public class Employer {
        @AuraEnabled
        public String employerId { get; set; }
        @AuraEnabled
        public String employerName { get; set; }
        @AuraEnabled
        public String employerCode { get; set; }
    }

    public class Baby {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public Boolean hasInsurance { get; set; }
        @AuraEnabled
        public String firstName { get; set; }
        @AuraEnabled
        public String lastName { get; set; }
        @AuraEnabled
        public Boolean isOnParentsPrimaryInsurance { get; set; }
        @AuraEnabled
        public List<Insurance> insurances { get; set; }

        public void checkInsurance() {
            this.hasInsurance = this.insurances != NULL && ! this.insurances.isEmpty();
        }
    }
    
    public class Doctor {
        @AuraEnabled
        public String associatedHospital { get; set; }
    }
}