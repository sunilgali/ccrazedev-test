global interface ICSSBillingSubscription {
    CSSBillingAccountModel createSubscription (String cartId,CSSAccountModel account, CSSContactModel contact, DateTime subscriptionStartDate,
                                                  String currencyCode, String locale, String paymentReferenceID,
                                                  String paymentType, CSSPaymentDetailsModel paymentDetails);
    
 /*   CSSBillingAccountModel cancelSubscription (String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId, DateTime cancellationDate) ;

    CSSBillingAccountModel regradeSubscription (String cartId,String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId,DateTime regradeEffectiveDate,
                                                   String subscriptionEndDate, String currencyCode, String Locale, String paymentType,
                                                   SSPaymentDetailsModel paymentDetails, String paymentReferenceID,String regradeType);
    CSSBillingAccountModel reactivateSubscription (String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId, DateTime reactivationDate);

    CSSBillingAccountModel crossSellSubscription (String cartId,String ccSSSubscriptionId, String billingAccountId,DateTime effectiveDate,
                                                   String subscriptionEndDate, String currencyCode, String Locale, String paymentType,
                                                   SSPaymentDetailsModel paymentDetails, String paymentReferenceID);
*/
   

}