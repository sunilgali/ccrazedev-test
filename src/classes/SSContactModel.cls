global class SSContactModel {

    @AuraEnabled
    global String firstName {get; set;}
    @AuraEnabled
    global String lastName {get; set;}
    @AuraEnabled
    global String email {get; set;}
    @AuraEnabled
    global String phone {get; set;}
    @AuraEnabled
    global String contactId {get; set;}
    @AuraEnabled
    global SSAddressModel address {get; set;}
   
}