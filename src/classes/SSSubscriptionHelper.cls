global class SSSubscriptionHelper {

global Static SSSubscriptionModel getSubscription(String subscriptionId) {
      //retrieve the current subscription
        List<ccrz__E_Order__c> subscriptionList = getSubscriptionById(subscriptionId); 
          
    if ((subscriptionList == null) || (subscriptionList.size() == 0)) {
          throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_SUBSCRIPTION_INVALID_SUBSCRIPTION_ID);
        }
        ccrz__E_Order__c ssSubscription = subscriptionList[0];
        
        return getSubscriptionInfo(ssSubscription);
        
    }
    
     global Static List<SSSubscriptionModel> getSubscriptions(String subscriptionId, String accountId, String contactEMail) {
        List<ccrz__E_Order__c> subscriptionList = new List<ccrz__E_Order__c>();
        if (!String.isBlank(subscriptionId)) {
            subscriptionList = getSubscriptionById(subscriptionId);          
        }
        else if (!String.isBlank(accountId)) {
            subscriptionList = getSubscriptionByAccountId(accountId);          
        }
        else if (!String.isBlank(contactEMail)) {
            subscriptionList = getSubscriptionsByEMail(contactEMail);          
        }
       System.debug('subscriptionList' + subscriptionList.size());
        List<SSSubscriptionModel> subscriptions = new List<SSSubscriptionModel>();            
        for (ccrz__E_Order__c subscription : subscriptionList) {
            SSSubscriptionModel subscriptionModel = getSubscriptionInfo(subscription);
            subscriptions.add(subscriptionModel);                            //

        }
         System.debug('Subscriptions'+subscriptions);
        return subscriptions;
    }
    
    global Static List<ccrz__E_Order__c> getSubscriptionsByEMail(String email) {
        List<Contact> contactsList = getContactsByEmail(email);
        List<String> accountIdList = new List<String>();
        for (Contact contactInfo : contactsList) {
            accountIdList.add(contactInfo.AccountId);
        }
        List<ccrz__E_Order__c> subscriptionList = getSubscriptionByAccounts(accountIdList);        
        return subscriptionList;
    }
    
     global Static List<Contact> getContactsByEmail(String email){
        try {
            List<Contact> cartContactList = [SELECT Id, FirstName, LastName, Email, AccountId, 
                                   MailingStreet, MailingCity, MailingState, MailingPostalCode,
                                   Account.Name, Account.Id, Account.BillingStreet FROM Contact WHERE Email =:email];
            
            return cartContactList;
        }
        catch (System.QueryException ex) {
            throw new SSCartException(SSCartException.EXCEPTION_INVALID_CART_ID);            
        }
    }
    
 global Static List<ccrz__E_Order__c> getSubscriptionByAccounts(List<String> accountList){
        try {
            return [SELECT ID, Name, ccrz__Account__c,
                    ccrz__CCEmailAddress__c, ccrz__Contact__c, ccrz__CurrencyISOCode__c, ccrz__OriginatedCart__c, 
                    ccrz__Storefront__c, Subscription_Status__c, CurrencyIsoCode, ccrz__OrderDate__c, 
                    ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, ccrz__TaxSubTotalAmount__c, ccrz__TotalAmount__c,
                    ccrz__OriginatedCart__r.ccrz__EncryptedId__c  
                    FROM ccrz__E_Order__c  
                    WHERE ccrz__Account__c IN : accountList ORDER BY ID];
            //Account__ID__c
        }
        catch (System.QueryException ex) {
            throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_SUBSCRIPTION_INVALID_ACCOUNT_ID);            
        }
    }

   global Static List<ccrz__E_Subscription__c> getSubscriptionItems(String subscriptionId){
        try {
            //subscriptionId = subscriptionId.toLowerCase();
            return [SELECT ID, Name, ccrz__SubscriptionProduct__r.Billing_Product_ID__c, ccrz__SubscriptionProduct__r.name, ccrz__SubscriptionProduct__r.ccrz__SKU__c, 
                    ccrz__SubscriptionProduct__r.ccrz__ShortDesc__c, ccrz__SubscriptionProduct__r.ccrz__LongDesc__c, 
                    ccrz__SubscriptionProduct__r.ID, ccrz__Storefront__c, ccrz__SubscriptionStartDate__c, ccrz__SPTInstallmentFrequencyUOM__c, 
                    ccrz__SPTInstallmentFrequency__c, ccrz__SPTInstallmentCount__c, ccrz__CurrencyISOCode__c, 
                    ccrz__CCOrder__c, ccrz__Account__c, Product_Entitlement_Id__c , ccrz__CCOrder__r.ccrz__OriginatedCart__c,
                      ccrz__SubscriptionStatus__c, ccrz__OrderStatus__c,Billing_Subscription_ID__c,
                    Bundle_Product_Description__c, Bundle_Product_SKU__c, Tier_Description__c, Is_Trial__c , ccrz__RecurringPrice__c, 
                    Subscription_End_Date__c, Subscription_Event__c ,ccrz__SubscriptionProduct__r.Trial_Period_in_Days__c
                    FROM ccrz__E_Subscription__c 
                    WHERE ccrz__CCOrder__c  =:subscriptionId];                
        }
        catch (System.QueryException ex) {
            throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_SUBSCRIPTION_INVALID_SUBSCRIPTION_ID);            
        }
    }
 
     global Static List<ccrz__E_Order__c> getSubscriptionById(String subscriptionId) {
        try {
           // subscriptionId = subscriptionId.toLowerCase();
            try {
                List<ccrz__E_Order__c> subscriptionList = [SELECT ID, Name, ccrz__Account__c,
                        ccrz__CCEmailAddress__c, ccrz__Contact__c, ccrz__CurrencyISOCode__c, ccrz__OriginatedCart__c, 
                            ccrz__Storefront__c, Subscription_Status__c, CurrencyIsoCode, ccrz__OrderDate__c, 
                        ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, ccrz__TaxSubTotalAmount__c, ccrz__TotalAmount__c, 
                        ccrz__OriginatedCart__r.ccrz__EncryptedId__c, Billing_Account_ID__c  
                        FROM ccrz__E_Order__c  
                        WHERE ccrz__ccsubscription__c  =: subscriptionId or ID =: subscriptionId];
                System.debug('subList'+subscriptionList);
                //this is for handling legacy subscriptions where the ID was persisted at CC Subscription level
                if (subscriptionList.size() == 0) {
                    return getSubscriptionFromSubItem(subscriptionId);             
                    
                }
                return subscriptionList;
            }
            catch (Exception ex) {
                //this is for handling legacy subscriptions where the ID was persisted at CC Subscription level
                return getSubscriptionFromSubItem(subscriptionId);             
            }
        }
        catch (System.QueryException ex) {
            throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_SUBSCRIPTION_INVALID_SUBSCRIPTION_ID);            
        }
    }
    
      global Static List<ccrz__E_Order__c> getSubscriptionFromSubItem(String subscriptionId) {
        List<ccrz__E_Subscription__c> subscriptionItems = [SELECT ID, Name, ccrz__SubscriptionProduct__r.name, ccrz__SubscriptionProduct__r.ccrz__SKU__c, 
                                                           ccrz__SubscriptionProduct__r.ccrz__ShortDesc__c, ccrz__SubscriptionProduct__r.ccrz__LongDesc__c, ccrz__SubscriptionProduct__r.ID, ccrz__Storefront__c, ccrz__SubscriptionStartDate__c, ccrz__SPTInstallmentFrequencyUOM__c, 
                    ccrz__SPTInstallmentFrequency__c, ccrz__SPTInstallmentCount__c, ccrz__CurrencyISOCode__c, 
                    ccrz__CCOrder__c, ccrz__Account__c , Bundle_Product_Description__c, Bundle_Product_SKU__c, Tier_Description__c, 
                     ccrz__SubscriptionStatus__c, ccrz__OrderStatus__c,Subscription_Event__c  FROM ccrz__E_Subscription__c 
                    WHERE ID =: subscriptionId];
        //Subscription_Item_ID__c
        ccrz__E_Subscription__c subscriptionItem = subscriptionItems[0];
        subscriptionId = subscriptionItem.ccrz__CCOrder__c;                
        return [SELECT ID, Name, ccrz__Account__c,
                        ccrz__CCEmailAddress__c, ccrz__Contact__c, ccrz__CurrencyISOCode__c,  ccrz__OriginatedCart__c, 
                            ccrz__Storefront__c, Subscription_Status__c, CurrencyIsoCode, ccrz__OrderDate__c, 
                        ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, ccrz__TaxSubTotalAmount__c, ccrz__TotalAmount__c, 
                        ccrz__OriginatedCart__r.ccrz__EncryptedId__c ,Billing_Account_ID__c
                        FROM ccrz__E_Order__c  
                        WHERE ID =: subscriptionId];                  
    }
    
    global Static List<ccrz__E_Order__c> getSubscriptionByAccountId(String accountId){
        try {
         //   accountId = accountId.toLowerCase();            
            return [SELECT ID, Name, ccrz__Account__c,
                        ccrz__CCEmailAddress__c, ccrz__Contact__c, ccrz__CurrencyISOCode__c,  ccrz__OriginatedCart__c, 
                            ccrz__Storefront__c, Subscription_Status__c, CurrencyIsoCode, ccrz__OrderDate__c, 
                        ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, ccrz__TaxSubTotalAmount__c, ccrz__TotalAmount__c, 
                        ccrz__OriginatedCart__r.ccrz__EncryptedId__c,Billing_Account_ID__c  
                        FROM ccrz__E_Order__c  
                    WHERE ccrz__Account__c =: accountId ORDER BY ID];
            //Account_ID__c
        }
        catch (System.QueryException ex) {
            throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_SUBSCRIPTION_INVALID_ACCOUNT_ID);            
        }
    }
    global Static boolean updateSubscription(String subscriptionId, String entitlementId, String slcsClientRef, String slcsSubscriptionGroupId, String slcsSubscriptionId) {

        List<ccrz__E_Order__c> subscriptionList = getSubscriptionById(subscriptionId);
        System.debug('###updateSubscription: subscription retrieved ' + subscriptionList.size());
        if (subscriptionList.size() > 0) {
            System.debug('###updateSubscription: updating subscription ' + subscriptionList.size());
            ccrz__E_Order__c subscription = subscriptionList[0];
            update subscription;
        }
        
        List<ccrz__E_Subscription__c> subscriptionItems = getSubscriptionItems(subscriptionId);
        System.debug('###updateSubscription:  retrieved subscription items ' + subscriptionId);
        for (ccrz__E_Subscription__c subscriptionItem : subscriptionItems) {
            String zuoraSubscriptionId = '';
            System.debug('###updateSubscription:  update subscription items ' + subscriptionId);
            updateSubscriptionItems(subscriptionItem.Id);
        }        
        System.debug('###updateSubscription:  processing completed ' + subscriptionId);
                
        return true;        
    }
    
    global Static SSSubscriptionModel getSubscriptionInfo(ccrz__E_Order__c subscription) {
  
        SSSubscriptionModel subscriptionModel = new SSSubscriptionModel();
        subscriptionModel.subscriptionId = subscription.Id;       
        subscriptionModel.storefront =subscription.ccrz__Storefront__c;
        
     // subscriptionModel.subscriptionStartDate = subscription.ccrz__OrderDate__c;
        subscriptionModel.subscriptionStatus = subscription.Subscription_Status__c;
        
        String cartId = subscription.ccrz__OriginatedCart__c;
        SSCartModel cart = SSCartHelper.getCartBySFID(cartId); //1 quer
        subscriptionModel.cart = cart;
        
      SSAccountModel accountModel = SSAccountHelper.getAccount(cart.accountId); //Commented to overcome soql limit
      subscriptionModel.account = accountModel;
                
        SSContactModel contactModel = SSContactHelper.getContact(cart.contactId); //Commented to overcome soql limit
         subscriptionModel.contact = contactModel;
        
      //  subscriptionModel.subscriptionEndDate = subscription.Subscription_End_Date__c;
      
      //  subscriptionModel.subscriptionEvent = subscription.Subscription_Event__c;
       // subscriptionModel.transactionReferenceNumber = subscription.Transaction_Reference_Number__c;
       // subscriptionModel.paymentMethodId = subscription.Payment_Method_Id__c;
       
       /* String zuoraSubscriptionId = cart.zuoraSubscriptionId;
        String zuoraSubscriptionNumber = cart.zuoraSubscriptionNumber;
        System.debug('#####zuoraSubscriptionId ' + zuoraSubscriptionId);*/
        
        List<ccrz__E_Subscription__c> subscriptionItems = getSubscriptionItems(subscription.Id);
   /*     if (subscriptionItems.size() > 0) {
            subscriptionModel.subscriptionTermType = subscriptionItems[0].ccrz__SPTInstallmentFrequencyUOM__c;
            cart.subscriptionTermType = subscriptionItems[0].ccrz__SPTInstallmentFrequencyUOM__c;
        }*/
        System.debug('#####subscriptionItems ' + subscriptionItems.size());
                   
        List<SSSubscriptionItemModel> products = new List<SSSubscriptionItemModel>();
        List<String> billingProducts = new List<String>();
        for (ccrz__E_Subscription__c subscriptionItem : subscriptionItems) {           
            SSSubscriptionItemModel subscriptionProduct = new SSSubscriptionItemModel();
           
            //Get Related Products
            List<SSProductModel> relatedProductslst = new List<SSProductModel>();
            relatedProductslst = SSProductService.getUpSellProducts(subscriptionItem.ccrz__SubscriptionProduct__r.ID);
            
            
            List<SSSubscriptionItemModel> childproductsLst = new List<SSSubscriptionItemModel>();
            subscriptionProduct.subscriptionItemId = subscriptionItem.Id;
            subscriptionProduct.subscriptionId = subscriptionItem.ccrz__CCOrder__c;
            subscriptionProduct.accountId = subscriptionItem.ccrz__Account__c;
            subscriptionProduct.billingProductId = subscriptionItem.ccrz__SubscriptionProduct__r.Billing_Product_ID__c;
            if (String.isNotBlank(subscriptionItem.ccrz__SubscriptionProduct__r.Billing_Product_ID__c)) {
                billingProducts.add(subscriptionItem.ccrz__SubscriptionProduct__r.Billing_Product_ID__c);         
            }
            subscriptionProduct.bundleProductSKU = subscriptionItem.Bundle_Product_SKU__c;
             subscriptionProduct.productSKU = subscriptionItem.ccrz__SubscriptionProduct__r.ccrz__SKU__c;
            subscriptionProduct.productShortDescription = subscriptionItem.ccrz__SubscriptionProduct__r.ccrz__ShortDesc__c;
            subscriptionProduct.productName = subscriptionItem.ccrz__SubscriptionProduct__r.name;
            subscriptionProduct.productLongDescription = subscriptionItem.ccrz__SubscriptionProduct__r.ccrz__LongDesc__c;
            subscriptionProduct.productId = subscriptionItem.ccrz__SubscriptionProduct__r.ID;
            subscriptionProduct.isTrial = SSProductHelper.isTrailProduct(subscriptionItem.ccrz__SubscriptionProduct__r.ccrz__SKU__c);
            System.debug('subscriptionProduct.isTrial '+subscriptionProduct.isTrial);
            subscriptionProduct.trailPeriod = subscriptionItem.ccrz__SubscriptionProduct__r.Trial_Period_in_Days__c;
            If (relatedProductslst.size()>0){
             subscriptionProduct.isUpgradable = true;  
            }else {
             subscriptionProduct.isUpgradable = false;    
            }
            subscriptionProduct.upsellProducts = relatedProductslst;
            
            //To Indicate Product Relations
            List<SSCartItemModel> cartItem = cart.cartItems;
            for (SSCartItemModel ct : cartItem) {
                If (subscriptionItem.ccrz__SubscriptionProduct__r.ccrz__SKU__c == ct.Sku){                  
                 subscriptionProduct.productRelationType= ct.relatedProductType; 
                 subscriptionProduct.relatedProductParentSku =ct.relatedProductParentSku; 
                 subscriptionProduct.productPrice = ct.subAmount; 
                 subscriptionProduct.productQuantity = ct.quantity;    
                }
                
                 If (subscriptionItem.ccrz__SubscriptionProduct__r.ccrz__SKU__c == ct.parentSku){
                  SSSubscriptionItemModel childProducts = new SSSubscriptionItemModel();
                 childProducts.productRelationType= ct.relatedProductType; 
                 childProducts.relatedProductParentSku =ct.relatedProductParentSku; 
                 childProducts.productSku = ct.sku;
                 childProducts.productName = ct.productName;
                 childProducts.productPrice = ct.subAmount; 
                 childProducts.productQuantity = ct.quantity;
                 childProducts.subscriptionTermType = subscriptionItem.ccrz__SPTInstallmentFrequencyUOM__c;
                 childProducts.subscriptionEndDate = subscriptionItem.Subscription_End_Date__c;
                 childProducts.subscriptionStatus = subscriptionItem.ccrz__SubscriptionStatus__c;
                 childProductsLst.add(childProducts);    
                }
                              
            }
            subscriptionProduct.childComponents = childProductsLst;
           
            subscriptionProduct.bundleProductDescription = subscriptionItem.Bundle_Product_Description__c;
            subscriptionProduct.currencyISOCode = subscriptionItem.ccrz__CurrencyISOCode__c;
            subscriptionProduct.recurringPrice = subscriptionItem.ccrz__RecurringPrice__c;
            subscriptionProduct.subscriptionTermType = subscriptionItem.ccrz__SPTInstallmentFrequencyUOM__c;
            subscriptionProduct.storefront = subscriptionItem.ccrz__Storefront__c;
            subscriptionProduct.subscriptionStartDate = subscriptionItem.ccrz__SubscriptionStartDate__c;
            subscriptionProduct.subscriptionEndDate = subscriptionItem.Subscription_End_Date__c;
            subscriptionProduct.subscriptionStatus = subscriptionItem.ccrz__SubscriptionStatus__c;
            subscriptionProduct.subscriptionEvent = subscriptionItem.Subscription_Event__c;
            subscriptionProduct.billingSubscriptionId =subscriptionItem.Billing_Subscription_ID__c;
            //subscriptionProduct.billingAccountId = subscription.Billing_Account_ID__c ;
            System.debug('Setting billingSubscriptionId to '+subscriptionProduct.billingSubscriptionId);
            products.add(subscriptionProduct);
        }
    //  subscriptionModel.billingProductList = billingProducts;
       subscriptionModel.subscribedProducts = products;
     //   subscriptionModel.identityId = '';
    //    System.debug('#####products ' + products.size());
        
       /* if (String.isNotBlank(zuoraSubscriptionNumber)) {
            try {
                System.debug('#####zuoraSubscriptionId ' + zuoraSubscriptionId);
                Zuora__Subscription__c zuoraSubscription = [SELECT ID, Name, Zuora__Zuora_Id__c, Zuora__CustomerAccount__r.Name,  
                                                            Zuora__Account__r.Name,  Zuora__Account__r.ID, Zuora__CustomerAccount__r.Zuora__AccountNumber__c, 
                                                            Zuora__CustomerAccount__r.ID, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c, 
                                                            Zuora__ContractEffectiveDate__c, Zuora__Status__c, Zuora__ServiceActivationDate__c, 
                                                            Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Zuora__NextChargeDate__c, 
                                                            Zuora__TermStartDate__c, Zuora__TermEndDate__c, Zuora__TermSettingType__c, 
                                                            Zuora__TCV__c FROM Zuora__Subscription__c WHERE Name =: zuoraSubscriptionNumber LIMIT 1];
                String zuoraSubscriptionSFID = zuoraSubscription.ID;
                subscriptionModel.zuoraSubscriptionSFID = zuoraSubscriptionSFID;   
                subscriptionModel.zuoraSubscriptionId = zuoraSubscription.Zuora__Zuora_Id__c;
                
                
                System.debug('#####zuoraSubscriptionSFID ' + zuoraSubscriptionSFID);
                
                TetrisBillingModel billingModel = new TetrisBillingModel();
                billingModel.zuoraAccountZuoraId = zuoraSubscription.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c;
                billingModel.zuoraAccountName = zuoraSubscription.Zuora__Account__r.Name;
                billingModel.zuoraAccountNumber = zuoraSubscription.Zuora__CustomerAccount__r.Zuora__AccountNumber__c;
                billingModel.salesforceAccountId = zuoraSubscription.Zuora__CustomerAccount__r.ID;
                billingModel.subscriptionNumber = zuoraSubscription.Name;
                billingModel.contractEffectiveDate = zuoraSubscription.Zuora__ContractEffectiveDate__c;
                billingModel.billingAccountStatus = zuoraSubscription.Zuora__Status__c;
                billingModel.serviceActivationDate = zuoraSubscription.Zuora__ServiceActivationDate__c;
                billingModel.zuoraAccountId = zuoraSubscription.Zuora__Account__r.ID;
                billingModel.subscriptionStartDate = zuoraSubscription.Zuora__SubscriptionStartDate__c;
                billingModel.subscriptionEndDate = zuoraSubscription.Zuora__SubscriptionEndDate__c;
                billingModel.nextChargeDate = zuoraSubscription.Zuora__NextChargeDate__c;
                billingModel.termStartDate = zuoraSubscription.Zuora__TermStartDate__c;
                billingModel.termEndDate = zuoraSubscription.Zuora__TermEndDate__c;
                billingModel.termSettingType = zuoraSubscription.Zuora__TermSettingType__c;
                
                
                subscriptionModel.billing = billingModel;
            }
           catch (Exception ex) {
        System.debug('#####Exception ' + ex.getMessage());
                        
            }
            subscriptionModel.zuoraSubscriptionId = zuoraSubscriptionId;
            subscriptionModel.zuoraSubscriptionNumber = zuoraSubscriptionNumber
        }*/
        subscriptionModel.billingAccountId= subscription.Billing_Account_ID__c ;      
     
        return subscriptionModel;                
    }

      
     global Static boolean updateSubscriptionItems(String subscriptionItemId) {
    
            ccrz__E_Subscription__c subscription = [SELECT ID, Name, ccrz__SubscriptionProduct__r.name, ccrz__SubscriptionProduct__r.ccrz__SKU__c, 
                                                           ccrz__SubscriptionProduct__r.ccrz__ShortDesc__c, ccrz__SubscriptionProduct__r.ccrz__LongDesc__c, ccrz__SubscriptionProduct__r.ID, ccrz__Storefront__c, ccrz__SubscriptionStartDate__c, ccrz__SPTInstallmentFrequencyUOM__c, 
                    ccrz__SPTInstallmentFrequency__c, ccrz__SPTInstallmentCount__c, ccrz__CurrencyISOCode__c, 
                    ccrz__CCOrder__c, ccrz__Account__c , Bundle_Product_Description__c, Bundle_Product_SKU__c, Tier_Description__c, 
                     ccrz__SubscriptionStatus__c, ccrz__OrderStatus__c   FROM ccrz__E_Subscription__c  WHERE ID =: subscriptionItemId  LIMIT 1];
    
            subscription.CurrencyISOCode = subscription.ccrz__CCOrder__r.CurrencyISOCode;
          
            update subscription;
        
        return true;
        
    }
    
    global static void updateTaxAmount(String cartId, Decimal taxAmount) {
        try {
                List<ccrz__E_Order__c> subscriptionList = [SELECT ID, Name, ccrz__OriginatedCart__c,  ccrz__TaxAmount__c
                        FROM ccrz__E_Order__c  
                        WHERE ccrz__OriginatedCart__c =: cartId];
                for (ccrz__E_Order__c subscription : subscriptionList) {
                    subscription.ccrz__TaxAmount__c = taxAmount;
                }
                update subscriptionList;
        }
        catch (System.Exception ex) {
        }
    }
    
   /* global static boolean updateSubscriptionStatus(String subscriptionId, String subscriptionStatus) {
        List<ccrz__E_Order__c> subscriptionList = getSubscriptionById(subscriptionId);
    ccrz__E_Order__c subscription = subscriptionList[0];
    subscription.Subscription_Status__c = subscriptionStatus;
    update subscription;       
        return true;
    }*/
    
    global static boolean updateSubscriptionStatus(String orderId, String subscriptionStatus, String subscriptionEvent, Boolean updateSubscriptionItems) {
        List<ccrz__E_Order__c> subscriptionList = getSubscriptionById(orderId);
    ccrz__E_Order__c subscription = subscriptionList[0];
        if (String.isNotBlank(subscriptionStatus)) {
      subscription.Subscription_Status__c = subscriptionStatus;        
        }
        if (String.isNotBlank(subscriptionEvent)) {
          subscription.Subscription_Event__c = subscriptionEvent;
        }
    update subscription;       

        if (updateSubscriptionItems) {
            List<ccrz__E_Subscription__c> subscriptionItems = getSubscriptionItems(orderId);
            System.debug('###updateSubscription:  retrieved subscription items ' + orderId);
            for (ccrz__E_Subscription__c subscriptionItem : subscriptionItems) {
            if (String.isNotBlank(subscriptionStatus)) {
                  subscriptionItem.ccrz__SubscriptionStatus__c = subscriptionStatus;
            }
            if (String.isNotBlank(subscriptionEvent)) {
                  subscriptionItem.Subscription_Event__c = subscriptionEvent;
            }
            }        
            update subscriptionItems;            
        }
        System.debug('subscription status updated');
        return true;
    }
    
    
    global static boolean updateCCSubscriptionStatus(String subscriptionId, String subscriptionStatus, String subscriptionEvent) {

            ccrz__E_Subscription__c subscription = [SELECT ccrz__SubscriptionStatus__c,Subscription_Event__c from ccrz__E_Subscription__c WHERE Id=:subscriptionId];
            System.debug('###updateSubscription:  retrieved subscription items ' + subscriptionId);
            if (String.isNotBlank(subscriptionStatus)) {
                  subscription.ccrz__SubscriptionStatus__c = subscriptionStatus;
            }
            if (String.isNotBlank(subscriptionEvent)) {
                  subscription.Subscription_Event__c = subscriptionEvent;
            }
                    update subscription;            
        System.debug('subscription status updated');
        return true;
    }
    
    global static void updateSubscriptionDates(String orderId, DateTime startDate, DateTime endDate) {
       List<ccrz__E_Subscription__c> subscriptionItemList = [SELECT ID, Name, ccrz__SubscriptionStatus__c, Subscription_Event__c FROM ccrz__E_Subscription__c WHERE ccrz__SubscriptionId__c =: orderId ];
        for (ccrz__E_Subscription__c subscriptionItem : subscriptionItemList) {
          subscriptionItem.Subscription_End_Date__c = endDate;
         }
        update subscriptionItemList;   
       // Do we need update the endDate on order as well?
      //  ccrz__E_Order__c subscription = [SELECT ID, Name FROM ccrz__E_Order__c WHERE ID =: orderId LIMIT 1];
       // subscription.Subscription_End_Date__c = endDate;
       // update subscription;                                
    }
    
    global static void updatebillingDetails(String subscriptionId, String userLocale, String journeyType, String billingSubscriptionId, String billingSubscriptionNumber, String BillingAccountId) { 
       ccrz__E_Order__c subOrder = [SELECT ID, Locale__c,Subscription_Journey_Type__c, Billing_Subscription_ID__c, Billing_Account_ID__c FROM ccrz__E_Order__c WHERE ID =: subscriptionId];
        if (String.isNotBlank(userLocale)) {
	        subOrder.Locale__c = userLocale;        
        }
        if (String.isNotBlank(journeyType)) {
      		subOrder.Subscription_Journey_Type__c = journeyType;
        }
        if (String.isNotBlank(billingSubscriptionId)) {
	    	subOrder.Billing_Subscription_ID__c = billingSubscriptionId;
	        subOrder.Billing_Account_ID__c = BillingAccountId;
		}
        update subOrder;
        
           List<ccrz__E_Subscription__c> subscriptionItems = getSubscriptionItems(subscriptionId);
            for (ccrz__E_Subscription__c subscriptionItem : subscriptionItems) {
            if (String.isNotBlank(billingSubscriptionId)) {
                  subscriptionItem.Billing_Subscription_ID__c = billingSubscriptionId;
            }
            }        
            update subscriptionItems;
   
        
    } 
    
        global static void updatebillingAccountDetails(String subscriptionId, String userLocale, String journeyType, String billingAccountId) { 
       ccrz__E_Order__c subOrder = [SELECT ID, Locale__c,Subscription_Journey_Type__c, Billing_Account_ID__c FROM ccrz__E_Order__c WHERE ID =: subscriptionId];
        if (String.isNotBlank(userLocale)) {
	        subOrder.Locale__c = userLocale;        
        }
        if (String.isNotBlank(journeyType)) {
      		subOrder.Subscription_Journey_Type__c = journeyType;
        }
        if (String.isNotBlank(billingAccountId)) {
	        subOrder.Billing_Account_ID__c = billingAccountId;
		}
        update subOrder;

    }
    
    global Static void updatebillingSubscriptionDetails(String orderId, Map<String,List<SSBillingSubscriptionModel.subscriptionModel>>subscriptionMap) {
     List<ccrz__E_Subscription__c> ccSubscriptionList = [SELECT Id, Name,Billing_Subscription_ID__c,Subscription_Event__c,ccrz__Account__r.Id,
                                                         ccrz__SubscriptionStartDate__c,ccrz__SubscriptionProduct__r.ccrz__SKU__c,ccrz__SubscriptionProduct__r.Trial_Period_in_Days__c,Subscription_End_Date__c,ccrz__SubscriptionStatus__c,ccrz__CCOrder__r.Billing_Account_ID__c FROM ccrz__E_Subscription__c WHERE ccrz__CCOrder__r.Id =: orderId];  
        for (ccrz__E_Subscription__c ccSub: ccSubscriptionList){ 
            If(subscriptionMap != null){
            List<SSBillingSubscriptionModel.subscriptionModel> subModel = new List<SSBillingSubscriptionModel.subscriptionModel>();
              system.debug(subscriptionMap) ; 
                system.debug('product'+ccSub.ccrz__SubscriptionProduct__r.ccrz__SKU__c);
            subModel = subscriptionMap.get(ccSub.ccrz__SubscriptionProduct__r.ccrz__SKU__c);
                                System.debug('subModel2'+subModel);
            ccSub.Billing_Subscription_ID__c = subModel[0].billingSubscriptionId;
           // ccSub.ccrz__SubscriptionStartDate__c = subModel[0].billingStartDate;
            ccSub.Subscription_End_Date__c = subModel[0].billingSubscriptionEndDate;
               
                
                //Added to create Zuora Subsription and included order Id parameter
                If (subModel.Size() > 0){
               Zuora_Subscription__c zuoraSubscription = new Zuora_Subscription__c();
                    
               zuoraSubscription.Subscription_Product__c = ccSub.ccrz__SubscriptionProduct__r.ccrz__SKU__c;
               zuoraSubscription.Billing_Account_Id__c = ccSub.ccrz__CCOrder__r.Billing_Account_ID__c;
               zuoraSubscription.Zuora_Subscription_Id__c =subModel[0].billingSubscriptionId; 
               zuoraSubscription.Account__c =  ccSub.ccrz__Account__r.Id;   
               System.debug(subModel[0].billingSubscriptionNumber);     
               zuoraSubscription.Name =subModel[0].billingSubscriptionNumber;               
               insert zuoraSubscription;
               System.debug('inserted');     
            }
                
                System.debug('in 493');
         //   ccSub.ccrz__SubscriptionStatus__c = 'Active';
          //  ccSub.Subscription_Event__c ='New';
            } else {
                //Have to check a way how we get startDate for TrailProducts
            //    Date startdate = date.Today();
           // ccSub.ccrz__SubscriptionStartDate__c = subModel[0].billingStartDate;
                If (SSProductHelper.isTrailProduct (ccSub.ccrz__SubscriptionProduct__r.ccrz__SKU__c)){
              System.debug('Entered trail');      
          //  ccSub.Subscription_End_Date__c = ccSub.ccrz__SubscriptionStartDate__c+Integer.ValueOf(ccSub.ccrz__SubscriptionProduct__r.Trial_Period_in_Days__c);
          ccSub.Subscription_End_Date__c = System.Today().AddDays(Integer.ValueOf(ccSub.ccrz__SubscriptionProduct__r.Trial_Period_in_Days__c));
          
            ccSub.Is_Trial__c = true;        
                    }
                else {
                  ccSub.Subscription_End_Date__c = DateTime.valueOf(SSSubscription.SUBSCRIPTION_TERM_EVERGREEN);   
                }
            ccSub.ccrz__SubscriptionStatus__c = 'Active'; 
             ccSub.Subscription_Event__c ='New';
            
            }
            update ccSub;    
        }
        
    }
    
    global Static List<SSSubscriptionItemModel> getCCSubscriptionInfo (String orderId){
         List<SSSubscriptionItemModel> ccSubscriptionLst = new  List<SSSubscriptionItemModel>();
         List<ccrz__E_Subscription__c> ccSubscriptionList = [SELECT ID, Name, ccrz__SubscriptionProduct__r.Billing_Product_ID__c, ccrz__SubscriptionProduct__r.name, ccrz__SubscriptionProduct__r.ccrz__SKU__c, 
                    ccrz__SubscriptionProduct__r.ccrz__ShortDesc__c, ccrz__SubscriptionProduct__r.ccrz__LongDesc__c, 
                    ccrz__SubscriptionProduct__r.ID, ccrz__Storefront__c, ccrz__SubscriptionStartDate__c, ccrz__SPTInstallmentFrequencyUOM__c, 
                    ccrz__SPTInstallmentFrequency__c, ccrz__SPTInstallmentCount__c, ccrz__CurrencyISOCode__c, 
                    ccrz__CCOrder__c, ccrz__Account__r.Id, Product_Entitlement_Id__c , 
                      ccrz__SubscriptionStatus__c, ccrz__OrderStatus__c, 
                    Bundle_Product_Description__c, Bundle_Product_SKU__c, Tier_Description__c,Billing_Subscription_ID__c, Is_Trial__c , ccrz__RecurringPrice__c, 
                    Subscription_End_Date__c, Subscription_Event__c,ccrz__CCOrder__r.ccrz__Contact__r.Id FROM ccrz__E_Subscription__c WHERE ccrz__CCOrder__r.Id =: orderId];  
        for (ccrz__E_Subscription__c ccSub: ccSubscriptionList){ 
        SSSubscriptionItemModel itemModel = new SSSubscriptionItemModel();
         itemModel.subscriptionId =ccSub.ID;
     //itemModel.subscriptionItemId =  ;
      itemModel.bundleProductSKU = ccSub.Bundle_Product_SKU__c;   
      itemModel.bundleProductDescription = ccSub.Bundle_Product_Description__c;
      itemModel.tierDescription = ccSub.Tier_Description__c;
      itemModel.billingProductId = ccSub.ccrz__SubscriptionProduct__r.Billing_Product_ID__c;
      itemModel.billingSubscriptionId =ccSub.Billing_Subscription_ID__c;
      itemModel.currencyISOCode = ccSub.ccrz__CurrencyISOCode__c;
      itemModel.isTrial = ccSub.Is_Trial__c;
     // itemModel.recurringPrice = ccSub.
     // itemModel.entitlementId      
      itemModel.subscriptionStartDate = ccSub.ccrz__SubscriptionStartDate__c; 
      itemModel.subscriptionEndDate = ccSub.Subscription_End_Date__c;
      itemModel.productId = ccSub.ccrz__SubscriptionProduct__r.Id;
      itemModel.productSKU = ccSub.ccrz__SubscriptionProduct__r.ccrz__SKU__c;
      itemModel.productShortDescription = ccSub.ccrz__SubscriptionProduct__r.ccrz__ShortDesc__c;
      itemModel.productName = ccSub.ccrz__SubscriptionProduct__r.Name;
      itemModel.productLongDescription = ccSub.ccrz__SubscriptionProduct__r.ccrz__LongDesc__c;
      itemModel.accountId = ccSub.ccrz__Account__r.Id;
      itemModel.contactId = ccSub.ccrz__CCOrder__r.ccrz__Contact__r.Id;
          
    // itemModel.subscriptionTermType = ccSub. 
      itemModel.storefront = ccSub.ccrz__Storefront__c;
      itemModel.subscriptionStatus = ccSub.ccrz__SubscriptionStatus__c;
      itemModel.subscriptionEvent = ccSub.Subscription_Event__c;
      ccSubscriptionLst.add(itemModel);      
        }
        return ccSubscriptionLst;
    }
    
    global Static SSSubscriptionItemModel getCCSubscriptionById (String subscriptionId){
        SSSubscriptionItemModel ccSubscriptionModel = new  SSSubscriptionItemModel();
         ccrz__E_Subscription__c ccSubscription = [SELECT ID, Name, ccrz__SubscriptionProduct__r.Billing_Product_ID__c, ccrz__SubscriptionProduct__r.name, ccrz__SubscriptionProduct__r.ccrz__SKU__c, 
                    ccrz__SubscriptionProduct__r.ccrz__ShortDesc__c, ccrz__SubscriptionProduct__r.ccrz__LongDesc__c, 
                    ccrz__SubscriptionProduct__r.ID, ccrz__Storefront__c, ccrz__SubscriptionStartDate__c, ccrz__SPTInstallmentFrequencyUOM__c, 
                    ccrz__SPTInstallmentFrequency__c, ccrz__SPTInstallmentCount__c, ccrz__CurrencyISOCode__c, 
                    ccrz__CCOrder__c, ccrz__Account__r.Id, Product_Entitlement_Id__c , 
                      ccrz__SubscriptionStatus__c, ccrz__OrderStatus__c,ccrz__CCOrder__r.ccrz__OriginatedCart__c,ccrz__CCOrder__r.Billing_Account_ID__c, 
                    Bundle_Product_Description__c, Bundle_Product_SKU__c, Tier_Description__c,Billing_Subscription_ID__c, Is_Trial__c , ccrz__RecurringPrice__c, 
                    Subscription_End_Date__c, Subscription_Event__c,ccrz__CCOrder__r.ccrz__Contact__r.Id  FROM ccrz__E_Subscription__c WHERE Id =: subscriptionId];  
      
        
      String cartId =ccSubscription.ccrz__CCOrder__r.ccrz__OriginatedCart__c;
        SSCartModel cart = SSCartHelper.getCartBySFID(cartId);
        ccSubscriptionModel.cart = cart;   
        
       ccSubscriptionModel.subscriptionId =ccSubscription.ID;    
     //itemModel.subscriptionItemId =  ;
      ccSubscriptionModel.bundleProductSKU = ccSubscription.Bundle_Product_SKU__c;   
      ccSubscriptionModel.bundleProductDescription = ccSubscription.Bundle_Product_Description__c;
      ccSubscriptionModel.tierDescription = ccSubscription.Tier_Description__c;
      ccSubscriptionModel.billingProductId = ccSubscription.ccrz__SubscriptionProduct__r.Billing_Product_ID__c;
      ccSubscriptionModel.billingSubscriptionId =ccSubscription.Billing_Subscription_ID__c;
      ccSubscriptionModel.currencyISOCode = ccSubscription.ccrz__CurrencyISOCode__c;
      ccSubscriptionModel.isTrial = ccSubscription.Is_Trial__c;
     // itemModel.recurringPrice = ccSub.
     // itemModel.entitlementId      
      ccSubscriptionModel.subscriptionStartDate = ccSubscription.ccrz__SubscriptionStartDate__c; 
      ccSubscriptionModel.subscriptionEndDate = ccSubscription.Subscription_End_Date__c;
      ccSubscriptionModel.productId = ccSubscription.ccrz__SubscriptionProduct__r.Id;
      ccSubscriptionModel.productSKU = ccSubscription.ccrz__SubscriptionProduct__r.ccrz__SKU__c;
      ccSubscriptionModel.productShortDescription = ccSubscription.ccrz__SubscriptionProduct__r.ccrz__ShortDesc__c;
      ccSubscriptionModel.productName = ccSubscription.ccrz__SubscriptionProduct__r.Name;
      ccSubscriptionModel.productLongDescription = ccSubscription.ccrz__SubscriptionProduct__r.ccrz__LongDesc__c;
      ccSubscriptionModel.accountId = ccSubscription.ccrz__Account__r.Id;
      ccSubscriptionModel.contactId = ccSubscription.ccrz__CCOrder__r.ccrz__Contact__r.Id;
    // itemModel.subscriptionTermType = ccSub. 
      ccSubscriptionModel.storefront = ccSubscription.ccrz__Storefront__c;
      ccSubscriptionModel.subscriptionStatus = ccSubscription.ccrz__SubscriptionStatus__c;
      ccSubscriptionModel.subscriptionEvent = ccSubscription.Subscription_Event__c;
      ccSubscriptionModel.billingAccountId = ccSubscription.ccrz__CCOrder__r.Billing_Account_ID__c;
     
        return ccSubscriptionModel;
    }
    
    global Static Void updateDetailsOnNewCart(SSSubscriptionItemModel parentSubscription,String newCartId){
         SSCartModel parentCartModel = parentSubscription.cart; 
       ccrz__E_Cart__c cart = SSCartHelper.getCartByEncryptedId(newCartId);
        cart.ccrz__Name__c = parentCartModel.cartNumber + ' - Product Regrade';
        cart.ccrz__CartId__c = newCartId;
        cart.Locale__c = parentCartModel.cartLocaleId;
        cart.Parent_Cart__c = parentCartModel.sfId;
        cart.VAT_Number__c = parentCartModel.vatNumber;
        cart.Tax_Code__c = parentCartModel.taxCode;
        cart.ccrz__CurrencyISOCode__c = parentCartModel.currencyCode;
      //  cart.ccrz__Storefront__c = parentCartModel.storefront;
        update cart; 
    }  
          

}