global class SSPriceModel {
    
    global String priceType {get;set;}
    global String unitOfMeasure {get;set;}
    global String currencyCode {get;set;} 
    global Date startDate {get;set;}
    global Date endDate {get;set;}
    global boolean enabled {get;set;} 
    @AuraEnabled
    global String priceListID {get;set;} 
    @AuraEnabled
    global String priceListItemID {get;set;} 
    global String priceListName {get;set;} 
    @AuraEnabled
    global Double listPrice {get;set;} 
    global Decimal minQuantity {get;set;}  
    global Decimal maxQuantity {get;set;} 
    global Boolean recurringPrice {get;set;}  
    global String uom {get;set;}   
    
    global String subscriptionTermId {get;set;} 
    global Long subscriptionDuration {get;set;} 
    @AuraEnabled
    global String subscriptionFrequency {get;set;} 
    global Boolean subscriptionAutoRenewal {get;set;} 
    global Boolean availableForSubscription {get;set;} 
    global Decimal subscriptionInstallmentCount {get;set;} 
    global Decimal subscriptionInstallmentFrequency {get;set;} 
    @AuraEnabled
    global String subscriptionInstallmentUOM {get;set;} 
    
    // Tiered Product Attributes
    @AuraEnabled
    global List<SSTierPriceModel> tierPriceList {get;set;} 
    global Double bundledComponentPrice {get;set;} 
    
    global String productId {get;set;}
    global String productName {get;set;}
    
    global String productType {get;set;}
    global String attributePricing {get; set;} //json type
    
    @AuraEnabled
    global Boolean selected {get;set;}
}