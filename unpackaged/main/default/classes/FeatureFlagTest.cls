@IsTest
public class FeatureFlagTest {
    static String flagName = 'pleaseNeverNameAFlagLikeThisTestFlag';
    @IsTest
    static void testFetchingFeatureFlagEnabled() {
        FeatureFlag.featureFlagCache = new Map<String, Boolean>{
            flagName => true
        };
        Test.startTest();
        Boolean result = FeatureFlag.isActive(flagName);
        Test.stopTest();
        System.Assert.areEqual(true, result);
    }

    @IsTest
    static void testFetchingFeatureFlagDisabled() {
        FeatureFlag.featureFlagCache = new Map<String, Boolean>{
            flagName => false
        };
        Test.startTest();
        Boolean result = FeatureFlag.isActive(flagName);
        Test.stopTest();
        System.Assert.areEqual(false, result);
    }

    @IsTest
    static void testFetchingFeatureFlagMissing() {
        Test.startTest();
        Boolean result = FeatureFlag.isActive(flagName);
        Test.stopTest();
        System.Assert.areEqual(false, result);
    }

    @IsTest
    static void testFetchingFlowFeatureFlagEnabled() {
        FeatureFlag.featureFlagCache = new Map<String, Boolean>{
            flagName => true
        };
        List<FeatureFlag.FlowInput> flowInputs = new List<FeatureFlag.FlowInput>();
        FeatureFlag.FlowInput fi = new FeatureFlag.FlowInput();
        fi.featureName = flagName;
        flowInputs.add(fi);
        Test.startTest();
        List<FeatureFlag.FlowOutput> result = FeatureFlag.isActive(flowInputs);
        Test.stopTest();
        System.Assert.areEqual(true, result[0].isActive);
    }
}