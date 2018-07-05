global class ccSSRegradeZuoraSubscriptionImpl implements ISSRegradeBillingSubscription{
 global SSBillingSubscriptionModel regradeSubscription (String cartId,String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId,DateTime regradeEffectiveDate,String regradeType){
    SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
    System.debug('regradeSubscription');
   Callout_Configuration__mdt[] zuoraregradeSubscriptionCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c
   , Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCancelSubscription'];                                    
    if(!zuoraregradeSubscriptionCalloutConfig.IsEmpty()) {      
   billingModel = SSZuoraRegradeUtil.regradeSubscription (cartId,billingSubscriptionId,billingAccountId,regradeEffectiveDate,
                                                          zuoraregradeSubscriptionCalloutConfig[0].Endpoint_URL__c, zuoraregradeSubscriptionCalloutConfig[0].Username__c, zuoraregradeSubscriptionCalloutConfig[0].Password__c, zuoraregradeSubscriptionCalloutConfig[0].Version__c,zuoraregradeSubscriptionCalloutConfig[0].HTTP_Method__c);                                                      
      }  
        return billingModel;  
}
}