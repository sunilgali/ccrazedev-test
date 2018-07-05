global interface ISSCrossSellBillingSubscription {

  SSBillingSubscriptionModel createCrossSellSubscription (String cartId,String ccSSSubscriptionId, String billingAccountId,DateTime subscriptionStartDate,
                                                    String currencyCode, String Locale, String paymentType,
                                                    String paymentReferenceID,SSPaymentDetailsModel paymentDetails);
 
}