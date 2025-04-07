/** 
 * @Author: gleb.demidchik@mavenmule.com 
 * @Date: 2025-02-04 
 * @Desc: ESLBackgroundCheckController test class
*/
@IsTest
public with sharing class ESLBackgroundCheckControllerTest {    
	@IsTest
    private static void successCallout() {
        Test.setMock(
            HttpCalloutMock.class,
            new MicroservicesHttpCalloutMock(true));

        Test.startTest();
        String calloutResponse = ESLBackgroundCheckController.sendBackgroundCheck('00QNq00000DrAAAAAA');
        Test.stopTest();

        Assert.areEqual(ESLBackgroundCheckController.SUCCESS_RESPONSE, calloutResponse, 'If no error occurs must return success response message');
    }
        
	@IsTest
    private static void failedCallout() {
        Test.setMock(
            HttpCalloutMock.class,
            new MicroservicesHttpCalloutMock(false));
        String calloutResponse;

        Test.startTest();
        try {
            ESLBackgroundCheckController.sendBackgroundCheck('00QNq00000DrAAAAAA');
        } catch(Exception e) {
            calloutResponse = e.getMessage();
        }
        Test.stopTest();

        Assert.isNotNull(calloutResponse, 'If error occurs error must be thrown');
    }

    public class MicroservicesHttpCalloutMock implements HttpCalloutMock {
        private Boolean IS_SUCCESS_RESPONSE = true;

        public MicroservicesHttpCalloutMock(Boolean isSuccess) {
            IS_SUCCESS_RESPONSE = isSuccess;
        }

        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();            
            response.setHeader('Content-Type', 'application/json');

            if (IS_SUCCESS_RESPONSE) {
                response.setStatusCode(200);
            } else {
                response.setStatusCode(500);
                response.setBody('{"error": "Server exception"}');
            }
            
            return response;
        }
    }
    
    @IsTest
    private static void getFeatureFlagTest() {
        Test.startTest();
        Boolean isFeatureFlagEnabled = ESLBackgroundCheckController.isFeatureFlagEnabled();
        Test.stopTest();

        Assert.isNotNull(isFeatureFlagEnabled, 'Must return current feature flag state');
    }
}