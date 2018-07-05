global class SSBillingSubscriptionModel {

global String billingAccountId {get; set;}
global String billingAccountNumber {get; set;} 
    global String paymentMethodId {get; set;}
global Map<String,List<subscriptionModel>> subscriptionMap {get; set;}//{ subscriptionMap = new  Map<String,List<subscriptionModel>>(); }    

  
global Class subscriptionModel {
global String billingSubscriptionId {get; set;}
global DateTime billingStartDate {get; set;}
global DateTime billingLastBilledDate {get; set;}
global String subscriptionStatus {get; set;}
global DateTime billingSubscriptionEndDate {get; set;}
global String billingSubscriptionNumber {get; set;}
global String billingProductSku {get; set;}
    }
    
}