global Interface ISSConvertBillingSubscription {

     SSBillingSubscriptionModel convertSubscription (String cartId,SSAccountModel account, SSContactModel contact, DateTime subscriptionStartDate,
                                                  String currencyCode, String locale, String paymentReferenceID,
                                                  String paymentType, SSPaymentDetailsModel paymentDetails,String billingAccountId,Boolean isBillingAccountCreated);
    
}