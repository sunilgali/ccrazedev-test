global class SSUpgradeConfirmationController {
    
    @AuraEnabled
    global static Map<String , Object> getSubscriptions(String previousSubscriptionId , String upgradeSubscriptionId){
        Map<String , Object> sMap = new Map<String, Object>();
        SSSubscriptionModel psModel = SSSubscriptionHelper.getSubscription(previousSubscriptionId);
        SSSubscriptionModel usModel = SSSubscriptionHelper.getSubscription(upgradeSubscriptionId);
        sMap.put('previousSubscription' , psModel);
        sMap.put('upgradeSubscription' , usModel);
        return sMap;
    }

}