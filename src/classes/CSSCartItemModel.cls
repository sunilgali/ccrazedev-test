global class CSSCartItemModel {

    @AuraEnabled
    global String cartItemId;
    @AuraEnabled
    global String cartId;
    @AuraEnabled
    global Decimal quantity;
    @AuraEnabled
    global Integer trialLength;
    @AuraEnabled
    global Decimal absoluteDiscount;
    @AuraEnabled
    global Decimal percentageDiscount;
    @AuraEnabled
    global Decimal adjustmentAmount;
    @AuraEnabled
    global Decimal subAmount;
    @AuraEnabled
    global Decimal taxAmount;
    @AuraEnabled
    global Decimal taxPercentage;


    @AuraEnabled
    global CSSProductModel product;

    @AuraEnabled
    global List<CSSPriceTierModel> selectedTierList;
    @AuraEnabled
    global List<CSSProductModel> selectedBundleComponentList;
    
    @AuraEnabled
    global String parentBundleSku;
    @AuraEnabled
    global String parentBundleDescription;
    @AuraEnabled
    global String tierDescription;

    @AuraEnabled
    global String couponCode;
    @AuraEnabled
    global String couponType;
    @AuraEnabled
    global String couponMessage;
    @AuraEnabled
    global String couponShortDescription;
    @AuraEnabled
    global String couponLongDescription;
    
    //Additional Fields
    
    @AuraEnabled
    global String category;
    
    @AuraEnabled
    global Decimal price;
    @AuraEnabled
    global String pricingType;
    @AuraEnabled
    global String subProdTermId;
    @AuraEnabled
    global String subscriptionTermType;
    @AuraEnabled
    global Decimal subscriptionFrequency;
    @AuraEnabled
    global Decimal subscriptionDuration;
    @AuraEnabled
    global String subscriptionTermId;

    @AuraEnabled
    global String cartItemNumber;
    @AuraEnabled
    global String cartItemType;
    @AuraEnabled
    global String comments;
    
    @AuraEnabled
    global String couponPurpose;
    
    @AuraEnabled
    global DateTime contractEffectiveDate;
    @AuraEnabled
    global DateTime contractStartDate;



    @AuraEnabled
    global List<Id> lineDataAttributeList;
    @AuraEnabled
    global List<String> lineDataAttributes;
    
}