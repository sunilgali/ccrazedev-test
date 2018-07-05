global class SSZuoraReactivationUtil {
global Static SSBillingSubscriptionModel reactivateSubscription (String ccSubscriptionId, String billingSubscriptionId,String billingAccountId,DateTime reactivationDate,String zuoraServiceUrl,String userName, String password, 
                                      String zuoraVersion,String HTTPMethod){
         SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
         SSZuoraUtil.ProductRatePlanJSON productjson = new SSZuoraUtil.ProductRatePlanJSON();
         List<SSZuoraUtil.ProductRatePlanJSON> productjsonLst= new List<SSZuoraUtil.ProductRatePlanJSON>();
                                    
           List<SSBillingSubscriptionModel.subscriptionModel> subModelList = new List<SSBillingSubscriptionModel.subscriptionModel>();
           String termPeriodType;
           Integer initialTerm;
           Boolean autoRenew;
           String productSubscriptionType;
           String bundleSku;
           String bundleName;
           String bundleInstanceId;                                          
           
         
         ccrz__E_Subscription__c ccSubscription = [SELECT ID, Name, ccrz__SubscriptionProduct__r.name, ccrz__SubscriptionProduct__r.ccrz__SKU__c,
                    ccrz__SubscriptionProduct__r.ID, ccrz__Storefront__c, ccrz__SPTInstallmentFrequencyUOM__c, 
                    ccrz__SPTInstallmentFrequency__c, ccrz__SPTInstallmentCount__c, ccrz__CurrencyISOCode__c, ccrz__AutoRenew__c,
                    ccrz__SubscriptionProduct__r.product_subscription_type__c,ccrz__CCOrder__r.Billing_Account_ID__c, Billing_Subscription_ID__c, 
                    Subscription_End_Date__c, Subscription_Event__c,ccrz__CCOrderItem__r.Id,ccrz__Quantity__c  FROM ccrz__E_Subscription__c WHERE Id =: ccSubscriptionId]; 
           
           termPeriodType = ccSubscription.ccrz__SPTInstallmentFrequencyUOM__c;
           initialTerm =  Integer.valueOf(ccSubscription.ccrz__SPTInstallmentCount__c);
           autoRenew = ccSubscription.ccrz__AutoRenew__c;
           productSubscriptionType = ccSubscription.ccrz__SubscriptionProduct__r.product_subscription_type__c; 
           
                                          
    
     Boolean isProductBundle= SSProductHelper.isProductBundle(ccSubscription.ccrz__SubscriptionProduct__r.ccrz__SKU__c);
     If(isProductBundle){
         bundleSku = ccSubscription.ccrz__SubscriptionProduct__r.ccrz__SKU__c;
         bundleName = ccSubscription.ccrz__SubscriptionProduct__r.Name;
     List<ccrz__E_OrderItem__c> ccOrderItem = [SELECT ID,Name,ccrz__Product__r.Id,ccrz__Product__r.ccrz__SKU__c,ccrz__Product__r.name,ccrz__Product__r.product_subscription_type__c,ccrz__Quantity__c FROM ccrz__E_OrderItem__c WHERE ccrz__ParentOrderItem__r.id =:ccSubscription.ccrz__CCOrderItem__r.Id];                                
       System.debug('For bundled Product'+ ccOrderItem);
         for(ccrz__E_OrderItem__c ccOrder:ccOrderItem){
           productjson =  SSZuoraUtil.getSubscripionProductInfo (ccOrder.ccrz__Product__r.ccrz__SKU__c, termPeriodType, '','',
                                                  '', '', ccOrder.ccrz__Product__r.Id,String.ValueOf(ccOrder.ccrz__Quantity__c),bundleSku, bundleName, '');
          productjsonLst.add(productjson);
         }
     }  else{                                        
    productjson =  SSZuoraUtil.getSubscripionProductInfo (ccSubscription.ccrz__SubscriptionProduct__r.ccrz__SKU__c, termPeriodType, '','',
                                                  '', '', ccSubscription.ccrz__SubscriptionProduct__r.Id,String.ValueOf(ccSubscription.ccrz__Quantity__c) ,'','', '');
    productjsonLst.add(productjson);  
         }
                                          
         Date nextInvoiceDate =  SSZuoraCancelUtil.getZuoraNextInvoiceDate(billingSubscriptionId);                                  
        If (nextInvoiceDate==null ){
          reactivationDate =SYstem.Today();           
              } 
        else{
             reactivationDate =  nextInvoiceDate;
                                          }
                                          
                //Check for Coupons at the time of reactivation -- Right now no coupons are assigned at reactivation                          
                   //String couponType,String couponLength,
         //      String couponPeriod, String discountAmount, String ccProductId, String quantity,String bundleSku, String bundleDescription, String bundleInstanceId
                                    
    String queryResult = SSZuoraUtil.getRestCreateSubscriptionResult(billingAccountId, reactivationDate,productSubscriptionType,initialTerm,termPeriodType,
                                                  autoRenew,productjsonLst);
      JSONParser parser = JSON.createParser(queryResult);
           SSBillingSubscriptionModel.subscriptionModel subModel = new SSBillingSubscriptionModel.subscriptionModel();
           while (parser.nextToken() != null) {
          parser.nextValue();
          String tokenName = parser.getCurrentName();
          String tokenValue = parser.getText();
          if (tokenName != null) {
          if (tokenName.equals('subscriptionId')) {
                    subModel.billingSubscriptionId = String.valueOf(tokenValue);
                         }
                         if (tokenName.equals('subscriptionNumber')) {
                            subModel.billingSubscriptionNumber = String.valueOf(tokenValue);
                         }               
                     }
          
             billingModel.billingAccountId = billingAccountId;
             subModel.billingStartDate = reactivationDate;
             subModel.subscriptionStatus = 'Active';
             subModel.billingProductSku = ccSubscription.ccrz__SubscriptionProduct__r.ccrz__SKU__c;
              if (ccSubscription.ccrz__SubscriptionProduct__r.product_subscription_type__c == 'TERMED' && ccSubscription.ccrz__AutoRenew__c == false ){
             subModel.billingSubscriptionEndDate = SSZuoraUtil.getSubscriptionEndDate(reactivationDate,ccSubscription.ccrz__SPTInstallmentFrequencyUOM__c,Integer.ValueOf(ccSubscription.ccrz__SPTInstallmentCount__c));
                 }
            else {
                subModel.billingSubscriptionEndDate = DateTime.valueOf(SSSubscription.SUBSCRIPTION_TERM_EVERGREEN);
            }
            subModelList.add(subModel);
             System.debug('subModelList'+subModelList);
             billingModel.subscriptionMap.put(ccSubscription.ccrz__SubscriptionProduct__r.ccrz__SKU__c,subModelList);        
                                      }
         return billingModel;
                                      }

}