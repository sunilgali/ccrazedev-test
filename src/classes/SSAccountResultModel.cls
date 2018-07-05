global class SSAccountResultModel extends SSBaseModel {
    @AuraEnabled
    global String accountName {get; set;}
    @AuraEnabled
    global String accountId {get; set;}
    @AuraEnabled
    global String contactId {get; set;}
    @AuraEnabled
    global String opportunityId {get; set;}
    
}