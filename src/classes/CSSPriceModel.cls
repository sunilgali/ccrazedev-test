global class CSSPriceModel {
    @AuraEnabled
    global String priceType {get;set;}
    @AuraEnabled
    global String uom {get;set;}
    @AuraEnabled
    global String currencyCode {get;set;} 
    @AuraEnabled
    global Date startDate {get;set;}
    @AuraEnabled
    global Date endDate {get;set;}
    @AuraEnabled
    global boolean enabled {get;set;} 
    @AuraEnabled
    global String priceListId {get;set;} 
    @AuraEnabled
    global String priceListItemId {get;set;} 
    @AuraEnabled
    global String priceListName {get;set;} 
    @AuraEnabled
    global Double listPrice {get;set;} 
    @AuraEnabled
    global Decimal minQuantity {get;set;}  
    @AuraEnabled
    global Decimal maxQuantity {get;set;} 
    @AuraEnabled
    global Boolean recurringPrice {get;set;}  
    
    @AuraEnabled
    global String subscriptionTermId {get;set;} 
    @AuraEnabled
    global Long subscriptionDuration {get;set;} 
    @AuraEnabled
    global String subscriptionFrequency {get;set;} 
    @AuraEnabled
    global Boolean subscriptionAutoRenewal {get;set;} 
    @AuraEnabled
    global Boolean availableForSubscription {get;set;} 
    @AuraEnabled
    global Decimal subscriptionInstallmentCount {get;set;} 
    @AuraEnabled
    global Decimal subscriptionInstallmentFrequency {get;set;} 
    @AuraEnabled
    global String subscriptionInstallmentUOM {get;set;} 
    
    // Tiered Product Attributes
    @AuraEnabled
    global List<CSSPriceTierModel> tierPriceList {get;set;} 
    @AuraEnabled
    global Double bundledComponentPrice {get;set;} 
    
    @AuraEnabled
    global String productId {get;set;}
    @AuraEnabled
    global String productName {get;set;}
    
    @AuraEnabled
    global String productType {get;set;}
    @AuraEnabled
    global String attributePricing {get; set;} //json type
    
    @AuraEnabled
    global Boolean selected {get;set;}

}