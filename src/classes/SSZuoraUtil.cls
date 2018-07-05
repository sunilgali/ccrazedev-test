global class SSZuoraUtil {
      global static SSBillingSubscriptionModel createSubscription(String cartId,SSAccountModel account, SSContactModel contact, DateTime subscriptionStartDate,
                                                  String currencyCode, String locale, String paymentReferenceID,
                                                               String paymentType, SSPaymentDetailsModel paymentDetails, String zuoraServiceUrl,String userName, String password, 
                                                               String zuoraVersion,String HTTPMethod) { 
                                                                   
  SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
  String billingAccountNumber;
  String paymentMethodId;                                                                 
                                                                   
  try {                                                             
   // Create Zuora Account And get the accountId
   billingModel =  SSZuoraUtil.createAccount(account,contact,currencyCode,locale,paymentReferenceID,
                                                        paymentDetails,zuoraServiceUrl,userName,password,zuoraVersion,HTTPMethod);
   System.debug('##BillingModel'+billingModel);                                                                
   //Iterate Over the cartItems and create Individual Subscriptions for all Products, If dynamic Kit create a single
   //subscription for all products within the kit   
    //
    //
    //
    billingAccountNumber = billingModel.billingAccountNumber;
    paymentMethodId = billingModel.paymentMethodId;
       
    billingModel = SSZuoraUtil.createZuoraSubscription(cartId,billingModel.billingAccountId,subscriptionStartDate); 
       
      
      If (!String.IsBlank(billingModel.billingAccountId)){
    Zuora_Billing_Account__c billingAccount = new Zuora_Billing_Account__c();
    billingAccount.name = account.accountName;
    billingAccount.Account__c = account.accountId;
    billingAccount.Billing_Account_Number__c= billingAccountNumber;
    billingAccount.Billing_Account_Id__c = billingModel.billingAccountId;
    billingAccount.PaymentMethodId__c = paymentMethodId;
    insert billingAccount;
      }
      
    System.debug('##BillingModel After subCreation'+billingModel);  
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATE_ZUORA_SUBSCRIPTION_ERROR);
        } 
                
             return billingModel;
        }
      
