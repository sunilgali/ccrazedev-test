global class CSSPriceTierModel {
    @AuraEnabled
    global String tierAttribute {get;set;}
    @AuraEnabled
    global String attributeValue {get;set;}
    @AuraEnabled
    global Decimal minQuantity {get;set;} 
    @AuraEnabled
    global Decimal maxQuantity {get;set;} 
    @AuraEnabled
    global Double listPrice {get;set;} 
    @AuraEnabled
    global Double bundleDiscountedPrice {get;set;} 
    @AuraEnabled
    global String tierDescription {get;set;}
    @AuraEnabled
    global Boolean selected {get;set;}
    @AuraEnabled
    global String quantity {get;set;}
    @AuraEnabled
    global String tierId {get;set;}

}