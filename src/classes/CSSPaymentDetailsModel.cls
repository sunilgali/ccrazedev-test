global class CSSPaymentDetailsModel {
    //global String paymentType {get; set;}
    @AuraEnabled
    global String cardType {get; set;}
    @AuraEnabled
    global String cardNumber {get; set;}
    @AuraEnabled
    global Integer expirationMonth {get; set;}
    @AuraEnabled
    global Integer expirationYear {get; set;}
    @AuraEnabled
    global String securityCode {get; set;}
    @AuraEnabled
    global String cardHolderName {get; set;}
    @AuraEnabled
    global String street {get; set;}
    @AuraEnabled
    global String city {get; set;}
    @AuraEnabled
    global String state {get; set;}
    @AuraEnabled
    global String country {get; set;}
    @AuraEnabled
    global String email {get; set;}
    @AuraEnabled
    global String phone {get; set;}
    @AuraEnabled
    global String postalCode {get;set;}

}