global class SSSubscriptionItemModel extends SSBaseModel{

    @AuraEnabled
    global SSCartModel cart {get; set;}
    @AuraEnabled
    global String subscriptionId {get; set;}
    @AuraEnabled
    global String subscriptionItemId {get; set;}
    @AuraEnabled
    global String bundleProductSKU {get; set;}    
    @AuraEnabled
    global String bundleProductDescription {get; set;}
    @AuraEnabled
    global String tierDescription {get; set;}
    @AuraEnabled
    global String billingProductId {get; set;}
    @AuraEnabled
    global String billingSubscriptionId {get; set;}
    @AuraEnabled
    global String currencyISOCode {get; set;}
    @AuraEnabled
    global Boolean isTrial {get; set;} 
    @AuraEnabled
    global Decimal recurringPrice {get; set;}
    @AuraEnabled
    global String entitlementId {get; set;}
    @AuraEnabled
    global DateTime subscriptionStartDate {get; set;}
    @AuraEnabled
    global DateTime subscriptionEndDate {get; set;}
    @AuraEnabled
    global String productId {get; set;}
    @AuraEnabled
    global String productSKU {get; set;}
    @AuraEnabled
    global String productShortDescription {get; set;}
    @AuraEnabled
    global String productName {get; set;}
    @AuraEnabled
    global String productLongDescription {get; set;}
    
    //Additional Fields
    @AuraEnabled
    global String accountId {get; set;}
     @AuraEnabled
    global String contactId {get; set;}
    @AuraEnabled
    global String subscriptionTermType {get; set;}
    @AuraEnabled
    global String storefront {get; set;}
 	@AuraEnabled
    global String subscriptionStatus {get; set;}
    @AuraEnabled
    global String subscriptionEvent {get; set;}
    @AuraEnabled
    global Decimal productPrice {get; set;}
    @AuraEnabled
    global String productRelationType {get; set;}
    @AuraEnabled
    global String relatedProductParentSku {get; set;}
     @AuraEnabled
    global Decimal productQuantity {get; set;}
     @AuraEnabled
    global List<SSSubscriptionItemModel> childComponents {get; set;} 
  	@AuraEnabled
  	global Boolean isUpgradable {get; set;} 
    @AuraEnabled
    global String billingAccountId {get; set;}
    @AuraEnabled
    global List<SSProductModel> upsellProducts {get; set;}
    @AuraEnabled
    global String trailPeriod {get; set;}
}