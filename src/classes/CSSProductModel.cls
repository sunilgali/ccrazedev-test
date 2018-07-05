global class CSSProductModel {
    
    @AuraEnabled
    global String productId {get;set;} 
    @AuraEnabled
    global String productSKU {get;set;} 
    @AuraEnabled
    global String productType {get;set;}
    @AuraEnabled
    global String productName {get;set;} 
    @AuraEnabled
    global String alternateName {get;set;} 

    @AuraEnabled
    global String status {get;set;} 
    @AuraEnabled
    global String country {get;set;}
    @AuraEnabled
    global String currencyUnit {get;set;} 
    @AuraEnabled
    global String locale {get; set;} 
    @AuraEnabled
    global String productFamily {get;set;} 
    @AuraEnabled
    global List<String> categories {get;set;} 
    @AuraEnabled
    global String industry {get;set;}         
    @AuraEnabled
    global List<String> segment {get;set;} 
    @AuraEnabled
    global String longDescription {get;set;} 
    @AuraEnabled
    global String shortDescription {get;set;} 
    @AuraEnabled
    global String uom {get;set;}  
    @AuraEnabled
    global Decimal quantityPerUnit {get;set;} 
    @AuraEnabled
    global String storefront {get; set;}
    @AuraEnabled
    global Date startDate {get;set;}  
    @AuraEnabled
    global Date endDate {get;set;} 
    
    //trial related attributes
    @AuraEnabled
    global Boolean trial {get;set;}  
    @AuraEnabled
    global String trialLength {get;set;} 
    
    //bundle related attributes   
    @AuraEnabled
    global Boolean isBundledProduct {get; set;}
    @AuraEnabled
    global List<CSSProductModel> bundleComponents {get;set;} 
    @AuraEnabled
    global Double bundleListPrice {get;set;} 
    @AuraEnabled
    global Double bundleDiscountedPrice {get;set;} 
    @AuraEnabled
    global Double bundleSavingsPercentage {get;set;} 
    //bundle component related attributes
    @AuraEnabled
    global Boolean bundleComponentIsOptional {get; set;}
    @AuraEnabled
    global String bundleComponentDescription {get; set;}
    @AuraEnabled
    global String parentBundleSku {get; set;}
    @AuraEnabled
    global String parentBundleDescription {get; set;}
    
    //pricing related attributes
    @AuraEnabled
    global Boolean tierPriced {get;set;}  
    @AuraEnabled
    global List<CSSPriceModel> price {get;set;}
    @AuraEnabled
    global String tierCode {get; set;}
    
    //pricing setup for product
    @AuraEnabled
    global String soldBy {get;set;}
    @AuraEnabled
    global Boolean taxable {get;set;} 
    @AuraEnabled
    global String priceType {get;set;}
    @AuraEnabled
    global String periodOrFrequency {get;set;} 
    @AuraEnabled
    global String termsAndConditions {get;set;}
    @AuraEnabled
    global Boolean individuallySold {get;set;}  
    @AuraEnabled
    global String cancellationPeriod {get;set;} 
    @AuraEnabled
    global boolean isVatOrTaxExempt {get;set;}
    @AuraEnabled
    global String taxCode {get; set;}           
    @AuraEnabled
    global String contractDuration {get; set;}
    @AuraEnabled
    global Boolean vatRule {get; set;}
        
    //related products
    @AuraEnabled
    global List<CSSProductModel> crossSellProducts {get;set;} 
    @AuraEnabled
    global List<CSSProductModel> upSellProducts {get;set;} 
    @AuraEnabled
    global List<CSSProductModel> addOnProducts {get;set;} 
    @AuraEnabled
    global List<CSSProductModel> maintainanceProducts {get;set;} 
    @AuraEnabled
    global CSSProductModel buyProduct {get;set;} 
    @AuraEnabled
    global CSSProductModel trialProduct {get;set;} 
        
    @AuraEnabled
    global String subscriptionDisclaimer {get; set;}
    
    //product media
    @AuraEnabled	
    global String productThumbnailImage {get; set;}  
    @AuraEnabled	
    global String productImage {get; set;}  

    //zuora or subscription engine related attributes
    @AuraEnabled
    global String billingProductId {get;set;} 
    @AuraEnabled
    global String billingProductRatePlanId {get;set;} 
    @AuraEnabled
    global String sfdcProductId {get;set;} 
    @AuraEnabled
    global String provisionProductId {get;set;}

    @AuraEnabled
    global String entitlementProductId {get; set;}

    //changed attribute models
    @AuraEnabled
    global String subscriptionType {get; set;} 
    
    @AuraEnabled
    global String parentSKU {get; set;}
    
    //used for Cart Item
	@AuraEnabled
    global Integer bundleChildQuantity {get; set;}
    //used for bundle child component in a cart item
    @AuraEnabled
    global List<CSSPriceTierModel> bundleChildSelectedTierList;
    
}