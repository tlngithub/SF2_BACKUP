@isTest
public class ScheduleDailyDeliveredPlatformEventsTest {

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            String responseBody = '{"DailyDeliveredPlatformEvents": {"Max": 525000, "Remaining": 5000}}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(responseBody);
            response.setStatusCode(200);
            
            return response;
        }
    }

    @isTest
    static void execute() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ScheduleDailyDeliveredPlatformEvents scheduledJob = new ScheduleDailyDeliveredPlatformEvents();
        Test.startTest();
        scheduledJob.execute(null);
        Test.stopTest();
    }
    
    @isTest
    static void testSchedule() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String cronExpression = '0 0 * * * ?';
        ScheduleDailyDeliveredPlatformEvents scheduledJob = new ScheduleDailyDeliveredPlatformEvents();
        System.schedule('Test Daily Delivered Platform Events', cronExpression, scheduledJob);
    }
    
    @isTest
    static void testEmail() {
        ScheduleDailyDeliveredPlatformEvents sch = new ScheduleDailyDeliveredPlatformEvents();
        sch.notifyStakeholdersViaEmail(1,1);
        Integer emailInvocations = Limits.getEmailInvocations();
        System.assertEquals(1, emailInvocations, 'Expected one email to be sent');
    }
}