global class CSSBillingAccountModel {
    @AuraEnabled
	global String billingAccountId {get; set;}
    @AuraEnabled
	global String billingAccountNumber {get; set;} 
    @AuraEnabled
	global Map<String,List<CSSBillingSubscriptionModel>> subscriptionMap {get; set;}
  
	global Class CSSBillingSubscriptionModel {
	    @AuraEnabled
		global String billingSubscriptionId {get; set;}
	    @AuraEnabled
		global DateTime billingStartDate {get; set;}
    	@AuraEnabled
		global DateTime billingLastBilledDate {get; set;}
    	@AuraEnabled
		global String subscriptionStatus {get; set;}
    	@AuraEnabled
		global DateTime billingSubscriptionEndDate {get; set;}
    	@AuraEnabled
		global String billingSubscriptionNumber {get; set;}
    	@AuraEnabled
		global String billingProductSku {get; set;}
    }

}