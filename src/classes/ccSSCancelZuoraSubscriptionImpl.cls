global class ccSSCancelZuoraSubscriptionImpl implements ISSCancelBillingSubscription {
    global SSBillingSubscriptionModel cancelSubscription (String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId, DateTime cancellationDate, String cancellationPolicy){
    SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
    System.debug('cancelSubscription');
   Callout_Configuration__mdt[] zuoraCancelSubscriptionCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c
   , Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCancelSubscription'];                                    
    if(!zuoraCancelSubscriptionCalloutConfig.IsEmpty()) {      
    billingModel = SSZuoraCancelUtil.cancelSubscription (ccSSSubscriptionId,billingSubscriptionId,billingAccountId,cancellationDate,cancellationPolicy,zuoraCancelSubscriptionCalloutConfig[0].Endpoint_URL__c, zuoraCancelSubscriptionCalloutConfig[0].Username__c, zuoraCancelSubscriptionCalloutConfig[0].Password__c, zuoraCancelSubscriptionCalloutConfig[0].Version__c,zuoraCancelSubscriptionCalloutConfig[0].HTTP_Method__c);

}                                                        
    return billingModel;  
}
}