/**
 * @description Mock response for EligibilityService.cls
**/
public class EligibilityMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(generateResponse());
        response.setStatusCode(200);
        return response;
    }

    public class AccessTokenMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            Map<String, Object> accessToken = new Map<String, Object> {
                    'access_token' => 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIs'
            };
            response.setBody(JSON.serialize(accessToken));
            response.setStatusCode(200);
            return response;
        }
    }

    public class ExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            throw new CalloutException();
        }
    }

    public static String generateResponse() {
        EligibilityService.PersonWrapper personData = new EligibilityService.PersonWrapper();
        personData.personID = '86b17f4d-28a0-42ca-e334-08dc531febdd';
        personData.personType = 'Baby';
        personData.firstName = 'Peter';
        personData.lastName = 'Parker';

        EligibilityService.Eligibility eligibility = new EligibilityService.Eligibility();
        eligibility.eligibilityID = '3a114e2b-1fa7-4bbd-e63c-08dc37fac706';
        eligibility.eligibilityStatusCode = 'RV-01';
        eligibility.status = 'Under Review';
        eligibility.internalDescription = 'Eligibility under review by insurance specialist';
        eligibility.dateChecked = Datetime.now();
        personData.eligibilities.add(eligibility);

        eligibility = new EligibilityService.Eligibility();
        eligibility.eligibilityID = 'd1fde1bf-b7a8-49d1-2d2f-08dc3f9c6632';
        eligibility.eligibilityStatusCode = 'PP-01';
        eligibility.status = 'In Process';
        eligibility.internalDescription = 'Pre-processing rules to run before calling out to external services';
        eligibility.dateChecked = Datetime.now();
        personData.eligibilities.add(eligibility);

        eligibility = new EligibilityService.Eligibility();
        eligibility.eligibilityID = '4c795390-34c0-4837-7444-08dc54bc0483';
        eligibility.eligibilityStatusCode = 'RE-01';
        eligibility.status = 'Received';
        eligibility.internalDescription = 'Eligibility claim received and pending initial review';
        eligibility.dateChecked = Datetime.now();
        personData.eligibilities.add(eligibility);

        return JSON.serialize(personData);
    }
}