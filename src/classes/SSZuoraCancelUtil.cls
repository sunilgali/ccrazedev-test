global class SSZuoraCancelUtil {
    
     global static SSBillingSubscriptionModel cancelSubscription(String ccSubscriptionId,String billingSubscriptionId,String billingAccountId,DateTime cancellationDate, String cancellationPolicy, String zuoraServiceUrl ,String username,String password,String zuoraVersion,String httpMethod){
        SSBillingSubscriptionModel billingModel= new SSBillingSubscriptionModel();
        SSBillingSubscriptionModel.subscriptionModel subModel = new SSBillingSubscriptionModel.subscriptionModel();
        List<SSBillingSubscriptionModel.subscriptionModel> subModelList = new List<SSBillingSubscriptionModel.subscriptionModel>();   
           billingModel.subscriptionMap = new  Map<String,List<SSBillingSubscriptionModel.subscriptionModel>>();
       zuoraServiceUrl = zuoraServiceUrl+billingSubscriptionId+'/cancel';
       Date nextInvoiceDate =  getZuoraNextInvoiceDate(billingSubscriptionId);
       SSSubscriptionItemModel subItemModel = SSSubscriptionHelper.getCCSubscriptionById(ccSubscriptionId);
       String billingProductSku =  subItemModel.productSKU;
         System.debug('billingProductSku'+billingProductSku);
         System.debug('##InvoiceDate'+nextInvoiceDate);
         If (nextInvoiceDate!=null){
            cancellationPolicy ='EndOfLastInvoicePeriod'; 
         } 
         else{
             cancellationPolicy ='SpecificDate';            
         }
        
            HttpRequest req = SSZuoraRequestsUtil.getZuoraRequestHeader(zuoraServiceUrl, userName, password,zuoraVersion,httpMethod);
            String body = SSZuoraRequestsUtil.getCancelSubscriptionRequestBody(cancellationPolicy,cancellationDate); 
              req.setBody(body);                        
    Http http = new Http();
       try {
            HTTPResponse res = null;
            if (!Test.isRunningtest())
                {
                   res = http.send(req); 
                }else{
                }  
            System.debug('STATUS_CODE:'+res.getStatusCode());
            System.debug('Response body ' + res.getBody());
            Integer statusCode = res.getStatusCode();
            if (statusCode == 200) {

                String cancelSubResponse = res.getBody();
             JSONParser parser = JSON.createParser(cancelSubResponse);
                while (parser.nextToken() != null) {
                    parser.nextValue();
                    String tokenName = parser.getCurrentName();
                    String tokenValue = parser.getText();
                     if (tokenName != null) {
                         if (tokenName.equals('subscriptionId')) {
                            subModel.billingSubscriptionId = String.valueOf(tokenValue);
                         }
                         
                     }  
                     }
                 If (nextInvoiceDate!=null){
                subModel.billingSubscriptionEndDate = datetime.newInstance(nextInvoiceDate.year(), nextInvoiceDate.month(),nextInvoiceDate.day());
                 } else {
                     subModel.billingSubscriptionEndDate = System.Today();
                 }
             subModel.billingProductSku = billingProductSku;
             subModelList.add(subModel);
             System.debug('subModelList'+subModelList);
           billingModel.subscriptionMap.put(billingProductSku,subModelList);
            System.debug('subModelList'+billingModel.subscriptionMap);
                // billingModel.subscriptionModel  =subModel;
                 billingModel.billingAccountId= billingAccountId;
                }
           else {
                System.debug('Error retrieving subscription ' + statusCode);
                System.debug('Error retrieving subscription response ' + res.getBody());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CANCEL_ZUORA_SUBSCRIPTION_ERROR);
            }
            }      
        catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CANCEL_SUBSCRIPTION_CALLOUT);
        }      
         System.debug('Final Cancellation Payload'+billingModel);
                     return billingModel;
         
                                                            
   } 
    
    public Static Date getZuoraNextInvoiceDate(String billingSubscriptionId) {
      Date nextInvoiceDate;
        
        try {
      String ratePlanId;
      String zRatePlanQuery ='select Id,Name from RatePlan where SubscriptionId=\''+billingSubscriptionId+'\'';
                
         String ratePlanResult = SSZuoraUtil.getRestQueryResult(zRatePlanQuery);
          System.debug('RatePlanResult'+RatePlanResult);
                
         Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(ratePlanResult);
         List<Object> ratePlanRecords = (List<Object>) m.get('records');
         
         If (ratePlanRecords.size() > 0){      
        
           for (Object rec : ratePlanRecords) {
           Map<String, Object> ratePlanMap = (Map<String, Object>) rec;
              ratePlanId =  (String)ratePlanMap.get('Id'); 
                 
              }   
         }
         
    If (!String.IsBlank(ratePlanId)) {
      String ratePlanChargeQuery =  'SELECT Id,Name,ProductRatePlanChargeId,ChargeModel,ChargedThroughDate,EffectiveEndDate,EffectiveStartDate FROM RatePlanCharge WHERE RatePlanId=\''+ratePlanId+'\'';  
    
    String ratePlanChargeResult = SSZuoraUtil.getRestQueryResult(ratePlanChargeQuery);
        Map<String, Object> r = (Map<String, Object>) JSON.deserializeUntyped(ratePlanChargeResult);
         List<Object> ratePlanChargeRecords = (List<Object>) r.get('records');
         
         If (ratePlanChargeRecords.size() > 0){      
        
           for (Object rec : ratePlanChargeRecords) {
           Map<String, Object> ratePlanChargeMap = (Map<String, Object>) rec;
              nextInvoiceDate= (Date)ratePlanChargeMap.get('ChargedThroughDate');
              }   
         } 
        
    }        
         } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_RESTQUERY_CALLOUT);
        } 
     return nextInvoiceDate;
    }
    

}