global class ccSSCreateZuoraSubscriptionImpl implements ISSBillingSubscription {
 global SSBillingSubscriptionModel createSubscription  (String cartId,SSAccountModel account, SSContactModel contact, DateTime subscriptionStartDate,
                                                  String currencyCode, String locale, String paymentReferenceID,
                                                  String paymentType, SSPaymentDetailsModel paymentDetails) {
    SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
   System.debug('createSubscription');
   Callout_Configuration__mdt[] zuoraCreateSubscriptionCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c
   , Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCreateAccount'];  
    // System.debug('createSubscription'+zuoraCreateSubscriptionCalloutConfig[0].Endpoint_URL__c);                                  
    if(!zuoraCreateSubscriptionCalloutConfig.IsEmpty()) { 
       
    billingModel = SSZuoraUtil.createSubscription(cartId, account, contact, subscriptionStartDate, currencyCode, locale, paymentReferenceID, paymentType, paymentDetails, zuoraCreateSubscriptionCalloutConfig[0].Endpoint_URL__c, zuoraCreateSubscriptionCalloutConfig[0].Username__c, zuoraCreateSubscriptionCalloutConfig[0].Password__c, zuoraCreateSubscriptionCalloutConfig[0].Version__c,zuoraCreateSubscriptionCalloutConfig[0].HTTP_Method__c);     
   System.debug('createSubscription');
    }                                                               
                                                               
    return billingModel;                                        
                                                           }
    
    
    /*
    global Static SSBillingSubscriptionModel cancelSubscription (String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId, DateTime cancellationDate){
    SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
    return billingModel;     
    }

    global Static SSBillingSubscriptionModel regradeSubscription (String cartId,String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId,DateTime regradeEffectiveDate,
                                                   String subscriptionEndDate, String currencyCode, String Locale, String paymentType,
                                                           SSPaymentDetailsModel paymentDetails, String paymentReferenceID,String regradeType){
                              SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
                                                               
                                   return billingModel;                                   
                                                           }
    
    
    global Static SSBillingSubscriptionModel reactivateSubscription (String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId, DateTime reactivationDate){
    SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
    return billingModel;        
    }

    
    
    global Static SSBillingSubscriptionModel crossSellSubscription (String cartId,String ccSSSubscriptionId, String billingAccountId,DateTime effectiveDate,
                                                   String subscriptionEndDate, String currencyCode, String Locale, String paymentType,
                                                      SSPaymentDetailsModel paymentDetails, String paymentReferenceID){
    SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
    return billingModel;                                  
                                                          
                                                      }
*/
   
}