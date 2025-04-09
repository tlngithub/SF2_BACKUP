public with sharing class FeatureFlag {
    @TestVisible
    static Map<String, Boolean> featureFlagCache = null;

    public FeatureFlag() {}

    public static Boolean isActive(String featureName) {
        if (featureFlagCache == null) {
            List<Feature_Flag__mdt> cmtsFeatureFlag = [
                SELECT DeveloperName, Enabled__c
                FROM Feature_Flag__mdt LIMIT 10000];
            featureFlagCache = new Map<String, Boolean>();
            for (Feature_Flag__mdt ffcmt : cmtsFeatureFlag) {
                featureFlagCache.put(ffcmt.DeveloperName, ffcmt.Enabled__c);
            }
        }

        if (featureFlagCache.containsKey(featureName)) {
            return featureFlagCache.get(featureName);
        }
        return false;
    }

    public class FlowInput {
        @InvocableVariable public String featureName;
    }

    public class FlowOutput {
        @InvocableVariable public Boolean isActive;
        public FlowOutput(Boolean isActive) {
            this.isActive = isActive;
        }
    }

    @InvocableMethod(Label='Feature Flag Is Active')
    public static FlowOutput[] isActive(List<FlowInput> flowInputs) {
        FlowOutput[] results = new List<FlowOutput>();
        for (FlowInput fi: flowInputs) {
            results.add(new FlowOutput(
                FeatureFlag.isActive(fi.featureName)
            ));
        }
        return results;
    }
}