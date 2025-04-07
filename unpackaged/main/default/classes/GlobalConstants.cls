/**
 * @description Store global constants to be re-used across application.
 **/
public with sharing class GlobalConstants {

    public static final General_Settings__c GLOBAL_SETTINGS {
        get {
            if (GLOBAL_SETTINGS == null) {
                GLOBAL_SETTINGS = General_Settings__c.getOrgDefaults();
            }
            return GLOBAL_SETTINGS;
        }
        private set;
    }

    public static Boolean areTriggersEnabled() {
        return !GLOBAL_SETTINGS?.Triggers_Disabled__c;
    }

    public static final String LC_STATUS_PENDING_DEACTIVATION = 'Pending Deactivation';
    public static final String LC_STATUS_DEACTIVATED = 'Deactivated';
    public static final String LC_STATUS_PENDING_DISABLEMENT = 'Pending Disablement';
    public static final String LC_STATUS_DISABLED = 'Disabled';
}