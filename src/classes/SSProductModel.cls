global class SSProductModel extends SSBaseModel {
    @AuraEnabled
    global String productId {get;set;} 
    @AuraEnabled
    global String productType {get;set;} // in json: type
    @AuraEnabled
    global String productName {get;set;} 
    @AuraEnabled
    global String productSKU {get;set;} 
    global String alternateName {get;set;} 
    global String status {get;set;} 
    global String country {get;set;}
    global String currencyUnit {get;set;} 
    global String locale {get; set;} 
    global String productSubscriptionType {get; set;} 
    global String productFamily {get;set;} 
    global List<String> categories {get;set;} 
    global String industry {get;set;}         
    global List<String> segment {get;set;} 
    global Date startDate {get;set;}  
    global Date endDate {get;set;} 
    global String longDescription {get;set;} 
    global String shortDescription {get;set;} 
    global String uom {get;set;}  
    global Decimal quantityPerUnit {get;set;} 
    global String storefront {get; set;}
    
    //trial related attributes
    global Boolean trial {get;set;}  
    global string trialLength {get;set;} 
    
    //bundle related attributes   
    @AuraEnabled
    global Boolean isBundledProduct {get; set;}
    @AuraEnabled
    global List<SSProductModel> bundleComponents {get;set;} 
    global Double bundleListPrice {get;set;} 
    global Double bundleDiscountedPrice {get;set;} 
    global Double bundleSavingsPercentage {get;set;} 
    
    //pricing related attributes
    @AuraEnabled
    global Boolean isTierPriced {get;set;}  
    @AuraEnabled
    global List<SSPriceModel> price {get;set;}
    global String tierCode {get; set;}
    
    //pricing setup for product
    global String soldBy {get;set;}
    global Boolean taxable {get;set;} 
    global String priceType {get;set;}
    global String periodOrFrequency {get;set;} 
    global String termsAndConditions {get;set;}
    global Boolean individuallySold {get;set;}  
    global String cancellationPeriod {get;set;} 
    
    //zuora or subscription engine related attributes
    global String billingProductId {get;set;} 
    global String sfdcProductId {get;set;} 
    global String provisionProductId {get;set;}
    
    //related products
    @AuraEnabled
    global List<SSProductModel> crossSellProducts {get;set;} 
    @AuraEnabled
    global List<SSProductModel> upSellProducts {get;set;} 
    @AuraEnabled
    global List<SSProductModel> addOnProducts {get;set;} 
    @AuraEnabled
    global List<SSProductModel> maintainanceProducts {get;set;} 
    @AuraEnabled
    global SSProductModel buyProduct {get;set;} 
    @AuraEnabled
    global SSProductModel trialProduct {get;set;} 
    
    global boolean isVatOrTaxExempt {get;set;}
    global String taxCode {get; set;}       
    
    //bundle component related attributes
    @AuraEnabled
    global Boolean bundleComponentIsOptional {get; set;}
    global String bundleComponentDescription {get; set;}
    
    global String productShortDescription {get; set;}
    @AuraEnabled
    global String productLongDescription {get; set;}
    global String contractDuration {get; set;}
    global Boolean vatRule {get; set;}
    
    global String entitlementProductId {get; set;}
    global String subscriptionDisclaimer {get; set;}
    @AuraEnabled	
    global String productThumbImage {get; set;}  
    @AuraEnabled	
    global String productImage {get; set;} 
    @AuraEnabled	
    global String relationType {get; set;} 
}