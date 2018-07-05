global class SSCartItemModel {

    @AuraEnabled
    global String Sku;
    @AuraEnabled
    global String productId;
    @AuraEnabled
    global String productName;
    global String productShortDescription;
    global String productLongDescription;
    @AuraEnabled
    global string parentSku;
    
    global String cartId;
    @AuraEnabled
    global Decimal quantity;

    @AuraEnabled
    global String cartItemQuantity;

    @AuraEnabled
    global String parentbundleSKU;
    @AuraEnabled
    global String parentbundleDescription;
    @AuraEnabled
    global List<SSCartItemTierModel> tier;
    @AuraEnabled
    global List<bundleChildComponents> bundleComponent;
    
    @AuraEnabled
    global String couponCode;
    global String couponType;
    global String couponMessage;
    global String couponShortDescription;
    global String couponLongDescription;
    
    global String billingProductId;
    global String billingProductRatePlanId;
    global String provisiongProductId;
        
      
    //Additional Fields
    global Integer trialLength;
    global Decimal absoluteDiscount;
    global Decimal percentageDiscount;
    global Decimal adjustmentAmount;
    @AuraEnabled
    global Decimal subAmount;
    global Decimal taxAmount;
    global Decimal taxPercentage;
    
    global String category;
    
    global Decimal price;
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

    global String cartItemId;
    global String cartItemNumber;
    
    global String cartItemType;
    global String comments;
    @AuraEnabled
    global string relatedProductType;
    @AuraEnabled
    global string relatedProductParentSku;
    @AuraEnabled
    global String couponPurpose;
    
    global DateTime contractEffectiveDate;
    global DateTime contractStartDate;
    @AuraEnabled
    global String productType;
    @AuraEnabled
    global Boolean isTierPriced;
    @AuraEnabled
    global String isProductBundle;
    @AuraEnabled
    global List<SSTierPriceModel> tierPrice;
    @AuraEnabled
    global List<Id> lineDataAttributeList;
    @AuraEnabled
    global List<String> lineDataAttributes;
    
 	@AuraEnabled
    global String parentProductBundleSKU;
    @AuraEnabled
    global String parentProductBundleDescription;
    @AuraEnabled
    global String tierDescription;
    
    @AuraEnabled
    global List<SSCartItemModel> addonProducts;
    @AuraEnabled
    global List<SSCartItemModel> bundleComponents;
}