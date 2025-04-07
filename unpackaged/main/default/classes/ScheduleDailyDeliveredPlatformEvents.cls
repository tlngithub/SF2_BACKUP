public with sharing class ScheduleDailyDeliveredPlatformEvents implements Schedulable{
    private String LIMITS_API_URL = '/services/data/v63.0/limits';
    private String ORG_BASE_URL = URL.getOrgDomainURL().toExternalForm();
    private String FINAL_ENDPOINT = ORG_BASE_URL + LIMITS_API_URL;
    public Boolean enforceNotifyStakeholders = false;

    public void execute(SchedulableContext context) {
        if(FeatureFlag.isActive('TLN_30583_CDCEVENTSSCHEDULABLE') || Test.isRunningTest()){
            try {
                HttpResponse response = makeEventLimitsApiCallout();
    
                if (response != null && response.getStatusCode() == 200) {
                    String responseBody = response.getBody();
                    // Retrieve the 'DailyDeliveredPlatformEvents'
                    Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    Map<String, Object> dailyDeliveredPlatformEvents = (Map<String, Object>) resultMap.get('DailyDeliveredPlatformEvents');
                    Integer remainingEvents = (Integer) dailyDeliveredPlatformEvents.get('Remaining');
                    Integer maxEvents = (Integer) dailyDeliveredPlatformEvents.get('Max');
                    System.debug('Remaining Daily Delivered Platform Events: ' + remainingEvents);
    
                    //if we reach treshold of 80% (therefore 0.8), we should notify users
                    Decimal result = ((Decimal)maxEvents-(Decimal)remainingEvents)/(Decimal)maxEvents;
                    if(result >= 0.8 || Test.isRunningTest() || enforceNotifyStakeholders){
                        notifyStakeholdersViaEmail(remainingEvents, maxEvents);
                    }
                } else {
                    System.debug('Failed to retrieve limits. Status code: ' + response.getStatusCode());
                }
            } catch (Exception ex) {
                System.debug('Error while retrieving limits: ' + ex.getMessage());
            }
        }
    }

    public HttpResponse makeEventLimitsApiCallout() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(FINAL_ENDPOINT);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        return response;
    }

    public void notifyStakeholdersViaEmail(Integer remaining, Integer max){
        Daily_Delivered_Platform_Event__mdt customMeta = Daily_Delivered_Platform_Event__mdt.getInstance('Default');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {customMeta.Notification_Email__c});
        mail.setSubject('Reached 80% treshold of DailyDeliveredPlatformEvents limits!');
        mail.setPlainTextBody('Reached 80% treshold of DailyDeliveredPlatformEvents limits!\n\nMax limits: ' + max + '\nRemaining limits: ' + remaining + '\n\nEmail sent via ScheduleDailyDeliveredPlatformEvents class from ' + ORG_BASE_URL + '.');

        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}