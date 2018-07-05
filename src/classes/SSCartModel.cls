global class SSCartModel extends SSBaseModel {

    @AuraEnabled
    global String cartId;
    @AuraEnabled
    global String sfId;
    @AuraEnabled
    global String storefront;
    
    @AuraEnabled
    global String cartNumber;
    @AuraEnabled
    global String transactionType;
    @AuraEnabled
    global String cartStatus;
    @AuraEnabled
    global String cartType;
    
    @AuraEnabled
    global String currencyCode;
    @AuraEnabled
    global String locale;
    @AuraEnabled
    global String country;
    @AuraEnabled
    global Decimal totalAmount;
    @AuraEnabled
    global Decimal subTotalAmount;
    @AuraEnabled
    global Decimal adjustmentAmount;
    @AuraEnabled
    global String adjustmentReason;
    @AuraEnabled
    global Decimal taxAmount;
    @AuraEnabled
    global Decimal taxPercentage;
    
    @AuraEnabled
    global Boolean taxExemptFlag;
    @AuraEnabled
    global Decimal taxSubtotalAmount;
    @AuraEnabled
    global Decimal totalDiscount;
    @AuraEnabled
    global String vatNumber;
    @AuraEnabled
    global String taxCode;
    
    @AuraEnabled
    global String accountId;
    @AuraEnabled
    global String contactId;
    @AuraEnabled
    global String billTo;
    @AuraEnabled
    global String opportunityId;
    @AuraEnabled
    global String paymentId;
    
    @AuraEnabled
    global String cartLocale;
    @AuraEnabled
    global String cartLocaleId;
    @AuraEnabled
    global String paymentMethodId;
    @AuraEnabled
    global String userIdentityId;
    
    @AuraEnabled
    global String buyerEmail;
    
   	//What is the difference between these 2. Seems to be the same  
    @AuraEnabled
    global List<SSCartItemModel> cartItemList;
    @AuraEnabled
    global List<SSCartItemModel> cartItems;
    
    @AuraEnabled
    global String localeId;
    @AuraEnabled
    global String transactionReferenceNumber;
    @AuraEnabled
    global String subscriptionTermType;
    
    @AuraEnabled
    global String portalUserName;
    
    @AuraEnabled
    global String subscriptionItemId;
}