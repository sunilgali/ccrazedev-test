global class SSZuoraUtilEx {
    
   global static SSBillingSubscriptionModel createSubscription(String cartId,SSAccountModel account, SSContactModel contact, DateTime subscriptionStartDate,
                                                  String currencyCode, String locale, String paymentReferenceID,
                                                               String paymentType, SSPaymentDetailsModel paymentDetails, String zuoraServiceUrl,String userName, String password, 
                                                               String zuoraVersion) { 
  SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
  try {                                                             
   // Create Zuora Account And get the accountId
   billingModel =  SSZuoraUtilEx.createAccount(account,contact,currencyCode,locale,paymentReferenceID,
                                                        paymentDetails,zuoraServiceUrl,userName,password,zuoraVersion);
   System.debug('##BillingModel'+billingModel);                                                                
   //Iterate Over the cartItems and create Individual Subscriptions for all Products, If dynamic Kit create a single
   //subscription for all products within the kit   
    
    billingModel = SSZuoraUtilEx.createZuoraSubscription(cartId,billingModel.billingAccountId,subscriptionStartDate); 
    System.debug('##BillingModel After subCreation'+billingModel);  
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_CREATE_SUBSCRIPTION_ERROR);
        } 
                
             return billingModel;
        }
      
global Static SSBillingSubscriptionModel createAccount(SSAccountModel account, SSContactModel contact, String currencyCode, String locale, String paymentReferenceID,
                                                        SSPaymentDetailsModel paymentDetails,String zuoraServiceUrl,String userName,String password, String zuoraVersion){
          SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel(); 
            HttpRequest req = SSZuoraUtilEx.getZuoraRequestHeader(zuoraServiceUrl, userName, password,zuoraVersion);
             String body = SSZuoraUtilEx.getCreateAccountRequestBody(account,contact,
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
                         
                     }
                }
            }
            else {
                System.debug('Error retrieving subscription ' + statusCode);
                System.debug('Error retrieving subscription response ' + res.getBody());
                throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_CREATE_ACCOUNT_ERROR);
            }
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_CREATE_ACCOUNT_CALLOUT);
        }                                                
                     return billingModel;
                                                            
   }    
    
/* global static SSBillingSubscriptionModel createCrossSellSubscription(String cartId, String zuoraAccountId,DateTime subscriptionStartDate,
                                                  DateTime subscriptionEndDate,String currencyCode,String locale, String zuoraServiceUrl,String userName, String password, 
                                                               String zuoraVersion) { 
   SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();                         
   HttpRequest req = SSZuoraUtil.getZuoraRequestHeader(zuoraServiceUrl, userName, password,zuoraVersion);
  // System.debug('req'+req);
   List<SSZuoraUtil.ProductRatePlanJSON> productInfoLst = SSZuoraUtil.getZuoraProductInfo(cartId);                                                            
    String body = SSZuoraUtil.getZuoraCrossSellSubscriptionRequestBody(zuoraAccountId, subscriptionStartDate,
                                subscriptionEndDate,currencyCode,locale,productInfoLst);
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
                         if (tokenName.equals('subscriptionId')) {
                            billingModel.billingSubscriptionId = String.valueOf(tokenValue);
                         }
                         if (tokenName.equals('subscriptionNumber')) {
                            billingModel.billingSubscriptionId = String.valueOf(tokenValue);
                         }
                           }
                }
            }
            else {
                System.debug('Error retrieving subscription ' + statusCode);
                System.debug('Error retrieving subscription response ' + res.getBody());
                throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_CREATE_SUBSCRIPTION_ERROR);
            }
        } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_CREATE_SUBSCRIPTION_CALLOUT);
        }       
             return billingModel;
        }*/ 
    
