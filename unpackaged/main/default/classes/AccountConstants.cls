/**
 * @description Constants for Account object.
 * @author Eugene
 * @date 31.03.2025
**/
public class AccountConstants {

    public static final String ELIGIBILITY_STATUS_ELIGIBLE = 'Eligible';
    public static final String ELIGIBILITY_STATUS_INELIGIBLE = 'Ineligible';

    public static final String REASON_FOR_INACTIVE_INSURANCE_WENT_INACTIVE = 'Insurance went inactive';

    public static final String PATIENT_RT_ID {
        get {
            if(PATIENT_RT_ID == NULL) {
                PATIENT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
            }
            return PATIENT_RT_ID;
        }
        private set;
    }
}