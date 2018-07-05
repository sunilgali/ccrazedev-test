global class SSSubscriptionModel extends SSBaseModel{
     
    global String storefront {get; set;}
    @AuraEnabled
    global String subscriptionId {get; set;}
    @AuraEnabled
    global String parentSubscriptionId {get; set;}
    
    //startdate,enddate need?
   // global DateTime subscriptionStartDate {get; set;}
  //  global DateTime subscriptionEndDate {get; set;}
  //  @AuraEnabled
    global String subscriptionStatus {get; set;}
    @AuraEnabled
    global String subscriptionEvent {get; set;}
 //   global String subscriptionTermType {get; set;}
    @AuraEnabled
    global SSAccountModel account {get; set;}
    @AuraEnabled
    global SSContactModel contact {get; set;}
    
    @AuraEnabled
    global SSCartModel cart {get; set;}
    @AuraEnabled
    global List<SSSubscriptionItemModel> subscribedProducts {get; set;}
    @AuraEnabled
    global Decimal totalAmount {get; set;}
    global Decimal discountedAmount {get; set;}
    global Decimal percentageDiscount {get; set;}
    global Decimal subTotalAmount {get; set;}
    global Decimal taxAmount {get; set;}
    global Decimal taxPercentage {get; set;}
      
    global String provisiongProductId {get; set;}
    global String billingProductId {get; set;}
    global String billingAccountId {get; set;}
    
    @AuraEnabled
    global String orderId {get; set;}
    global String transactionReferenceNumber {get; set;}
    global SSSubscriptionModel parentSubscription {get; set;}
    @AuraEnabled
   	global SSSubscriptionItemModel sortedSubscription {get; set;}
}