global static HttpRequest getZuoraRequestHeader(String zuoraServiceUrl, String userName, String password,String zuoraVersion) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(zuoraServiceUrl);
        System.debug('Setting request header');  
        req.setHeader('content-type', 'application/json');
        req.setHeader('apiAccessKeyId', userName);
        req.setHeader('apiSecretAccessKey', password);
        req.setHeader('zuora-version',zuoraVersion);
        return req;        
    }
    
    global Static String getzuoraQueryRequestBody(String zQuery){
    JSONGenerator gen = JSON.createGenerator(true);    
	gen.writeStartObject();
    gen.writeStringField('queryString', zQuery);    
    gen.writeEndObject();                                                                   
    String jsonS = gen.getAsString();
    return jsonS;           
    }
    
    global static String getRestQueryResult(String zQuery) {
     
     String queryResult;                                                                    
     Callout_Configuration__mdt[] zuoraQueryCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c,Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraQuery_SANDBOX'];                                                                
  //   String   zuoraServiceUrl = zuoraQueryCalloutConfig[0].Endpoint_URL__c;       
      HttpRequest req = SSZuoraUtilEx.getZuoraRequestHeader(zuoraQueryCalloutConfig[0].Endpoint_URL__c, zuoraQueryCalloutConfig[0].Username__c, zuoraQueryCalloutConfig[0].Password__c,zuoraQueryCalloutConfig[0].Version__c);                                                         
      String body = SSZuoraUtilEx.getzuoraQueryRequestBody(zQuery);    
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
                throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_CREATE_SUBSCRIPTION_CALLOUT);
        } 
           System.debug('queryResult'+queryResult) ;                                                        
           return queryResult;                                                                   
    }
    
    global static String getRestCreateSubscriptionResult(String zuoraAccountId, DateTime subscriptionStartDate,String termType,Integer initialTerm, Integer renewalTerm,
                                                  Boolean autoRenew,List<SSZuoraUtilEx.ProductRatePlanJSON> productInfoLst) {
     
     String queryResult;                                                                    
     Callout_Configuration__mdt[] zuoraQueryCalloutConfig = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,Password__c, HTTP_Method__c,Content_Type__c,Version__c FROM Callout_Configuration__mdt where QualifiedApiName = 'ZuoraCreateSubscription_SANDBOX'];                                                                
  //   String   zuoraServiceUrl = zuoraQueryCalloutConfig[0].Endpoint_URL__c;       
      HttpRequest req = SSZuoraUtilEx.getZuoraRequestHeader(zuoraQueryCalloutConfig[0].Endpoint_URL__c, zuoraQueryCalloutConfig[0].Username__c, zuoraQueryCalloutConfig[0].Password__c,zuoraQueryCalloutConfig[0].Version__c);                                                         
      String body = SSZuoraUtilEx.getCreateSubscriptionRequestBody(zuoraAccountId, subscriptionStartDate,termType,initialTerm,renewalTerm,autoRenew,productInfoLst);  
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
                throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_CREATE_SUBSCRIPTION_CALLOUT);
        } 
           System.debug('queryResult'+queryResult) ;                                                        
           return queryResult;                                                                   
    }    
                                                               
 global static String getCreateSubscriptionRequestBody(String zuoraAccountId, DateTime subscriptionStartDate,String termType,Integer initialTerm, Integer renewalTerm,
                                                  Boolean autoRenew,List<SSZuoraUtilEx.ProductRatePlanJSON> productInfoLst) {
   JSONGenerator gen = JSON.createGenerator(true);    
	
  gen.writeStartObject(); 
  gen.writeStringField('termType',termType);                                                     
  If (termType.equalsIgnoreCase('termed')) {  //Zuora Has TERMED and EVERGREEN subscriptions. Define at the CC subscription Level?
  gen.writeNumberField('initialTerm',initialTerm); //Where can we get info about this field                                                                
  gen.writeBooleanField('autoRenew', autoRenew);
  gen.writeNumberField('renewalTerm', renewalTerm);//Where can we get info about this field  
  } 
  gen.writeDateTimeField('contractEffectiveDate', subscriptionStartDate); 
  gen.writeStringField('accountKey', zuoraAccountId);                                                     
  gen.writeStringField('notes', 'Test Subscription');
  gen.writeObjectField('subscribeToRatePlans',productInfoLst);//have to fetch the Product Info                                                 					                                                              
  gen.writeBooleanField('invoice',false);                                                                 
  gen.writeEndObject();                                                                   
  String jsonS = gen.getAsString();
  return jsonS;                                           
      }
    
 global static String getCreateAccountRequestBody(SSAccountModel account, SSContactModel contact, String currencyCode, String locale, String paymentReferenceID,
                                                             SSPaymentDetailsModel paymentDetails) {
                           
    JSONGenerator gen = JSON.createGenerator(true);    
	
	gen.writeStartObject();      
	gen.writeStringField('name', account.accountName);
    gen.writeStringField('crmId', account.accountId);                                                               
	gen.writeStringField('currency', currencyCode);
    gen.writeNumberField('billCycleDay', 0);
    gen.writeBooleanField('autoPay', true); 
    gen.writeStringField('batch', 'Batch1'); 
    gen.writeStringField('paymentTerm','Due Upon Receipt'); 
  //gen.writeStringField('invoiceTemplateId',''); //If not passed will be deafulted to Zuora Invoice Template
  //gen.writeStringField ('communicationProfileId',''); //If not passed will be deafulted to Zuora Invoice Template                                                            
  //gen.writeStringField('taxCompanyCode',taxCompanyCode); // Needs to be passed as input parameter
  //gen.writeStringField('taxExemptStatus','Yes');  //  get it from the cartModel                                                         
  //gen.writeStringField('taxExemptCertificateID', vatNumber); get it from the cartModel//when flowVars.accountResponse.vatNumber == null otherwise flowVars.accountResponse.vatNumber
 // gen.writeStringField('VATId',vatNumber);// when flowVars.accountResponse.vatNumber == null otherwise flowVars.accountResponse.vatNumber,                                                                                                                                                                                  
  gen.writeFieldName('billToContact');
  gen.writeStartObject();
  gen.writeStringField('address1',contact.address.streetAddress);                                                               
  gen.writeStringField('city', contact.address.city);
  gen.writeStringField('country', contact.address.country);
  gen.writeStringField('firstName', contact.firstName);
  gen.writeStringField('lastName', contact.lastName);
  gen.writeStringField('state', contact.address.state);
  gen.writeStringField('zipCode', contact.address.postalCode);
  gen.writeStringField('workEmail', contact.email); 
  gen.writeStringField('workPhone', contact.phone);                                                                 
 // gen.writeStringField('county', ''); 						                                                              
  gen.writeEndObject(); 
 // Optional SoldToContact                                                                  
  gen.writeFieldName('soldToContact');
  gen.writeStartObject();
  gen.writeStringField('address1',contact.address.streetAddress);
  gen.writeStringField('city', contact.address.city);
  gen.writeStringField('country', contact.address.country);
  gen.writeStringField('firstName', contact.firstName);
  gen.writeStringField('lastName', contact.lastName);
  gen.writeStringField('state', contact.address.state);
  gen.writeStringField('zipCode', contact.address.postalCode);
  gen.writeStringField('workEmail', contact.email); 
  gen.writeStringField('workPhone', contact.phone);
  gen.writeEndObject();                                                                 
 // gen.writeStringField('county', ''); 
  if (!String.IsBlank(paymentReferenceID)) {
  gen.writeStringField('hpmCreditCardPaymentMethodId', paymentReferenceID);    
  }	
  else {                                                                  
  gen.writeFieldName('creditCard');
  gen.writeStartObject(); 
  gen.writeStringField('cardType', paymentDetails.cardType);
  gen.writeNumberField('expirationMonth',paymentDetails.expirationMonth);
  gen.writeStringField('securityCode',paymentDetails.securityCode);
  gen.writeStringField('cardNumber',paymentDetails.cardNumber);                                                                 
  gen.writeNumberField('expirationYear',paymentDetails.expirationYear);
  //Optional CardHolder Info, If not Provide takes the billTo Contact                                                                 
  gen.writeFieldName('cardHolderInfo');
  gen.writeStartObject();
  gen.writeStringField('cardHolderName',paymentDetails.cardHolderName);
  gen.writeStringField('addressLine1',paymentDetails.street); 
  //gen.writeStringField('addressLine2', '');                                                                 
  gen.writeStringField('city', paymentDetails.city);
  gen.writeStringField('state', paymentDetails.state);
  gen.writeStringField('zipCode', paymentDetails.postalCode);                                                                 
  gen.writeStringField('country', paymentDetails.country);
  gen.writeStringField('email', paymentDetails.email); 
  gen.writeStringField('phone', paymentDetails.phone);                                                                  					                                                              
  gen.writeEndObject();   
  gen.writeEndObject();
  }                                                                
  gen.writeEndObject();                                                                   
  String jsonS = gen.getAsString();
  return jsonS;                                                                 
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
        List<ProductRatePlanJSON> productLstJson = new List<ProductRatePlanJSON>(); 
        List<SSBillingSubscriptionModel.subscriptionModel> subModelList = new List<SSBillingSubscriptionModel.subscriptionModel>();       
        productLstJson.add(getSubscripionProductInfo (cartItem.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c, cartItem.ccrz__Coupon__r.ccrz__CouponType__c,String.valueOf(cartItem.ccrz__Coupon__r.Length__c),cartItem.ccrz__Coupon__r.Period__c, String.valueOf(cartItem.ccrz__Coupon__r.ccrz__DiscountAmount__c), cartItem.ccrz__Product__r.Id,String.valueof(cartItem.ccrz__Quantity__c)));
        queryResult = SSZuoraUtilEx.getRestCreateSubscriptionResult(zuoraAccountId, subscriptionStartDate,String.ValueOf(cartItem.ccrz__Product__r.product_subscription_type__c),Integer.ValueOf(cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c), 12,
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
            subModelList.add(subModel);
             System.debug('subModelList'+subModelList);
          //  billingModel.subscriptionMap<String,List<SSBillingSubscriptionModel.subscriptionModel>> map22 = new billingModel.subscriptionMap<String,List<SSBillingSubscriptionModel.subscriptionModel>>();
            // map22.put(bundleCartItems[0].ccrz__Product__r.ccrz__SKU__c,subModelList);
             billingModel.subscriptionMap.put(cartItem.ccrz__Product__r.ccrz__SKU__c,subModelList);
            System.debug('subModelList'+billingModel.subscriptionMap);
         }
       
        }
       
        List<ccrz__E_CartItem__c> bundlecartItems = [SELECT ccrz__Product__r.ccrz__SKU__c,ccrz__Product__r.Id,ccrz__Product__r.product_subscription_type__c, ccrz__Coupon__r.ccrz__CouponType__c,ccrz__Coupon__r.ccrz__DiscountAmount__c,ccrz__Quantity__c,ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c,ccrz__Coupon__r.Period__c,ccrz__Coupon__r.Length__c,
                                                   Bundle_Product_Description__c,Bundle_Product_SKU__c,Tier_Description__c,ccrz__SubProdTerm__r.ccrz__InstallmentCount__c,ccrz__SubProdTerm__r.ccrz__AutoRenew__c FROM ccrz__E_CartItem__c where ccrz__Cart__r.ccrz__EncryptedId__c =: cartId and ccrz__cartItemType__c= 'Major' and Bundle_Product_SKU__c!=null and ccrz__ProductType__c='Dynamic Kit'];  
        If(bundlecartItems.size()!=0){
        List<ProductRatePlanJSON> bundleproductLstJson = new List<ProductRatePlanJSON>();
         for (ccrz__E_CartItem__c cartItem: bundlecartItems) {
        bundleproductLstJson.add(getSubscripionProductInfo (cartItem.ccrz__Product__r.ccrz__SKU__c, cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c, cartItem.ccrz__Coupon__r.ccrz__CouponType__c,String.valueOf(cartItem.ccrz__Coupon__r.Length__c),cartItem.ccrz__Coupon__r.Period__c, String.valueOf(cartItem.ccrz__Coupon__r.ccrz__DiscountAmount__c), cartItem.ccrz__Product__r.Id,String.valueof(cartItem.ccrz__Quantity__c)));
         }
            //Where to get the renewal date, can we get it from subprodterm?
       queryResult = SSZuoraUtilEx.getRestCreateSubscriptionResult(zuoraAccountId, subscriptionStartDate,String.ValueOf(bundlecartItems[0].ccrz__Product__r.product_subscription_type__c),Integer.ValueOf(bundlecartItems[0].ccrz__SubProdTerm__r.ccrz__InstallmentCount__c), 12,
                                                  bundleCartItems[0].ccrz__SubProdTerm__r.ccrz__AutoRenew__c,bundleproductLstJson); 
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
             subModelList.add(subModel);
           
              billingModel.subscriptionMap.put(bundleCartItems[0].ccrz__Product__r.ccrz__SKU__c,subModelList);  
                  }
       
            } catch(System.CalloutException e) {
            System.debug('Callout exception ' + e.getMessage());
                throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_RESTQUERY_CALLOUT);
        } 
    return billingModel; 
    }
    
    global static ProductRatePlanJSON getSubscripionProductInfo (String productSku, String subscriptionFrequency, String couponType,String couponLength,
                                                  String couponPeriod, String discountAmount, String ccProductId, String quantity) {
      
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
             
            // If(!String.(cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c)){
              String strNameSupport = '%'+subscriptionFrequency+ ' [Promo:'+couponType+']';
            //  }
                 If (String.IsBlank(couponType)){
             strNameSupport = '%'+subscriptionFrequency+ ' [Promo:None]';  
              }
              
              If ((!String.IsBlank(couponLength)) && (!String.IsBlank(couponPeriod))) {
               endDateCondition = 'Fixed_Period';
               couponPeriod = couponPeriod +'s';
              }
          
          //Fetch ProductRatePlan based on ProductId 
          String zProductRatePlanQuery ='select Id,Name from ProductRatePlan where Productid=\''+productId +'\' and Name like \''+strNameSupport+'\'';
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
            List<Map<String,String>> chargeList =new  List<Map<String,String>>();
            rpjson.productRatePlanId = productRatePlanId;
            String  zProductRatePlanChargeQuery ='select Id,Name,UOM from ProductRatePlanCharge where ProductRatePlanid=\''+productRatePlanId+'\' ';
            String productRatePlanChargeResult = getRestQueryResult(zProductRatePlanChargeQuery);
            
           Map<String, Object> productRatePlanCharge = (Map<String, Object>) JSON.deserializeUntyped(productRatePlanChargeResult);
           List<Object> productRatePlanChargeRecords = (List<Object>) productRatePlanCharge.get('records');      
            
           If (productRatePlanChargeRecords.size() > 0){            
           for (Object rec : productRatePlanChargeRecords) {
           Map<String, Object> productRatePlanChargeMap = (Map<String, Object>) rec;
           Map<String,String> chargeJson= new  Map<String,String>();  
            String ChargeName=(String)productRatePlanChargeMap.get('Name');
            if(ChargeName.contains('Price')){
                    chargeJson.put('productRatePlanChargeId',(String)productRatePlanChargeMap.get('Id'));
                    chargeJson.put('discountAmount',discountAmount);
                    // chargejson.put('applyDiscountTo',pr.strapplyDiscountTo);
                    chargeJson.put('endDateCondition',endDateCondition);
                    chargeJson.put('upToPeriods',couponLength);
                    chargeJson.put('upToPeriodsType',couponPeriod);
            } 
               else if(ChargeName.contains('Percentage')){
                      chargeJson.put('productRatePlanChargeId',(String)productRatePlanChargeMap.get('Id'));
                      chargejson.put('discountPercentage',discountAmount);
                     // chargejson.put('applyDiscountTo',pr.strapplyDiscountTo); 
                      chargejson.put('endDateCondition', endDateCondition);
                      chargejson.put('upToPeriods', couponLength);
                      chargejson.put('upToPeriodsType', couponPeriod);       
                } 
               else if(SSproductHelper.isTierPriced(ccProductId)== true){
                     chargejson.put('productRatePlanChargeId', (String)productRatePlanChargeMap.get('Id'));
                     chargejson.put('quantity',String.valueof(quantity));                 
                    }
               else{
                    chargejson.put('productRatePlanChargeId',(String)productRatePlanChargeMap.get('Id'));     
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
                throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_RESTQUERY_CALLOUT);
        } 
   return rpjson;
}

 global class ProductRatePlanJSON {
       global String productRatePlanId {get; set;}
       global List<Map<String,String>> chargeOverrides {get; set;}              
                 }
 
}