global with sharing class SSSubscriptionHookExtension extends ccrz.cc_hk_Subscriptions {

     global override Map<String,Object> cancelSubscription(Map<String,Object> inputData)
    { 
        
        
        Map<String, Object> inputDataForSub = new Map<String,Object>();
        
        inputDataForSub.put(ccrz.cc_hk_Subscriptions.PARAM_SUBSCRIPTIONID,(object)inputData.get('subscriptionId'));
        
        Map<String, Object> res = new Map<String, Object> {ccrz.ccApi.SUCCESS => false};
        
        res = super.cancelSubscription(inputDataForSub);
        
        System.debug('cchk_Subscription: process: result is .... ' +  res);
        
        return inputData;
    }
    
}