/** 
 * @Author: gleb.demidchik@mavenmule.com 
 * @Date: 2025-02-04 
 * @Desc: Controller class for LWC EslLeadBackgroundCheck
*/
public with sharing class ESLBackgroundCheckController {
    public static String SUCCESS_RESPONSE = 'Request Accepted';
    public static String ERROR_RESPONSE = 'Callout Failed. Status Code: ';
    
    @AuraEnabled
    public static String sendBackgroundCheck(String recordId) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:LP_Microservices/api/backgroundcheck');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(20000);
            req.setBody('{"salesforce2Id": "' + recordId +'"}');

            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                return SUCCESS_RESPONSE;
            } else {
                throw new AuraHandledException(ERROR_RESPONSE + res.getStatusCode());
            }
        } catch (Exception e) {
            e = e.getTypeName() != 'System.AuraHandledException' ? new AuraHandledException(e.getMessage()) : e;
            throw e;
        }
    }
            
    @AuraEnabled
    public static Boolean isFeatureFlagEnabled() {
        return FeatureFlag.isActive('TLN_26048_CHECKRINTEGRATION');
    }
}