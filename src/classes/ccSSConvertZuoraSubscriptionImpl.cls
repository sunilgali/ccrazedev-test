global class ccSSConvertZuoraSubscriptionImpl implements ISSConvertBillingSubscription{
global SSBillingSubscriptionModel convertSubscription (String cartId,SSAccountModel account, SSContactModel contact, DateTime subscriptionStartDate,
                                                  String currencyCode, String locale, String paymentReferenceID,
                                                  String paymentType, SSPaymentDetailsModel paymentDetails,String billingAccountId,Boolean isBillingAccountCreated){
    SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
   Callout_Configuration__mdt[] zuoraconvertSubscriptionCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c
   , Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCreateAccount'];                                    
    if(!zuoraconvertSubscriptionCalloutConfig.IsEmpty()) {   
        if(isBillingAccountCreated){ 
         System.debug('Billing account is already created');  
        billingModel = SSZuoraUtil.createZuoraSubscription (cartId, billingAccountId,subscriptionStartDate); 
           } 
        else{
             System.debug(' Create Billing account and Billing Subscription'); 
          billingModel = SSZuoraUtil.createSubscription(cartId, account, contact, subscriptionStartDate, currencyCode, locale, paymentReferenceID, paymentType, paymentDetails, zuoraconvertSubscriptionCalloutConfig[0].Endpoint_URL__c, zuoraconvertSubscriptionCalloutConfig[0].Username__c, zuoraconvertSubscriptionCalloutConfig[0].Password__c, zuoraconvertSubscriptionCalloutConfig[0].Version__c,zuoraconvertSubscriptionCalloutConfig[0].HTTP_Method__c);     
        
        }
}                                                        
    return billingModel;  
}
}