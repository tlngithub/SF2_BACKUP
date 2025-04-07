/**
 * @description Manages REST callouts to the TLN Eligibility microservice.
 * @ticket User Story 18187: SF2 Call out to Eligibility service to get records associated to leads/patients and submission records
**/
public class EligibilityService {

    private static Credential__mdt credential;
    public static String accessToken;

    /**
     * @description Get Eligibility with the specified Id.
     * @param personId Person guid.
     * @return Eligibility.
    **/
    public static PersonWrapper getEligibility(String personId) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(getCredentials().Service_Endpoint__c + '/' + EncodingUtil.urlEncode(personId, 'UTF-8'));
        httpRequest.setMethod('GET');
        httpRequest.setHeader('Authorization', 'Bearer ' + getAccessToken());
        httpRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpRequest.setTimeout(120000);

        PersonWrapper personData = new PersonWrapper();
        try {
            Http http = new Http();
            HttpResponse response = http.send(httpRequest);
            System.debug('getEligibility response = ' + response.getBody());
            // Parse response
            personData = (PersonWrapper)JSON.deserialize(response.getBody(), PersonWrapper.class);
        } catch(Exception exc) {
            System.debug('getEligibility exception = ' + exc);
            throw exc;
        }
        return personData;
    }

    /**
     * @description Get the Access Token.
     * @return String Access Token.
    **/
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
            
            try {
                Http http = new Http();
                HttpResponse response = http.send(httpRequest);
                System.debug('getAccessToken response = ' + response.getBody());
                // parse the access token from the response body
                accessToken = String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(response.getBody())).get('access_token'));
            } catch(Exception exc) {
                System.debug('getAccessToken exception = ' + exc);
                throw exc;
            }
        }
        return accessToken;
    }

    /**
     * @description Get the Credentials.
     * @return Credential metadata type.
    **/
    public static Credential__mdt getCredentials() {
        if (credential == null) {
            credential = Credential__mdt.getInstance('Eligibility');
        }
        return credential;
    }

    public class PersonWrapper {
        @AuraEnabled
        public String personID { get; set; }
        @AuraEnabled
        public String firstName { get; set; }
        @AuraEnabled
        public String lastName { get; set; }
        @AuraEnabled
        public String personType { get; set; }
        @AuraEnabled
        public List<Eligibility> eligibilities { get; set; }

        public PersonWrapper() {
            this.eligibilities = new List<Eligibility>();
        }
    }

    public class Eligibility {
        @AuraEnabled
        public String eligibilityID { get; set; }
        @AuraEnabled
        public String eligibilityStatusCode { get; set; }
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public String internalDescription { get; set; }
        @AuraEnabled
        public Datetime dateChecked { get; set; }
    }
}