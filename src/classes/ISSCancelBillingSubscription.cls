global Interface ISSCancelBillingSubscription {
 
    SSBillingSubscriptionModel cancelSubscription (String ccSSSubscriptionId, String billingSubscriptionId,String billingAccountId, DateTime cancellationDate, String cancellationPolicy) ;

}