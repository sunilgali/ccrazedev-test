global class ccSSReactivateZuoraSubscriptionImpl implements ISSReactivateBillingSubscription {
    global SSBillingSubscriptionModel reactivateSubscription(String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId, DateTime reactivationDate){
    SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
    System.debug('cancelSubscription');
   Callout_Configuration__mdt[] zuoraReactivateSubscriptionCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c
   , Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCancelSubscription'];                                    
    if(!zuoraReactivateSubscriptionCalloutConfig.IsEmpty()) {      
  //  billingModel = SSZuoraUtil.cancelSubscription (billingSubscriptionId,billingAccountId,reactivationDate,zuoraReactivateSubscriptionCalloutConfig[0].Endpoint_URL__c, zuoraReactivateSubscriptionCalloutConfig[0].Username__c, zuoraReactivateSubscriptionCalloutConfig[0].Password__c, zuoraReactivateSubscriptionCalloutConfig[0].Version__c,zuoraReactivateSubscriptionCalloutConfig[0].HTTP_Method__c);

}                                                        
    return billingModel;  
}
}