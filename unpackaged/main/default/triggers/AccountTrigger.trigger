/** 
 * @Author: gleb.demidchik@mavenmule.com 
 * @Date: 2025-01-15 
 * @Desc: Trigger for Account object
*/
trigger AccountTrigger on Account (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        AccountTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.new);
    }
}