global Static SSBillingSubscriptionModel createAccount(SSAccountModel account, SSContactModel contact, String currencyCode, String locale, String paymentReferenceID,
                                                        SSPaymentDetailsModel paymentDetails,String zuoraServiceUrl,String userName,String password, String zuoraVersion,string httpMethod){
          SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel(); 
            HttpRequest req = SSZuoraRequestsUtil.getZuoraRequestHeader(zuoraServiceUrl, userName, password,zuoraVersion,httpMethod);
             System.debug('Http Account Create Request'+req);                                               
             System.debug('#####account details in Zuora Util'+account);                                               
             String body = SSZuoraRequestsUtil.getCreateAccountRequestBody(account,contact,
                                currencyCode,locale, paymentReferenceID, paymentDetails); 
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
                String createSubResponse = res.getBody();
                JSONParser parser = JSON.createParser(createSubResponse);
                while (parser.nextToken() != null) {
                    parser.nextValue();
                    String tokenName = parser.getCurrentName();
                    String tokenValue = parser.getText();
                     if (tokenName != null) {
                         if (tokenName.equals('accountNumber')) {
                            billingModel.billingAccountNumber = String.valueOf(tokenValue);
                         }
                         if (tokenName.equals('accountId')) {
                            billingModel.billingaccountId = String.valueOf(tokenValue);
                         }
                         if (tokenName.equals('paymentMethodId')) {
                            billingModel.paymentMethodId = String.valueOf(tokenValue);
                         }
                         
                     }
                }
            }
            else {
                System.debug('Error retrieving subscription ' + statusCode);
                System.debug('Error retrieving subscription response ' + res.getBody());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATE_ZUORA_ACCOUNT_ERROR);
            }
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATE_ACCOUNT_CALLOUT);
        }                                                
                     return billingModel;
                                                            
   }    
    
 global static SSBillingSubscriptionModel createCrossSellSubscription(String cartId, String zuoraAccountId,DateTime subscriptionStartDate) { 
 SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();                                                      
 billingModel = SSZuoraUtil.createZuoraSubscription(cartId,zuoraAccountId,subscriptionStartDate);                                                          
 return billingModel;
        }
   
    
   
    
    global static String getRestQueryResult(String zQuery) {
     
     String queryResult;                                                                    
     Callout_Configuration__mdt[] zuoraQueryCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c,Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraQuery'];                                                                
  //   String   zuoraServiceUrl = zuoraQueryCalloutConfig[0].Endpoint_URL__c;       
      HttpRequest req = SSZuoraRequestsUtil.getZuoraRequestHeader(zuoraQueryCalloutConfig[0].Endpoint_URL__c, zuoraQueryCalloutConfig[0].Username__c, zuoraQueryCalloutConfig[0].Password__c,zuoraQueryCalloutConfig[0].Version__c,zuoraQueryCalloutConfig[0].HTTP_Method__c);                                                         
      String body = SSZuoraRequestsUtil.getzuoraQueryRequestBody(zQuery);    
            System.debug('body'+body);                                                        
      req.setBody(body);                     
      Http http = new Http();
       try {
            HTTPResponse res = null;
            if (!Test.isRunningtest())
                {
                   res = http.send(req); 
                }else{
                }  
            Integer statusCode = res.getStatusCode();
           System.debug('statusCode'+statusCode);
            if (statusCode == 200) {
                 queryResult = res.getBody(); 
            } } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_RESTQUERY_CALLOUT);
        } 
           System.debug('queryResult'+queryResult) ;                                                        
           return queryResult;                                                                   
    }
    
    global static String getRestCreateSubscriptionResult(String zuoraAccountId, DateTime subscriptionStartDate,String termType,Integer initialTerm,String termPeriodType,
                                                  Boolean autoRenew,List<SSZuoraUtil.ProductRatePlanJSON> productInfoLst) {
     
     String queryResult;                                                                    
     Callout_Configuration__mdt[] zuoraQueryCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c,Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCreateSubscription'];                                                                
  //   String   zuoraServiceUrl = zuoraQueryCalloutConfig[0].Endpoint_URL__c;       
      HttpRequest req = SSZuoraRequestsUtil.getZuoraRequestHeader(zuoraQueryCalloutConfig[0].Endpoint_URL__c, zuoraQueryCalloutConfig[0].Username__c, zuoraQueryCalloutConfig[0].Password__c,zuoraQueryCalloutConfig[0].Version__c,zuoraQueryCalloutConfig[0].HTTP_Method__c);                                                         
      String body = SSZuoraRequestsUtil.getCreateSubscriptionRequestBody(zuoraAccountId, subscriptionStartDate,termType,initialTerm,termPeriodType,autoRenew,productInfoLst);  
     System.debug('body'+body);                                              
      req.setBody(body);                     
      Http http = new Http();
       try {
            HTTPResponse res = null;
            if (!Test.isRunningtest())
                {
                   res = http.send(req); 
                }else{
                }  
            Integer statusCode = res.getStatusCode();
           System.debug('statusCode'+statusCode);
            if (statusCode == 200) {
                 queryResult = res.getBody();
            } } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATE_SUBSCRIPTION_CALLOUT);
        } 
           System.debug('queryResult'+queryResult) ;                                                        
           return queryResult;                                                                   
    }    
                                                               
 
 
   
 global Static SSBillingSubscriptionModel createZuoraSubscription (String cartId, String zuoraAccountId,DateTime subscriptionStartDate) {       
    
   //   SSBillingSubscriptionModel billingModellst = new SSBillingSubscriptionModel();
      SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
       billingModel.subscriptionMap = new  Map<String,List<SSBillingSubscriptionModel.subscriptionModel>>();
      String queryResult;  
     try {
        //If product Type is Bundle,Dynamic Kit Process it separately Or are we following cloudcraze implementation or custom implemenattion
        //If two individual products -- create two subscriptions
        //If two producsts with a dynamic sku on them -- create a single subscription
                 
        List<ccrz__E_CartItem__c> cartItems = [SELECT ccrz__Product__r.ccrz__SKU__c,ccrz__Product__r.Id,ccrz__Product__r.product_subscription_type__c, ccrz__Coupon__r.ccrz__CouponType__c,ccrz__Coupon__r.ccrz__DiscountAmount__c,ccrz__Quantity__c,ccrz__SubProdTerm__r.ccrz__InstallmentCount__c,ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c,ccrz__Coupon__r.Period__c,ccrz__Coupon__r.Length__c,Bundle_Product_Description__c,Bundle_Product_SKU__c,Tier_Description__c,ccrz__SubProdTerm__r.ccrz__AutoRenew__c FROM ccrz__E_CartItem__c where ccrz__Cart__r.ccrz__EncryptedId__c =: cartId and ccrz__cartItemType__c= 'Major' and ccrz__ProductType__c='Product'];
        If(cartItems.size()!=0){
         for (ccrz__E_CartItem__c cartItem: cartItems) {
        Boolean isTrailProduct = SSProductHelper.isTrailProduct(cartItem.ccrz__Product__r.ccrz__SKU__c);
             If (!isTrailProduct) {     
        List<ProductRatePlanJSON> productLstJson = new List<ProductRatePlanJSON>(); 
        List<SSBillingSubscriptionModel.subscriptionModel> subModelList = new List<SSBillingSubscriptionModel.subscriptionModel>();       
        productLstJson.add(getSubscripionProductInfo (cartItem.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c, cartItem.ccrz__Coupon__r.ccrz__CouponType__c,String.valueOf(cartItem.ccrz__Coupon__r.Length__c),cartItem.ccrz__Coupon__r.Period__c, String.valueOf(cartItem.ccrz__Coupon__r.ccrz__DiscountAmount__c), cartItem.ccrz__Product__r.Id,String.valueof(cartItem.ccrz__Quantity__c),'','',''));
        queryResult = SSZuoraUtil.getRestCreateSubscriptionResult(zuoraAccountId, subscriptionStartDate,String.ValueOf(cartItem.ccrz__Product__r.product_subscription_type__c),Integer.ValueOf(cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c),cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c,
                                                  cartItem.ccrz__SubProdTerm__r.ccrz__AutoRenew__c,productLstJson);
         System.debug('##BillingModel before subCreation'+queryResult);     
          //   Map<SubscriptionId,queryResult>
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
                }
             billingModel.billingAccountId = zuoraAccountId;
             subModel.billingStartDate = subscriptionStartDate;
             subModel.subscriptionStatus = 'Active';
             subModel.billingProductSku = cartItem.ccrz__Product__r.ccrz__SKU__c;
              if (cartItem.ccrz__Product__r.product_subscription_type__c == 'TERMED' && cartItem.ccrz__SubProdTerm__r.ccrz__AutoRenew__c == false ){
             subModel.billingSubscriptionEndDate = getSubscriptionEndDate(subscriptionStartDate,cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c,Integer.ValueOf(cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c));
                 }
            else {
                subModel.billingSubscriptionEndDate = DateTime.valueOf(SSSubscription.SUBSCRIPTION_TERM_EVERGREEN);
            }
            subModelList.add(subModel);
             System.debug('subModelList'+subModelList);
             billingModel.subscriptionMap.put(cartItem.ccrz__Product__r.ccrz__SKU__c,subModelList);
                 
                 
        
                 
            System.debug('subModelList'+billingModel.subscriptionMap);
         }
        }
        }
       
        List<ccrz__E_CartItem__c> bundlecartItems = [SELECT ccrz__Product__r.ccrz__SKU__c,ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c,ccrz__Product__r.Id,ccrz__ParentCartItem__r.ccrz__Product__r.Name,ccrz__ParentCartItem__r.ccrz__Product__r.product_subscription_type__c, ccrz__Coupon__r.ccrz__CouponType__c,ccrz__Coupon__r.ccrz__DiscountAmount__c,ccrz__Quantity__c,ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c,ccrz__Coupon__r.Period__c,ccrz__Coupon__r.Length__c,
                                                   Bundle_Product_Description__c,Bundle_Product_SKU__c,Tier_Description__c,ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c,ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__AutoRenew__c,ccrz__ParentCartItem__r.ccrz__Coupon__r.ccrz__CouponType__c,ccrz__ParentCartItem__r.ccrz__Coupon__r.Period__c,ccrz__ParentCartItem__r.ccrz__Coupon__r.Length__c,ccrz__ParentCartItem__r.ccrz__Coupon__r.ccrz__DiscountAmount__c FROM ccrz__E_CartItem__c where ccrz__Cart__r.ccrz__EncryptedId__c =: cartId and ccrz__cartItemType__c= 'Minor' and ccrz__ParentCartItem__c!=null];  
        If(bundlecartItems.size()!=0){
        List<ProductRatePlanJSON> bundleproductLstJson = new List<ProductRatePlanJSON>();
         for (ccrz__E_CartItem__c cartItem: bundlecartItems) {
             If (cartItem.ccrz__ParentCartItem__r.ccrz__Coupon__r.ccrz__CouponType__c != null){
                bundleproductLstJson.add(getSubscripionProductInfo (cartItem.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c, cartItem.ccrz__ParentCartItem__r.ccrz__Coupon__r.ccrz__CouponType__c,String.valueOf(cartItem.ccrz__ParentCartItem__r.ccrz__Coupon__r.Length__c),cartItem.ccrz__ParentCartItem__r.ccrz__Coupon__r.Period__c, String.valueOf(cartItem.ccrz__ParentCartItem__r.ccrz__Coupon__r.ccrz__DiscountAmount__c), cartItem.ccrz__Product__r.Id,String.valueof(cartItem.ccrz__Quantity__c),cartItem.ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__ParentCartItem__r.ccrz__Product__r.Name,cartId));     
             }
             else{
        bundleproductLstJson.add(getSubscripionProductInfo (cartItem.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c, cartItem.ccrz__Coupon__r.ccrz__CouponType__c,String.valueOf(cartItem.ccrz__Coupon__r.Length__c),cartItem.ccrz__Coupon__r.Period__c, String.valueOf(cartItem.ccrz__Coupon__r.ccrz__DiscountAmount__c), cartItem.ccrz__Product__r.Id,String.valueof(cartItem.ccrz__Quantity__c),cartItem.ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__ParentCartItem__r.ccrz__Product__r.Name,cartId));
         }
         }
            //Where to get the renewal date, can we get it from subprodterm?
       queryResult = SSZuoraUtil.getRestCreateSubscriptionResult(zuoraAccountId, subscriptionStartDate,String.ValueOf(bundlecartItems[0].ccrz__ParentCartItem__r.ccrz__Product__r.product_subscription_type__c),Integer.ValueOf(bundlecartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c),bundlecartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c,
                                                  bundleCartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__AutoRenew__c,bundleproductLstJson); 
          JSONParser parser = JSON.createParser(queryResult);
            System.debug('##BillingModel before subCreation'+queryResult);  
          SSBillingSubscriptionModel.subscriptionModel subModel = new SSBillingSubscriptionModel.subscriptionModel();
          List<SSBillingSubscriptionModel.subscriptionModel> subModelList = new List<SSBillingSubscriptionModel.subscriptionModel>();  
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
                }
             billingModel.billingAccountId = zuoraAccountId;
             subModel.billingStartDate = subscriptionStartDate;
             subModel.subscriptionStatus = 'Active';
             subModel.billingProductSku =  bundleCartItems[0].ccrz__Product__r.ccrz__SKU__c;
            if (bundleCartItems[0].ccrz__ParentCartItem__r.ccrz__Product__r.product_subscription_type__c == 'TERMED' && bundleCartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__AutoRenew__c == false ){
             subModel.billingSubscriptionEndDate = getSubscriptionEndDate(subscriptionStartDate,bundlecartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c, Integer.ValueOf(bundlecartItems[0].ccrz__ParentCartItem__r.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c));
                 }
            else {
                subModel.billingSubscriptionEndDate = DateTime.valueOf(SSSubscription.SUBSCRIPTION_TERM_EVERGREEN);
            }
             subModelList.add(subModel);
           
              billingModel.subscriptionMap.put(bundleCartItems[0].ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c,subModelList);  
            
  
            
                  }
       
            } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSZuoraException(SSZuoraException.EXCEPTION_CREATE_SUBSCRIPTION_CALLOUT);
        } 
    return billingModel; 
    }
    
    global static ProductRatePlanJSON getSubscripionProductInfo (String productSku, String subscriptionFrequency, String couponType,String couponLength,
                                                  String couponPeriod, String discountAmount, String ccProductId, String quantity,String bundleSku, String bundleDescription, String bundleInstanceId) {
      
      //productsku =cartItem.ccrz__Product__r.ccrz__SKU__c
      //subscriptionFrequency = cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c
      //couponType = cartItem.ccrz__Coupon__r.ccrz__CouponType__c
      //couponLength = cartItem.ccrz__Coupon__r.Length__c
      //couponPeriod = cartItem.ccrz__Coupon__r.Period__c
      //discountAmount =cartItem.ccrz__Coupon__r.ccrz__DiscountAmount__c
      //quantity=cartItem.ccrz__Quantity__c
      //ccProductId = cartItem.ccrz__Product__r.Id
      
      ProductRatePlanJSON rpjson = new ProductRatePlanJSON();   
      String endDateCondition;
      String productId;
      String productRatePlanId;   
        //  System.debug('cartItem.ccrz__Product__r.ccrz__SKU__c'+productSku);      
           //Fetch the Product Id based on the SKU 
         try {  
             
         String zProductQuery ='select Id,Name from Product where SKU=\''+productSku+'\'';
                
         String productResult = getRestQueryResult(zProductQuery);
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
          String productRatePlanResult = getRestQueryResult(zProductRatePlanQuery);
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
             
            String  zProductRatePlanChargeQuery ='select Id,Name,UOM,ChargeModel from ProductRatePlanCharge where ProductRatePlanid=\''+productRatePlanId+'\' ';
            String productRatePlanChargeResult = getRestQueryResult(zProductRatePlanChargeQuery);
            
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
    
 global Static DateTime getSubscriptionEndDate(DateTime subscriptionStartDate,String termType, Integer termCount) {
        DateTime subscriptionEndDate;
       // Date subStartDate =  date.newinstance(subscriptionStartDate.year(), subscriptionStartDate.month(), subscriptionStartDate.day());
        If (termType.equalsIgnoreCase('MONTHLY')) {
        subscriptionEndDate = subscriptionStartDate.addMonths(termCount);
        }
        else If (termType.equalsIgnoreCase('YEARLY')){ 
            subscriptionEndDate = subscriptionStartDate.addYears(termCount);
        }
         else If (termType.equalsIgnoreCase('DAYS')){ 
            subscriptionEndDate = subscriptionStartDate.addDAYS(termCount);
        }
       //  else If (termType.equalsIgnoreCase('WEEKLY')){ 
       //     subscriptionEndDate = subscriptionStartDate.ad
      //  }
        
        return subscriptionEndDate;
        
    }  

    
    global class ProductRatePlanJSON {
       global String productRatePlanId {get; set;}
       global List<Map<String,Object>> chargeOverrides {get; set;} 
                 }
    
    
 
 
}