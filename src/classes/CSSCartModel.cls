global class CSSCartModel extends CSSBaseModel {
    
    @AuraEnabled
    global String storefront;

    @AuraEnabled
    global String cartId;
    @AuraEnabled
    global String encryptedCartId;
    @AuraEnabled
    global String cartNumber;
    @AuraEnabled
    global String cartStatus;
    @AuraEnabled
    global String cartType;    
    @AuraEnabled
    global String transactionType;
    
    @AuraEnabled
    global String currencyCode;
    @AuraEnabled
    global String locale;
    @AuraEnabled
    global String cartLocale;
    @AuraEnabled
    global String cartLocaleId;
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
    global String paymentMethodId;
    @AuraEnabled
    global String userIdentityId;
    
    @AuraEnabled
    global String buyerEmail;
    
    @AuraEnabled
    global List<CSSCartItemModel> cartItemList;
    
    @AuraEnabled
    global String localeId;
    @AuraEnabled
    global String transactionReferenceNumber;
    @AuraEnabled
    global String subscriptionTermType;
    
    @AuraEnabled
    global String portalUserName;
}