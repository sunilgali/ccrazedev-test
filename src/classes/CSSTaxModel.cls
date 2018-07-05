global class CSSTaxModel {
    @AuraEnabled
    global String country {get; set;}
    @AuraEnabled
    global Decimal taxAmount {get; set;}
    @AuraEnabled
    global Decimal taxRate {get; set;}
    @AuraEnabled
    global Decimal taxableAmount {get; set;}
    @AuraEnabled
    global Decimal totalAmount {get; set;}
    

}