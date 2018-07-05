global interface ICSSCrossSellBillingSubscription {
    
      CSSBillingAccountModel createCrossSellSubscription (String cartId,String cssSubscriptionId, String billingAccountId,DateTime subscriptionStartDate,
                                                    String currencyCode, String Locale, String paymentType,
                                                    String paymentReferenceID, CSSPaymentDetailsModel paymentDetails);


}