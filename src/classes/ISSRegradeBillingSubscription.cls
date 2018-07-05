global Interface ISSRegradeBillingSubscription {

   /* SSBillingSubscriptionModel regradeSubscription (String cartId,String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId,DateTime regradeEffectiveDate,
                                                   String subscriptionEndDate, String currencyCode, String Locale, String paymentType,
                                                   SSPaymentDetailsModel paymentDetails, String paymentReferenceID,String regradeType*/
    SSBillingSubscriptionModel regradeSubscription (String cartId,String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId,DateTime regradeEffectiveDate,
                                                    String regradeType);
    
}