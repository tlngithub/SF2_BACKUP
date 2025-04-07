/**
 * @description Test class for Account: Update Inactive Fields flow
 * @author Eugene
 * @date 31.03.2025
**/
@IsTest
private class AccountUpdateInactiveFieldsTest {

    @IsTest
    private static void eligibilityStatusChangeTest() {
        if(FeatureFlag.isActive('TLN_30673_CAPTUREREASONFORINACTIVE')) {
            Account patient = [
                    SELECT Eligibility_Status__pc, Reason_For_Inactive__c
                    FROM Account LIMIT 1];

            System.Test.startTest();

            patient.Eligibility_Status__pc = AccountConstants.ELIGIBILITY_STATUS_INELIGIBLE;
            patient.Reason_For_Inactive__c = AccountConstants.REASON_FOR_INACTIVE_INSURANCE_WENT_INACTIVE;
            Database.update(patient);

            patient = [
                    SELECT Eligibility_Status__pc, Reason_For_Inactive__c, Date_Inactive__c
                    FROM Account LIMIT 1];

            Assert.areEqual(Date.today(), patient.Date_Inactive__c, 'As we did not specify the date.');

            patient.Eligibility_Status__pc = AccountConstants.ELIGIBILITY_STATUS_ELIGIBLE;
            Database.update(patient);

            patient = [
                    SELECT Eligibility_Status__pc, Reason_For_Inactive__c, Date_Inactive__c
                    FROM Account LIMIT 1];

            System.Test.stopTest();

            Assert.isNull(patient.Date_Inactive__c, 'As we changed status back to eligible');
            Assert.isTrue(String.isBlank(patient.Reason_For_Inactive__c), 'As we changed status back to eligible');
        }
    }

    @TestSetup
    private static void setupData() {
        Account patient = new Account(
                RecordTypeId = AccountConstants.PATIENT_RT_ID,
                FirstName = 'Peter',
                LastName = 'Parker');
        Database.insert(patient);
    }
}