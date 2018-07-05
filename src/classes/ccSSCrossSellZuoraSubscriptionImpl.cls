global class ccSSCrossSellZuoraSubscriptionImpl implements ISSCrossSellBillingSubscription{
 global SSBillingSubscriptionModel createCrossSellSubscription (String cartId,String ccSSSubscriptionId, String billingAccountId,DateTime subscriptionStartDate,
                                                    String currencyCode, String Locale, String paymentType,
                                                    String paymentReferenceID,SSPaymentDetailsModel paymentDetails) {
    SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
   System.debug('createSubscription');
                                                        
  // Callout_Configuration__mdt[] zuoraCreateSubscriptionCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c
 //  , Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCreateAccount_SANDBOX'];  
    // System.debug('createSubscription'+zuoraCreateSubscriptionCalloutConfig[0].Endpoint_URL__c);                                  
  //  if(!zuoraCreateSubscriptionCalloutConfig.IsEmpty()) { 
       
  billingModel = SSZuoraUtil.createCrossSellSubscription(cartId,billingAccountId,subscriptionStartDate);     
   System.debug('createSubscription');
 //   }                                                               
                                                               
    return billingModel;                                        
                                                  }
}