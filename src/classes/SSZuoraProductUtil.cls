global class SSZuoraProductUtil {
    @AuraEnabled
    global Static Boolean SyncZuoraWithCCProduct (String productId){
        Boolean success = false;
         String zuoraProductRatePlanId;
        String zuoraProductRatePlanChargeId;
        String chargeModel;
        String billingPeriod;
        String productRatePlanName;
        String productRatePlanChargeName;
        String zuoraProductId;
        List<String> couponTypes = new List<String>{'None','Percentage','Price','Absolute'};
        try{
        ccrz__E_Product__c productInfo = [SELECT Id,Name,ccrz__SKU__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ShortDesc__c,Billing_Product_ID__c from ccrz__E_Product__c where Id=:productId];
       zuoraProductId = createZuoraProduct (productInfo.ccrz__SKU__c,productInfo.Name, productInfo.ccrz__ShortDesc__c, productInfo.ccrz__StartDate__c, productInfo.ccrz__EndDate__c);
            If(!String.IsBlank(zuoraProductId)){
            List<ccrz__E_SubProdTerm__c> productsptInfo = [SELECT Id,Name,ccrz__InstallmentFrequencyUOM__c,ccrz__EffectiveStart__c,ccrz__EffectiveEnd__c from ccrz__E_SubProdTerm__c where ccrz__CCProduct__r.Id =:productId];
            
            for (String coupon: CouponTypes){     
       for (ccrz__E_SubProdTerm__c spt :  productsptInfo){
         
       productRatePlanName = spt.Name +' Promo:'+ coupon ;
       System.debug('Coupon'+coupon);     
       System.debug('productRatePlanName'+productRatePlanName);
       System.debug('billingFrequency'+spt.ccrz__InstallmentFrequencyUOM__c);
       zuoraProductRatePlanId = createZuoraProductRatePlan (zuoraProductId,productRatePlanName, '', date.newinstance(spt.ccrz__EffectiveStart__c.year(), spt.ccrz__EffectiveStart__c.month(), spt.ccrz__EffectiveStart__c.day()), date.newinstance(spt.ccrz__EffectiveEnd__c.year(), spt.ccrz__EffectiveEnd__c.month(), spt.ccrz__EffectiveEnd__c.day()), coupon, spt.ccrz__InstallmentFrequencyUOM__c);
       ccrz__E_PriceListItem__c priceInfo = [SELECT Id, ccrz__Price__c,ccrz__PricingTiers__c, ccrz__RecurringPrice__c  from ccrz__E_PriceListItem__c where ccrz__Product__r.Id =:productId and ccrz__SubProdTerm__r.Id =:spt.Id and ccrz__RecurringPrice__c = true];
       If (!String.IsBlank(priceInfo.ccrz__PricingTiers__c)){
             chargeModel = 'Volume Pricing';             
           }else {
             chargeModel = 'Flat Fee Pricing';
           }
           If (spt.ccrz__InstallmentFrequencyUOM__c.equalsIgnoreCase('Monthly')){
              billingPeriod = 'Month';
           }else If (spt.ccrz__InstallmentFrequencyUOM__c.equalsIgnoreCase('Yearly')){
               billingPeriod = 'Annual';  
           }
           System.debug('zuoraProductRatePlanId'+zuoraProductRatePlanId);
           zuoraProductRatePlanChargeId = createZuoraProductRatePlanCharge (zuoraProductRatePlanId,'Deferred Revenue','DefaultFromCustomer', billingPeriod, chargeModel, 'Recurring',
                                                          'Deferred Revenue', productInfo.Name, 'Accounts Receivable', 'ContractEffective', false,priceInfo.ccrz__Price__c);
           If(coupon == 'Percentage'){
               productRatePlanChargeName = productInfo.Name+' Discount '+Coupon;
                zuoraProductRatePlanChargeId = createZuoraProductRatePlanDiscountCharge(zuoraProductRatePlanId,productRatePlanChargeName, 'DefaultFromCustomer',billingPeriod, 'AlignToTermStart','ContractEffective','Discount-Percentage','RECURRING','Recurring','subscription',1,0.0); 
           } else If(coupon == 'Price' || coupon == 'Absolute'){
               
             productRatePlanChargeName = productInfo.Name+' Discount '+Coupon;
                zuoraProductRatePlanChargeId = createZuoraProductRatePlanDiscountCharge(zuoraProductRatePlanId,productRatePlanChargeName, 'DefaultFromCustomer',billingPeriod, 'AlignToTermStart','ContractEffective','Discount-Fixed Amount','RECURRING','Recurring','subscription',1,0.0);    
           }
          
        success = true;
         
       }
            }}
                else{
                    success = false;  
                }
         } catch(Exception ex) {
          success = false;  
        }
          ccrz__E_Product__c ccproductInfo = [SELECT Id,Name,ccrz__SKU__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ShortDesc__c,Billing_Product_ID__c from ccrz__E_Product__c where Id=:productId];
         ccproductInfo.Billing_Product_ID__c =zuoraProductId;
        update ccproductInfo;  
        return success;
        
    }
    
    global Static String createZuoraProduct (String sku,String name, String description, Date effectiveStartDate, Date effectiveEndDate){
    String productId;   
    Callout_Configuration__mdt[] zuoraProductCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c,Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCreateProduct'];                                                                
    HttpRequest req = SSZuoraRequestsUtil.getZuoraRequestHeader(zuoraProductCalloutConfig[0].Endpoint_URL__c, zuoraProductCalloutConfig[0].Username__c, zuoraProductCalloutConfig[0].Password__c,zuoraProductCalloutConfig[0].Version__c,zuoraProductCalloutConfig[0].HTTP_Method__c);
    Map<String, Object> zuoraProductRequest = SSZuoraProductModel.zuoraProduct(sku,name, description,effectiveStartDate, effectiveEndDate ); 
    String body = JSON.serialize(zuoraProductRequest);
    System.debug('Product Request Body'+ body);    
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

                String createSuProductResponse = res.getBody();
             JSONParser parser = JSON.createParser(createSuProductResponse);
                while (parser.nextToken() != null) {
                    parser.nextValue();
                    String tokenName = parser.getCurrentName();
                    String tokenValue = parser.getText();
                     if (tokenName != null) {
                         if (tokenName.equals('Id')) {
                           productId  = String.valueOf(tokenValue);
                         }
             
                     }  
                     }

        
            } 
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_RESTQUERY_CALLOUT);
        }catch(Exception e) {
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATING_PRODUCT);
        }  
        return productId;       
}
    
    // Product Id retrieved from Create Product
    global Static String createZuoraProductRatePlan (String productId,String name, String description, Date effectiveStartDate, Date effectiveEndDate, String promotionType, String billingFrequency){
   String productRatePlanId;   
    Callout_Configuration__mdt[] zuoraProductRatePlanCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c,Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCreateProductRatePlan'];                                                                
    HttpRequest req = SSZuoraRequestsUtil.getZuoraRequestHeader(zuoraProductRatePlanCalloutConfig[0].Endpoint_URL__c, zuoraProductRatePlanCalloutConfig[0].Username__c, zuoraProductRatePlanCalloutConfig[0].Password__c,zuoraProductRatePlanCalloutConfig[0].Version__c,zuoraProductRatePlanCalloutConfig[0].HTTP_Method__c);
    Map<String, Object> zuoraProductRatePlanRequest = SSZuoraProductModel.zuoraProductRatePlan(productId,name, description,effectiveEndDate, effectiveStartDate,promotionType,billingFrequency); 
    String body = JSON.serialize(zuoraProductRatePlanRequest);
    System.debug('Product Request Body'+ body);    
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

                String createSuProductResponse = res.getBody();
             JSONParser parser = JSON.createParser(createSuProductResponse);
                while (parser.nextToken() != null) {
                    parser.nextValue();
                    String tokenName = parser.getCurrentName();
                    String tokenValue = parser.getText();
                     if (tokenName != null) {
                         if (tokenName.equals('Id')) {
                           productRatePlanId  = String.valueOf(tokenValue);
                         }
             
                     }  
                     }      
            } 
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_RESTQUERY_CALLOUT);
        } 
        catch(Exception e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATING_PRODUCTRATEPLAN);
        } 
        return productRatePlanId; 
}
    
    global Static String createZuoraProductRatePlanCharge (String productRatePlanId,String accountingCode,String billCycleType, String billingPeriod, String chargeModel, String chargeType,
                                                           String deferredRevenueAccount, String name, String recognizedRevenueAccount, String triggerEvent, Boolean useDiscountSpecificAccountingCode,Decimal price){
    String productRatePlanChargeId;   
    Callout_Configuration__mdt[] zuoraProductRatePlanCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c,Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCreateProductRatePlanCharge'];                                                                
    HttpRequest req = SSZuoraRequestsUtil.getZuoraRequestHeader(zuoraProductRatePlanCalloutConfig[0].Endpoint_URL__c, zuoraProductRatePlanCalloutConfig[0].Username__c, zuoraProductRatePlanCalloutConfig[0].Password__c,zuoraProductRatePlanCalloutConfig[0].Version__c,zuoraProductRatePlanCalloutConfig[0].HTTP_Method__c);
   Map<String, Object> zuoraProductRatePlanChargeRequest = SSZuoraProductModel.zuoraProductRatePlanCharge(productRatePlanId,accountingCode, billCycleType,billingPeriod, chargeModel,chargeType,deferredRevenueAccount,name,recognizedRevenueAccount,triggerEvent,useDiscountSpecificAccountingCode,price); 
  System.debug(zuoraProductRatePlanChargeRequest);
    String body = JSON.serialize(zuoraProductRatePlanChargeRequest);
   
    System.debug('Product Request Body'+ body);    
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

                String createSuProductResponse = res.getBody();
             JSONParser parser = JSON.createParser(createSuProductResponse);
                while (parser.nextToken() != null) {
                    parser.nextValue();
                    String tokenName = parser.getCurrentName();
                    String tokenValue = parser.getText();
                     if (tokenName != null) {
                         if (tokenName.equals('Id')) {
                           productRatePlanChargeId  = String.valueOf(tokenValue);
                         }
             
                     }  
                     }      
            } 
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_RESTQUERY_CALLOUT);
        } catch(Exception e) {
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATING_PRODUCTRATEPLANCHARGE);
        } 
                                                               
        return productRatePlanChargeId; 
}
    global Static String createZuoraProductRatePlanDiscountCharge (String productRatePlanId,String Name, String billCycleType, String billingPeriod, String BillingPeriodAlignment,String tiggerEvent,String chargeModel, String ApplyDiscountTo,
                                                                   String ChargeType, String discountLevel, Integer UpToPeriods,Decimal Discount ){
    String productRatePlanChargeId;   
    Callout_Configuration__mdt[] zuoraProductRatePlanCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c,Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCreateProductRatePlanCharge'];                                                                
    HttpRequest req = SSZuoraRequestsUtil.getZuoraRequestHeader(zuoraProductRatePlanCalloutConfig[0].Endpoint_URL__c, zuoraProductRatePlanCalloutConfig[0].Username__c, zuoraProductRatePlanCalloutConfig[0].Password__c,zuoraProductRatePlanCalloutConfig[0].Version__c,zuoraProductRatePlanCalloutConfig[0].HTTP_Method__c);
   Map<String, Object> zuoraProductRatePlanChargeRequest = SSZuoraProductModel.zuoraProductRatePlanDiscountCharge(productRatePlanId,Name, billCycleType,billingPeriod, BillingPeriodAlignment,tiggerEvent,chargeModel,ApplyDiscountTo,chargeType,discountLevel,UpToPeriods,Discount); 
  System.debug(zuoraProductRatePlanChargeRequest);
 
   String body = JSON.serialize(zuoraProductRatePlanChargeRequest);
   
    System.debug('Product Request Body'+ body);    
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

                String createSuProductResponse = res.getBody();
             JSONParser parser = JSON.createParser(createSuProductResponse);
                while (parser.nextToken() != null) {
                    parser.nextValue();
                    String tokenName = parser.getCurrentName();
                    String tokenValue = parser.getText();
                     if (tokenName != null) {
                         if (tokenName.equals('Id')) {
                           productRatePlanChargeId  = String.valueOf(tokenValue);
                         }
             
                     }  
                     }      
            } 
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_RESTQUERY_CALLOUT);
        } catch(Exception e) {
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATING_PRODUCTRATEPLANCHARGE);
        } 
                                                               
        return productRatePlanChargeId; 
}
}