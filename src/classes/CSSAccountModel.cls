global class CSSAccountModel {
	@AuraEnabled
    global String accountId {get; set;}
    @AuraEnabled
    global String accountName {get; set;}
    @AuraEnabled
    global String phone {get; set;}
    @AuraEnabled
    global CSSContactModel billingContact {get;set;}
    

}