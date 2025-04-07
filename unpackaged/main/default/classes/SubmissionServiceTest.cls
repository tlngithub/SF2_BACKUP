/**
 * @description Unit tests for the SubmissionService.cls
**/
@IsTest
private class SubmissionServiceTest {

    @IsTest
    private static void getSubmissionsTest() {
        SubmissionService.accessToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIs';

        SubmissionMock mock = new SubmissionMock();
        System.Test.setMock(HttpCalloutMock.class, mock);

        System.Test.startTest();

        List<SubmissionService.Submission> submissions = SubmissionService.getSubmissions('Test');
        submissions.get(0).populateClinicalPractice();

        System.Test.stopTest();

        System.assertEquals(1, submissions.size(), 'Wrong number of submissions.');
        System.assertEquals('Self', submissions.get(0).relationshipToSubscriber, 'Wrong insurance relationship.');
        Assert.areEqual('Hospital', submissions.get(0).clinicalPractice, 'Populated based on doctors data.');
    }

    @IsTest
    private static void getSubmissionsExceptionTest() {
        SubmissionService.accessToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIs';

        SubmissionMock.ExceptionMock mock = new SubmissionMock.ExceptionMock();
        System.Test.setMock(HttpCalloutMock.class, mock);

        Boolean exceptionThrown = false;
        System.Test.startTest();

        try {
            List<SubmissionService.Submission> submissions = SubmissionService.getSubmissions('Test');
        } catch (Exception exc) {
            exceptionThrown = true;
        }

        System.Test.stopTest();

        System.assert(exceptionThrown, 'Exception was not thrown.');
    }

    @IsTest
    private static void getAccessTokenTest() {
        SubmissionMock.AccessTokenMock mock = new SubmissionMock.AccessTokenMock();
        System.Test.setMock(HttpCalloutMock.class, mock);

        System.Test.startTest();

        String accessToken = SubmissionService.getAccessToken();

        System.Test.stopTest();

        System.assertEquals('eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIs', accessToken, 'Wrong access token.');
    }

    @IsTest
    private static void getAccessTokenExceptionTest() {
        SubmissionMock.ExceptionMock mock = new SubmissionMock.ExceptionMock();
        System.Test.setMock(HttpCalloutMock.class, mock);

        Boolean exceptionThrown = false;
        System.Test.startTest();

        try {
            String accessToken = SubmissionService.getAccessToken();
        } catch (Exception e) {
            exceptionThrown = true;
        }

        System.Test.stopTest();

        System.assert(exceptionThrown, 'Exception was not thrown.');
    }
}