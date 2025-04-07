/**
 * @description Mock response for SubmissionService.cls
**/
public class SubmissionMock implements HttpCalloutMock {
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
        SubmissionService.Submission submission = new SubmissionService.Submission();
        submission.id = '4053abfb-54b4-4361-b9ff-900b346956b6';
        submission.eligibilityId = '3a114e2b-1fa7-4bbd-e63c-08dc37fac706';
        submission.submissionOperationStatus = 'InProcess';
        submission.vanityIdentifier = '';
        submission.relationshipToSubscriber = 'Self';
        submission.veteransAffairsAuthorizationReferralNumber = 'VA032624';
        submission.dateCreated = Date.today().addDays(-30);

        submission.employer = new SubmissionService.Employer();
        submission.employer.employerId = 'employerId';
        submission.employer.employerName = 'Moen LLC';
        submission.employer.employerCode = 'employerCode';

        SubmissionService.Insurance insurance = new SubmissionService.Insurance();
        insurance.id = '4f65e2c3-d81a-4ef3-a32c-deb45eebb62e';
        insurance.companyName = 'Humana MMAI';
        insurance.groupNumber = '20757941';
        insurance.insuranceType = 'Primary';
        submission.insurances = new List<SubmissionService.Insurance> { insurance };

        SubmissionService.Baby baby = new SubmissionService.Baby();
        baby.insurances = new List<SubmissionService.Insurance> { insurance };
        baby.isOnParentsPrimaryInsurance = false;
        baby.firstName = 'Peter';
        baby.lastName = 'Parker';
        submission.babies = new List<SubmissionService.Baby> { baby };

        SubmissionService.Doctor doctor = new SubmissionService.Doctor();
        doctor.associatedHospital = 'Hospital';
        submission.doctors = new List<SubmissionService.Doctor> { doctor };

        return JSON.serialize(new List<SubmissionService.Submission>{submission});
    }
}