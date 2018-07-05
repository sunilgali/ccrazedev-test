global class SSAccountModel extends SSBaseModel{
	@AuraEnabled
    global String accountId {get; set;}
    @AuraEnabled
    global String accountName {get; set;}
    @AuraEnabled
    global String phone {get; set;}
    @AuraEnabled
    global SSContactModel billingContact {get;set;}
    
}