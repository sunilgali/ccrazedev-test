global class CSSAddressModel {
    
    @AuraEnabled
    global String streetAddress {get; set;}
    @AuraEnabled
    global String city {get; set;}
    @AuraEnabled
    global String state {get; set;}
    @AuraEnabled
    global String country {get; set;}
    @AuraEnabled
    global String postalCode {get; set;}

}