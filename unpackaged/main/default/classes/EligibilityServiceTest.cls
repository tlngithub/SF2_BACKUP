/**
 * @description Unit tests for the EligibilityService.cls
**/
@IsTest
private class EligibilityServiceTest {

    @IsTest
    private static void getEligibilityTest() {
        EligibilityService.accessToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIs';
        EligibilityMock mock = new EligibilityMock();
        System.Test.setMock(HttpCalloutMock.class, mock);

        System.Test.startTest();

        EligibilityService.PersonWrapper personData = EligibilityService.getEligibility('86b17f4d-28a0-42ca-e334-08dc531febdd');

        System.Test.stopTest();

        Assert.areEqual(personData.eligibilities.size(), 3, 'As we mocked that in response.');
    }

    @IsTest
    private static void getEligibilityExceptionTest() {
        EligibilityService.accessToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIs';
        EligibilityMock.ExceptionMock mock = new EligibilityMock.ExceptionMock();
        System.Test.setMock(HttpCalloutMock.class, mock);

        Boolean exceptionThrown = false;
        System.Test.startTest();
        try {
            EligibilityService.PersonWrapper personData = EligibilityService.getEligibility('Test');
        } catch (Exception exc) {
            exceptionThrown = true;
        }
        System.Test.stopTest();

        Assert.isTrue(exceptionThrown, 'As we mocked exception.');
    }

    @IsTest
    private static void getAccessTokenTest() {
        EligibilityMock.AccessTokenMock mock = new EligibilityMock.AccessTokenMock();
        System.Test.setMock(HttpCalloutMock.class, mock);

        System.Test.startTest();

        String accessToken = EligibilityService.getAccessToken();

        System.Test.stopTest();

        Assert.areEqual('eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIs', accessToken, 'Access token mocked in response.');
    }

    @IsTest
    private static void getAccessTokenExceptionTest() {
        EligibilityMock.ExceptionMock mock = new EligibilityMock.ExceptionMock();
        System.Test.setMock(HttpCalloutMock.class, mock);

        Boolean exceptionThrown = false;
        System.Test.startTest();
        try {
            String accessToken = EligibilityService.getAccessToken();
        } catch (Exception exc) {
            exceptionThrown = true;
        }
        System.Test.stopTest();

        Assert.isTrue(exceptionThrown, 'As we mocked exception.');
    }
}