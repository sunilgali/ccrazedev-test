global class SSZuoraRegradeUtil {
    
   
   global Static SSBillingSubscriptionModel regradeSubscription (String cartId,String billingSubscriptionId,String billingAccountId,DateTime regradeEffectiveDate,
                                                          String zuoraServiceUrl ,String username,String password,String zuoraVersion,String httpMethod){
            SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
           SSBillingSubscriptionModel.subscriptionModel subModel = new SSBillingSubscriptionModel.subscriptionModel();
           List<SSBillingSubscriptionModel.subscriptionModel> subModelList = new List<SSBillingSubscriptionModel.subscriptionModel>();  
           billingModel.subscriptionMap = new  Map<String,List<SSBillingSubscriptionModel.subscriptionModel>>();                                                   
           String TermType;
           Integer initialTerm;
           String termPeriodType;
           Boolean autoRenew;
           String productSku;                                                   
           List<ProductRegradeRatePlanJSON> productLstJson;
              zuoraServiceUrl = zuoraServiceUrl+billingSubscriptionId;
           HttpRequest req = SSZuoraRequestsUtil.getZuoraRequestHeader(zuoraServiceUrl, userName, password,zuoraVersion,httpMethod);
           List<ccrz__E_CartItem__c> cartItems = [SELECT ccrz__Product__r.ccrz__SKU__c,ccrz__Product__r.Id,ccrz__Product__r.product_subscription_type__c, ccrz__Coupon__r.ccrz__CouponType__c,ccrz__Coupon__r.ccrz__DiscountAmount__c,ccrz__Quantity__c,ccrz__SubProdTerm__r.ccrz__InstallmentCount__c,ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c,ccrz__Coupon__r.Period__c,ccrz__Coupon__r.Length__c,Bundle_Product_Description__c,Bundle_Product_SKU__c,Tier_Description__c,ccrz__SubProdTerm__r.ccrz__AutoRenew__c FROM ccrz__E_CartItem__c where ccrz__Cart__r.ccrz__EncryptedId__c =: cartId and ccrz__cartItemType__c= 'Major' and ccrz__ProductType__c='Product'] ;
        If(cartItems.size()!=0){
         for (ccrz__E_CartItem__c cartItem: cartItems) {
        Boolean isTrailProduct = SSProductHelper.isTrailProduct(cartItem.ccrz__Product__r.ccrz__SKU__c);
             If (!isTrailProduct) {     
         productLstJson = new List<ProductRegradeRatePlanJSON>();        
        productLstJson.add(getSubscripionProductInfo (cartItem.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c, cartItem.ccrz__Coupon__r.ccrz__CouponType__c,String.valueOf(cartItem.ccrz__Coupon__r.Length__c),cartItem.ccrz__Coupon__r.Period__c, String.valueOf(cartItem.ccrz__Coupon__r.ccrz__DiscountAmount__c), cartItem.ccrz__Product__r.Id,String.valueof(cartItem.ccrz__Quantity__c),'','','',regradeEffectiveDate));
            termType =String.ValueOf(cartItem.ccrz__Product__r.product_subscription_type__c);
            initialTerm=  Integer.ValueOf(cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c);
            termPeriodType= cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c;
             autoRenew = cartItem.ccrz__SubProdTerm__r.ccrz__AutoRenew__c;  
             productSKu =  cartItem.ccrz__Product__r.ccrz__SKU__c;
             }
           }
        }
            
        //Check for Bundle Cart    
       List<ccrz__E_CartItem__c> bundlecartItems = [SELECT ccrz__Product__r.ccrz__SKU__c,ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c,ccrz__Product__r.Id,ccrz__ParentCartItem__r.ccrz__Product__r.Name,ccrz__ParentCartItem__r.ccrz__Product__r.product_subscription_type__c, ccrz__Coupon__r.ccrz__CouponType__c,ccrz__Coupon__r.ccrz__DiscountAmount__c,ccrz__Quantity__c,ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c,ccrz__Coupon__r.Period__c,ccrz__Coupon__r.Length__c,
                                                   Bundle_Product_Description__c,Bundle_Product_SKU__c,Tier_Description__c,ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c,ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__AutoRenew__c,ccrz__ParentCartItem__r.ccrz__Coupon__r.ccrz__CouponType__c,ccrz__ParentCartItem__r.ccrz__Coupon__r.Period__c,ccrz__ParentCartItem__r.ccrz__Coupon__r.Length__c,ccrz__ParentCartItem__r.ccrz__Coupon__r.ccrz__DiscountAmount__c FROM ccrz__E_CartItem__c where ccrz__Cart__r.ccrz__EncryptedId__c =: cartId and ccrz__cartItemType__c= 'Minor' and ccrz__ParentCartItem__c!=null];  
        If(bundlecartItems.size()!=0){
        productLstJson = new List<ProductRegradeRatePlanJSON>();
         for (ccrz__E_CartItem__c cartItem: bundlecartItems) {
             If (cartItem.ccrz__ParentCartItem__r.ccrz__Coupon__r.ccrz__CouponType__c != null){
                productLstJson.add(getSubscripionProductInfo (cartItem.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c, cartItem.ccrz__ParentCartItem__r.ccrz__Coupon__r.ccrz__CouponType__c,String.valueOf(cartItem.ccrz__ParentCartItem__r.ccrz__Coupon__r.Length__c),cartItem.ccrz__ParentCartItem__r.ccrz__Coupon__r.Period__c, String.valueOf(cartItem.ccrz__ParentCartItem__r.ccrz__Coupon__r.ccrz__DiscountAmount__c), cartItem.ccrz__Product__r.Id,String.valueof(cartItem.ccrz__Quantity__c),cartItem.ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__ParentCartItem__r.ccrz__Product__r.Name,cartId,regradeEffectiveDate));     
             
            termType =String.ValueOf(bundlecartItems[0].ccrz__ParentCartItem__r.ccrz__Product__r.product_subscription_type__c);
            initialTerm=  Integer.ValueOf(bundlecartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c);
            termPeriodType= bundlecartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c;
             autoRenew = bundleCartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__AutoRenew__c; 
              productSKu =  bundleCartItems[0].ccrz__Product__r.ccrz__SKU__c;    

             }
             else{
        productLstJson.add(getSubscripionProductInfo (cartItem.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c, cartItem.ccrz__Coupon__r.ccrz__CouponType__c,String.valueOf(cartItem.ccrz__Coupon__r.Length__c),cartItem.ccrz__Coupon__r.Period__c, String.valueOf(cartItem.ccrz__Coupon__r.ccrz__DiscountAmount__c), cartItem.ccrz__Product__r.Id,String.valueof(cartItem.ccrz__Quantity__c),cartItem.ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__ParentCartItem__r.ccrz__Product__r.Name,cartId,regradeEffectiveDate));
       
            termType =String.ValueOf(bundlecartItems[0].ccrz__ParentCartItem__r.ccrz__Product__r.product_subscription_type__c);
            initialTerm=  Integer.ValueOf(bundlecartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c);
            termPeriodType= bundlecartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c;
             autoRenew = bundleCartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__AutoRenew__c; 
             productSKu =  bundleCartItems[0].ccrz__Product__r.ccrz__SKU__c;
     
                 }
             }
            }
      List<RatePlanJSON> ratePlanJsonLst = getExistingSubscriptionInfo(billingSubscriptionId,regradeEffectiveDate);
         String body = SSZuoraRequestsUtil.getRegradeSubscriptionRequestBody(termType,initialTerm,termPeriodType,autoRenew,productLstJson,ratePlanJsonLst);
                                                              
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
                
             billingModel.billingAccountId = billingAccountId;
             subModel.billingStartDate = regradeEffectiveDate;
             subModel.subscriptionStatus = 'Active';
           subModel.billingProductSku =  productSku;
            if (termType == 'TERMED' && autoRenew == false) {
             subModel.billingSubscriptionEndDate = SSZuoraUtil.getSubscriptionEndDate(regradeEffectiveDate,termPeriodType, initialTerm);
                 }
            else {
                subModel.billingSubscriptionEndDate = DateTime.valueOf(SSSubscription.SUBSCRIPTION_TERM_EVERGREEN);
            }	
             subModel.billingProductSku = productSku;
             subModelList.add(subModel);
             System.debug('subModelList'+subModelList);
           
              billingModel.subscriptionMap.put(productSku,subModelList);  
       
                }
           else {
                System.debug('Error retrieving subscription ' + statusCode);
                System.debug('Error retrieving subscription response ' + res.getBody());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_REGRADE_ZUORA_SUBSCRIPTION_ERROR);
            }
            }      
        catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_REGRADE_SUBSCRIPTION_CALLOUT);
        }                                                                        
                                                            
         //   String body = SSZuoraUtil.getRegradeSubscriptionRequestBody(cancellationPolicy,cancellationDate);  
                    System.debug('Regrade Subscription  from Zuora'+billingModel);                                         
                                                            return billingModel;
                                                        }
    
   
  global static ProductRegradeRatePlanJSON getSubscripionProductInfo (String productSku, String subscriptionFrequency, String couponType,String couponLength,
                                                  String couponPeriod, String discountAmount, String ccProductId, String quantity,String bundleSku, String bundleDescription, String bundleInstanceId,DateTime subscriptionStartDate) {
      
      //productsku =cartItem.ccrz__Product__r.ccrz__SKU__c
      //subscriptionFrequency = cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c
      //couponType = cartItem.ccrz__Coupon__r.ccrz__CouponType__c
      //couponLength = cartItem.ccrz__Coupon__r.Length__c
      //couponPeriod = cartItem.ccrz__Coupon__r.Period__c
      //discountAmount =cartItem.ccrz__Coupon__r.ccrz__DiscountAmount__c
      //quantity=cartItem.ccrz__Quantity__c
      //ccProductId = cartItem.ccrz__Product__r.Id
      
      ProductRegradeRatePlanJSON rpjson = new ProductRegradeRatePlanJSON();   
      String endDateCondition;
      String productId;
      String productRatePlanId;   
        //  System.debug('cartItem.ccrz__Product__r.ccrz__SKU__c'+productSku);      
           //Fetch the Product Id based on the SKU 
         try {  
             
         String zProductQuery ='select Id,Name from Product where SKU=\''+productSku+'\'';
          System.debug('Regrade Query'+zProductQuery);       
         String productResult = SSZuoraUtil.getRestQueryResult(zProductQuery);
          System.debug('productResult'+productResult);
                
         Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(productResult);
         List<Object> productRecords = (List<Object>) m.get('records');
         
         If (productRecords.size() > 0){      
        
           for (Object rec : productRecords) {
           Map<String, Object> productMap = (Map<String, Object>) rec;
              productId =  (String)productMap.get('Id'); 
              } 
             
         /*   // If(!String.(cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c)){
              String strNameSupport = '%'+subscriptionFrequency+ ' [Promo:'+couponType+']';
            //  }
                 If (String.IsBlank(couponType)){
             strNameSupport = '%'+subscriptionFrequency+ ' [Promo:None]';  
              } */
             
             If (String.IsBlank(couponType)){
             couponType = 'None';  
              } 
                     
              If ((!String.IsBlank(couponLength)) && (!String.IsBlank(couponPeriod))) {
               endDateCondition = 'Fixed_Period';
               couponPeriod = couponPeriod +'s';
              }
          
          //Fetch ProductRatePlan based on ProductId 
        
          String zProductRatePlanQuery ='select Id,Name from ProductRatePlan where Productid=\''+productId +'\' and BillingFrequency__c=\''+subscriptionFrequency +'\' and PromotionType__c=\''+couponType +'\'';
          String productRatePlanResult = SSZuoraUtil.getRestQueryResult(zProductRatePlanQuery);
           System.debug('userName'+productRatePlanResult);      
           Map<String, Object> productRatePlan = (Map<String, Object>) JSON.deserializeUntyped(productRatePlanResult);
           List<Object> productRatePlanRecords = (List<Object>) productRatePlan.get('records');      
            
           If (productRatePlanRecords.size() > 0){            
           for (Object rec : productRatePlanRecords) {
           Map<String, Object> productRatePlanMap = (Map<String, Object>) rec;
              productRatePlanId =  (String)productRatePlanMap.get('Id'); 
              } 
               
            //Fetch ProductRatePlanCharge Info based on a ProductRatePlan
            List<Map<String,Object>> chargeList =new  List<Map<String,Object>>();
            rpjson.productRatePlanId = productRatePlanId;
            rpjson.contractEffectiveDate =subscriptionStartDate;  
            String  zProductRatePlanChargeQuery ='select Id,Name,UOM,ChargeModel from ProductRatePlanCharge where ProductRatePlanid=\''+productRatePlanId+'\' ';
            String productRatePlanChargeResult = SSZuoraUtil.getRestQueryResult(zProductRatePlanChargeQuery);
            
           Map<String, Object> productRatePlanCharge = (Map<String, Object>) JSON.deserializeUntyped(productRatePlanChargeResult);
           List<Object> productRatePlanChargeRecords = (List<Object>) productRatePlanCharge.get('records');      
            
           If (productRatePlanChargeRecords.size() > 0){            
           for (Object rec : productRatePlanChargeRecords) {
           Map<String, Object> productRatePlanChargeMap = (Map<String, Object>) rec;
           Map<String,Object> chargeJson= new  Map<String,Object>();  
            String chargeModel=(String)productRatePlanChargeMap.get('ChargeModel');
            System.debug('SSproductHelper.isTierPriced(ccProductId)'+SSproductHelper.isTierPriced(ccProductId));
            if(chargeModel.equalsIgnoreCase('Discount-Fixed Amount')){
                    chargeJson.put('productRatePlanChargeId',(String)productRatePlanChargeMap.get('Id'));
                    chargeJson.put('discountAmount',discountAmount);
                    // chargejson.put('applyDiscountTo',pr.strapplyDiscountTo);
                    chargeJson.put('endDateCondition',endDateCondition);
                    chargeJson.put('upToPeriods',couponLength);
                    chargeJson.put('upToPeriodsType',couponPeriod);
                    chargejson.put('CCDynamicKit_Description__c',bundleDescription); 
                    chargejson.put('CCDynamicKit_SKU__c',bundleSku);
                    chargejson.put('CCDynamicKit_InstanceId__c',bundleInstanceId);	    
                         
            } 
               else if(chargeModel.equalsIgnoreCase('Discount-Percentage')){
                      chargeJson.put('productRatePlanChargeId',(String)productRatePlanChargeMap.get('Id'));
                      chargejson.put('discountPercentage',discountAmount);
                     // chargejson.put('applyDiscountTo',pr.strapplyDiscountTo); 
                      chargejson.put('endDateCondition', endDateCondition);
                      chargejson.put('upToPeriods', couponLength);
                      chargejson.put('upToPeriodsType', couponPeriod); 
                     chargejson.put('CCDynamicKit_Description__c',bundleDescription); 
                    chargejson.put('CCDynamicKit_SKU__c',bundleSku);
                    chargejson.put('CCDynamicKit_InstanceId__c',bundleInstanceId);	 
                } 
               else if(SSproductHelper.isTierPriced(ccProductId) == true){
                     chargejson.put('productRatePlanChargeId', (String)productRatePlanChargeMap.get('Id'));
                     chargejson.put('quantity',quantity); 
                     chargejson.put('CCDynamicKit_Description__c',bundleDescription); 
                    chargejson.put('CCDynamicKit_SKU__c',bundleSku);
                    chargejson.put('CCDynamicKit_InstanceId__c',bundleInstanceId);	 
                    }
               else{
                    chargejson.put('productRatePlanChargeId',(String)productRatePlanChargeMap.get('Id')); 
                   // chargejson.put('price',9.1);
                    chargejson.put('CCDynamicKit_Description__c',bundleDescription); 
                    chargejson.put('CCDynamicKit_SKU__c',bundleSku);
                    chargejson.put('CCDynamicKit_InstanceId__c',bundleInstanceId);	 
                    }
			   chargeList.add(chargejson);	
                }                
            }
                
          rpjson.chargeOverrides = chargeList;            
          
           }  
         }
         else {
           //   throw new SSSubscriptionException(SSSubscriptionException.NO_ZUORAPRODUCT_FOUND);
              } 
       
            } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_RESTQUERY_CALLOUT);
        } 
   return rpjson;
}
       

  global static List<RatePlanJSON> getExistingSubscriptionInfo(String billngSubscriptionId,DateTime regradeEffectiveDate){
    List<RatePlanJSON> rateplanlst = new List<RatePlanJSON>();
     String zRatePlanQuery = 'Select Id,ProductRatePlanId from RatePlan where SubscriptionId=\''+billngSubscriptionId+'\' '; //May need to filter the rateplanbased on the ammendmenttype as well 
        String ratePlanResult = SSZuoraUtil.getRestQueryResult(zRatePlanQuery);
          System.debug('ratePlanResult'+ratePlanResult);
                
         Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(ratePlanResult);
         List<Object> ratePlanRecords = (List<Object>) m.get('records');
         
         If (ratePlanRecords.size() > 0){      
        
           for (Object rec : ratePlanRecords) {
           Map<String, Object> ratePlanMap = (Map<String, Object>) rec;
             RatePlanJSON rateplan = new RatePlanJSON();
              rateplan.ratePlanId = (String)ratePlanMap.get('Id'); 
              rateplan.contractEffectiveDate = regradeEffectiveDate;
              rateplanlst.add(rateplan); 
         //     productId =  (String)productMap.get('Id'); 
              }
             }
			  
    return rateplanlst;    
    }    
 
  global class ProductRegradeRatePlanJSON {
       global String productRatePlanId {get; set;}
       global List<Map<String,Object>> chargeOverrides {get; set;} 
      global DateTime contractEffectiveDate {get; set;}
                 }
       
    global class RatePlanJSON  {
        public String ratePlanId {get; set;}
        public DateTime contractEffectiveDate {get; set;}    
    }    
}