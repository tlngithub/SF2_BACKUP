/**
 * @description Constants for Case object.
 * @author Eugene
 * @date 14.01.2025
**/
public class CaseConstants {

    public static final String STATUS_INSURANCE_FINALIZED = 'Insurance Finalized';
    public static final String STATUS_RESOLVED = 'Resolved';
    public static final String STATUS_WAITING_ON_EXTERNAL_RESPONSE = 'Waiting on External Response';

    public static final Set<String> STOPPED_STATUSES = new Set<String> {
            STATUS_INSURANCE_FINALIZED, STATUS_RESOLVED, STATUS_WAITING_ON_EXTERNAL_RESPONSE
    };

    public static final String CASE_BILLING_RT_ID {
        get {
            if(CASE_BILLING_RT_ID == NULL) {
                CASE_BILLING_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
            }
            return CASE_BILLING_RT_ID;
        }
        private set;
    }

    public static final String CASE_ELIGIBILITY_RT_ID {
        get {
            if(CASE_ELIGIBILITY_RT_ID == NULL) {
                CASE_ELIGIBILITY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Eligibility').getRecordTypeId();
            }
            return CASE_ELIGIBILITY_RT_ID;
        }
        private set;
    }

    public static final String CASE_INTAKE_RT_ID {
        get {
            if(CASE_INTAKE_RT_ID == NULL) {
                CASE_INTAKE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Intake').getRecordTypeId();
            }
            return CASE_INTAKE_RT_ID;
        }
        private set;
    }

    public static final String CASE_SUBMISSIONS_RT_ID {
        get {
            if(CASE_SUBMISSIONS_RT_ID == null) {
                CASE_SUBMISSIONS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Submissions').getRecordTypeId();
            }
            return CASE_SUBMISSIONS_RT_ID;
        }
        private set;
    }

    public static final String CASE_SUPPORT_ISSUE_RT_ID {
        get {
            if(CASE_SUPPORT_ISSUE_RT_ID == NULL) {
                CASE_SUPPORT_ISSUE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_Issue').getRecordTypeId();
            }
            return CASE_SUPPORT_ISSUE_RT_ID;
        }
        private set;
    }

    public static final String CASE_USER_SUPPORT_RT_ID {
        get {
            if(CASE_USER_SUPPORT_RT_ID == NULL) {
                CASE_USER_SUPPORT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('User_Support').getRecordTypeId();
            }
            return CASE_USER_SUPPORT_RT_ID;
        }
        private set;
    }
}