global Interface ISSBillingSubscription {

    SSBillingSubscriptionModel createSubscription (String cartId,SSAccountModel account, SSContactModel contact, DateTime subscriptionStartDate,
                                                  String currencyCode, String locale, String paymentReferenceID,
                                                  String paymentType, SSPaymentDetailsModel paymentDetails);
    
 /*   SSBillingSubscriptionModel cancelSubscription (String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId, DateTime cancellationDate) ;

    SSBillingSubscriptionModel regradeSubscription (String cartId,String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId,DateTime regradeEffectiveDate,
                                                   String subscriptionEndDate, String currencyCode, String Locale, String paymentType,
                                                   SSPaymentDetailsModel paymentDetails, String paymentReferenceID,String regradeType);
    SSBillingSubscriptionModel reactivateSubscription (String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId, DateTime reactivationDate);

    SSBillingSubscriptionModel crossSellSubscription (String cartId,String ccSSSubscriptionId, String billingAccountId,DateTime effectiveDate,
                                                   String subscriptionEndDate, String currencyCode, String Locale, String paymentType,
                                                   SSPaymentDetailsModel paymentDetails, String paymentReferenceID);
*/
   
}