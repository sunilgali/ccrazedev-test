@RestResource(urlMapping='/SSSubscriptionRestService')
global class SSSubscriptionRestService {    
    /*
     * This Service is responsible for retrieving the Subscription
     * details for the Conversion of Trail to Buy
     */ 
     @HttpPost
     global static SSSubscriptionModel createCCSubscription(String cartId, DateTime subscriptionStartDate, String paymentReferenceID,
                                                           String paymentType, SSPaymentDetailsModel paymentDetails) {    
                                                           
        system.debug('ENTER');
                                                                
        SSSubscriptionModel subscriptionModel = new SSSubscriptionModel();    
        SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
        List<SSSubscriptionItemModel> ccSubscriptionLst = new  List<SSSubscriptionItemModel>();                                                       
        try {            
          ccrz__E_Cart__c cart = SScartHelper.getCartByEncryptedId(cartId);
       //  String transactionType =  cart.Transaction_Type__c;
        
         String localeName = cart.Locale__r.Name;
         String locale = cart.Locale__c;    
         String currencyCode = cart.ccrz__CurrencyISOCode__c;  
         SSAccountModel account = new SSAccountModel();
         account.accountId = cart.ccrz__Account__r.Id;
         account.accountName = cart.ccrz__Account__r.Name; 
            
         SSContactModel contact = new SSContactModel();   
         contact.firstName = cart.ccrz__Contact__r.FirstName;
         contact.lastName =cart.ccrz__Contact__r.LastName;
         contact.email = cart.ccrz__Contact__r.email;
         contact.phone = cart.ccrz__Contact__r.phone;
            
       //Address Details
        SSAddressModel address = new SSAddressModel();
        address.streetAddress =cart.ccrz__Contact__r.MailingStreet;     
        address.city = cart.ccrz__Contact__r.MailingCity;                                                                  
        address.state = cart.ccrz__Contact__r.MailingState;
        address.country = cart.ccrz__Contact__r.MailingCountry;
        address.postalCode= cart.ccrz__Contact__r.MailingPostalCode;
        contact.address = address;
                
        // Instead of checking on cart transaction type, assuming if cart a combination of trail and buy products, call the billing engine    
        Boolean billingAccountRequired = SSCartHelper.isBillingAccountRequired(cartId);  
          System.debug('billingAccountRequired'+billingAccountRequired);   
        If (billingAccountRequired) {  
         System.debug('billingAccountRequired'+billingAccountRequired);   
         billingModel = SSCartHelper.createBillingSubscription(cartId,account, contact,subscriptionStartDate,currencyCode,localeName,paymentReferenceID,
                                                          paymentType,paymentDetails);
         }
      
        System.debug('###########billingModel'+billingModel);    
        System.debug('locale'+locale);    
        String orderId = SScartHelper.createCCOrder(cartId);
        System.debug('CCSubscriptionId'+orderId); 
           
      // If (billingAccountRequired)  {  
         // Update Billing Account details on to the order Object
         // ??????????? What would be the journeyType on the order??????????
         SSSubscriptionHelper.updatebillingAccountDetails(orderId,locale,'',billingModel.billingAccountId);
       
         //Update the Billing subscription details on to the CC Subscription Object , The subscription start date and end date are updated 
         //for a buy transaction on the CC Subscription Object  
      SSSubscriptionHelper.updatebillingSubscriptionDetails(orderId,billingModel.subscriptionMap);
       
      ccSubscriptionLst = SSSubscriptionHelper.getCCSubscriptionInfo (orderId);  
            
   //     }
           // Put in code to update the sub end date and substart date for trail products
           // How do we add return the SSSubModel if we have more than one billing subscription?
               
      // Date trailEndDate = subscriptionStartDate +           
       // SSSubscriptionHelper.updateSubscriptionDates(subscriptionId, null, endDate);  
            subscriptionModel.setStatus(true);
            subscriptionModel.account = account;
            subscriptionModel.contact =contact;
            subscriptionModel.orderId = orderId;
            //subscriptionModel.storefront = cart.storefront;
            
          //  subscriptionModel.billingAccountId = billingModel.billingAccountId;
           subscriptionModel.subscribedProducts = ccSubscriptionLst;
            
           // subscriptionModel.billingSubscriptionId = billingModel.billingSubscriptionId;
         //   subscriptionModel.subscriptionId = subscriptionId;
         //   subscriptionModel.subscriptionStartDate = subscriptionStartDate;
         //   subscriptionModel.subscriptionEndDate = subscriptionEndDate; 
           System.debug('###SSSubscriptinModel'+subscriptionModel);
            return subscriptionModel;
        }
        catch (SSCartException ex) {
            System.debug('SSSubscriptionService: createSubscription: cart exception ' + ex.getMessage());
            subscriptionModel.setErrorMessage(ex.getMessage());
            subscriptionModel.setStatus(false);
        }
        catch (SSSubscriptionException ex) {
            System.debug('SSSubscriptionService: createSubscription: subscription exception ' + ex.getMessage());
            subscriptionModel.setErrorMessage(ex.getMessage());
            subscriptionModel.setStatus(false);
        }
        return subscriptionModel;
    }  
    
    global static SSSubscriptionModel convertSubscription(String parentSubscriptionId,String cartId, String paymentReferenceID,
                                                           String paymentType, SSPaymentDetailsModel paymentDetails,String transactionType, DateTime subscriptionStartDate)
    {        
        SSSubscriptionRegradeModel subscriptionRegradeModel = new SSSubscriptionRegradeModel();    
        SSBillingSubscriptionModel billingModel = new SSBillingSubscriptionModel();
          List<SSSubscriptionItemModel> ccSubscriptionLst = new  List<SSSubscriptionItemModel>();  
        SSSubscriptionModel subscriptionModel = new SSSubscriptionModel();
        
        try {            
   
            subscriptionModel = SSSubscriptionHelper.getSubscription(parentSubscriptionId);
           // System.debug('SSSubscriptionRegradeService: convertSubscription: parentSubscription ' + parentSubscription);
            
          subscriptionRegradeModel.parentSubscription = subscriptionModel;
          SSCartModel parentCartModel = subscriptionModel.cart;
         ccrz__E_Cart__c cart = SScartHelper.getCartByEncryptedId(cartId);
      //   String transactionType =  cart.Transaction_Type__c;
         String locale = cart.Locale__r.Name;
         String currencyCode = cart.ccrz__CurrencyISOCode__c;  
         SSAccountModel account = new SSAccountModel();
         account.accountId = cart.ccrz__Account__r.Id;
         account.accountName = cart.ccrz__Account__r.Name; 
            
         SSContactModel contact = new SSContactModel();   
         contact.firstName = cart.ccrz__Contact__r.FirstName;
         contact.lastName =cart.ccrz__Contact__r.LastName;
         contact.email = cart.ccrz__Contact__r.email;
         contact.phone = cart.ccrz__Contact__r.phone;
            
       //Address Details
        SSAddressModel address = new SSAddressModel();
        address.streetAddress =cart.ccrz__Contact__r.MailingStreet;     
        address.city = cart.ccrz__Contact__r.MailingCity;                                                                  
        address.state = cart.ccrz__Contact__r.MailingState;
        address.country = cart.ccrz__Contact__r.MailingCountry;
        address.postalCode= cart.ccrz__Contact__r.MailingPostalCode;
        contact.address = address;
         
            Boolean billingAccountRequired = SScartHelper.isBillingAccountRequired(cartId);  
            
        If (billingAccountRequired) {  
          billingModel = SSCartHelper.createBillingSubscription(cartId,account,contact,subscriptionStartDate,currencyCode,locale,paymentReferenceID,
                                                          paymentType,paymentDetails);
   }
            
            //retrieve the New Cart and update the Account, Contact, Lead and Opportunity information            
            //cartManager.updateAccountAndLead(cartId, parentCartModel.accountId, parentCartModel.contactId, parentCartModel.leadId, 
            //                                 parentCartModel.opportunityId, TetrisCart.CART_TRANSACTION_TYPE_CONVERT, parentCartModel.sfId, parentCartModel.vatNumber);            
            //cartManager.updateCartWithPaymentDetails(cartId, zuoraSubscriptionId, zuoraSubscriptionNumber, paymentId);
            
            //create the new subscription
            String convertedOrderIdId = SSCartHelper.createCCOrder(cartId);            
          //  ssSubModel.orderId = convertedSubscriptionId;            
        //    String userIdentityId = parentCartModel.userIdentityId;

           //SSSubscriptionHelper.updateConvertedSubscriptionAsync(convertedSubscriptionId, cartId, subscriptionId, parentCartModel.userIdentityId, 
            //                                                            slcsSubscriptionId,  slcsSubscriptionGroupId,
             //                                                             slcsClientRef, entitlementId, activityId, parentCartModel.cartLocaleId,
           //                                           zuoraSubscriptionId, zuoraSubscriptionNumber);
            
        //update SLCS details on Cart
        //System.debug('SSSubscriptionService: createSubscription: Cart Id - ' + cartId + ', User Identity Id - ' + userIdentityId + ', SLCS Subscription Id - ' + slcsSubscriptionId +  ', SLCS Subscription Group Id - ' + slcsSubscriptionGroupId + ', SLCS Client Ref - ' + slcsClientRef + ', Entitlement Id - ' + entitlementId + ', Activity Id - ' + activityId);
     //   SSCartHelper.updateSLCSDetailsOnCart(cartId, userIdentityId, slcsSubscriptionId, slcsSubscriptionGroupId, slcsClientRef,  entitlementId, activityId);
        //cartManager.updateCartWithZuoraDetails(convertedCartId, zuoraSubscriptionId, zuoraSubscriptionNumber);            
    
        //update slcs details for the new (converted) subscription
     //   SSSubscriptionHelper.updateSubscription(convertedSubscriptionId, entitlementId, slcsClientRef, slcsSubscriptionGroupId, slcsSubscriptionId);
            
        //update subscription status for the old subscription (try)                        
        SSSubscriptionHelper.updateSubscriptionStatus(parentSubscriptionId, SSSubscription.SUBSCRIPTION_STATUS_CONVERTED, SSSubscription.SUBSCRIPTION_EVENT_CONVERT, true);
        //Status of the New subscription should not be updated but Event should be
        SSSubscriptionHelper.updateSubscriptionStatus(convertedOrderIdId, '', SSSubscription.SUBSCRIPTION_EVENT_CONVERT, true);

        //SSSubscriptionHelper.updateZuoraDetails(convertedSubscriptionId, parentCartModel.cartLocaleId, 
                                                   //SSCartHelper.CART_TRANSACTION_TYPE_CONVERT, zuoraSubscriptionId, zuoraSubscriptionNumber);
            
      SSSubscriptionHelper.updatebillingAccountDetails(convertedOrderIdId,locale,'',billingModel.billingAccountId);
       
         //Update the Billing subscription details on to the CC Subscription Object , The subscription start date and end date are updated 
         //for a buy transaction on the CC Subscription Object  
      SSSubscriptionHelper.updatebillingSubscriptionDetails(convertedOrderIdId,billingModel.subscriptionMap);
       
      ccSubscriptionLst = SSSubscriptionHelper.getCCSubscriptionInfo (convertedOrderIdId);  
            
   //     }
           // Put in code to update the sub end date and substart date for trail products
           // How do we add return the SSSubModel if we have more than one billing subscription?
               
      // Date trailEndDate = subscriptionStartDate +           
       // SSSubscriptionHelper.updateSubscriptionDates(subscriptionId, null, endDate);  
            subscriptionModel.setStatus(true);
            subscriptionModel.account = account;
            subscriptionModel.contact =contact;
            subscriptionModel.orderId = convertedOrderIdId;
            //subscriptionModel.storefront = cart.storefront;
            
          //  subscriptionModel.billingAccountId = billingModel.billingAccountId;
           subscriptionModel.subscribedProducts = ccSubscriptionLst;
            
           // subscriptionConvertRequest.setStatus(true);                        
           // return subscriptionConvertRequest;
        }
        catch (SSCartException ex) {
            System.debug('SSSubscriptionRegradeService: convertSubscription: cart exception ' + ex.getMessage());
            subscriptionRegradeModel.setErrorMessage(ex.getMessage());
            subscriptionRegradeModel.setStatus(false);
        }
        catch (SSSubscriptionException ex) {
            System.debug('SSSubscriptionRegradeService: convertSubscription: subscription exception ' + ex.getMessage());
            subscriptionRegradeModel.setErrorMessage(ex.getMessage());
            subscriptionRegradeModel.setStatus(false);
        }
        return subscriptionModel;
    }  
     global static SSSubscriptionModel crossSellSubscription(String parentSubscriptionId, List<SSCartItemModel> newCartItems,String regradeType)
    {        
        SSSubscriptionModel subscriptionModel = new SSSubscriptionModel();

        //SSSubscriptionHelper subscriptionManager = new SSSubscriptionHelper();
        SSCartHelper cartManager = new SSCartHelper();
        Map<String, String> subscriptionEvent = getSubscriptionEvent(regradeType);
        
         
        String newSubscriptionStatus = (String)subscriptionEvent.get('newSubscriptionStatus');
        String newSubscriptionEvent = (String)subscriptionEvent.get('newSubscriptionEvent');
        String parentSubscriptionStatus = (String)subscriptionEvent.get('parentSubscriptionStatus');
        String parentSubscriptionEvent = (String)subscriptionEvent.get('parentSubscriptionEvent');
        
        try {            
            //Step 1 - Retrieve info from Parent Subscription
            System.debug('SSSubscriptionRegradeService: regradeSubscription: enter');
            //retrieve the Cart ID, User Identity Id, Account ID, Contact Id, Lead Id, Opportunity ID tied to the old subscription id
            subscriptionModel.parentSubscription = SSSubscriptionHelper.getSubscription(parentSubscriptionId);
            System.debug('SSSubscriptionRegradeService: regradeSubscription: parentSubscription ' + subscriptionModel.parentSubscription);
                  
            Map<String, Object> crossSellRegradeCart = createNewCart( subscriptionModel.parentSubscription, newCartItems, regradeType, cartManager);  
            String crossSellCartId = (String)crossSellRegradeCart.get('cartId');
            String crossSellCartSfId = (String)crossSellRegradeCart.get('cartSfId');
            SSCartModel parentCartModel = (SSCartModel)crossSellRegradeCart.get('parentCart');
            String parentCartId = parentCartModel.cartId;
            
        //    addCoupon(crossSellCartId, newCartItems, parentCartModel.cartLocale, parentCartModel.currencyCode);
            //applyTax(regradedCartId, companyCode, 
                   //  customerCode, parentCartModel.country,
                             //  parentCartModel.taxCode, parentCartModel.vatNumber);
            //createLead(regradedCartId, newCartItems, parentCartModel, regradeType, cartManager, parentCartId); 
                        
            //create the new subscription
            String crossSellOrderId = SSCartHelper.createCCOrder(crossSellCartId);    
            System.debug('SSSubscriptionRegradeService: regradeSubscription: regradedSubscriptionId ' + crossSellOrderId);
                                   
        //    String zuoraAccountId = '';
          //  String zuoraAccountZuoraId = '';
           // String zuoraSubscriptionId = '';
            /*
            if ((parentSubscription.billing != null) && (String.isNotBlank(parentSubscription.billing.zuoraAccountId))) {
                zuoraAccountId = parentSubscription.billing.zuoraAccountId;
                zuoraAccountZuoraId = parentSubscription.billing.zuoraAccountZuoraId;
            }
            if (String.isNotBlank(parentCartModel.zuoraSubscriptionId)) {
                zuoraSubscriptionId = parentCartModel.zuoraSubscriptionId;
                if (String.isBlank(zuoraAccountId)) {
                    try {
                    Zuora__Subscription__c zuoraSubscription = subscriptionManager.getZuoraSubscription(zuoraSubscriptionId);
                    zuoraAccountZuoraId = zuoraSubscription.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c;
                    zuoraAccountId = zuoraSubscription.Zuora__Account__r.ID;
                    }
                    catch (Exception ex) {
                        System.debug('Exception retrieving Zuora Account for Subsctiption ' + zuoraSubscriptionId + ', ' + ex.getMessage());
                    }
                }
            }
            //return response
            subscriptionUpgradeRequest.zuoraAccountId = zuoraAccountId;
            subscriptionUpgradeRequest.zuoraAccountZuoraId = zuoraAccountZuoraId;
            //subscriptionUpgradeRequest.provisionResponse = provisionResponse;
            subscriptionUpgradeRequest.SSSubscriptionId = regradedSubscriptionId;
            subscriptionUpgradeRequest.slcsSubscriptionId = parentCartModel.slcsSubscriptionId;
            subscriptionUpgradeRequest.zuoraSubscriptionId = zuoraSubscriptionId;
            */
            subscriptionModel.cart.cartId = crossSellCartId;
         //   subscriptionUpgradeRequest.parentSubscription = parentSubscription;

            subscriptionModel.setStatus(true);
            
            
            //SSSubscriptionHelper.updateRegradeUpdateInitAsync( regradedSubscriptionId,  parentSubscriptionId,  newSubscriptionStatus, 
            //                                            newSubscriptionEvent,  parentSubscriptionStatus, 
            //                                            parentSubscriptionEvent);
            
                        //update new subscription status
            SSSubscriptionHelper.updateSubscriptionStatus(crossSellOrderId, newSubscriptionStatus, newSubscriptionEvent, true);
            //update parent subscription status
            SSSubscriptionHelper.updateSubscriptionStatus(parentSubscriptionId, parentSubscriptionStatus, parentSubscriptionEvent, true);

            return subscriptionModel;
        }
        catch (SSCartException ex) {
            System.debug('SSSubscriptionRegradeService: regradeSubscription: cart exception ' + ex.getMessage());
            subscriptionModel.setErrorMessage(ex.getMessage());
            subscriptionModel.setStatus(false);
        }
        catch (SSSubscriptionException ex) {
            System.debug('SSSubscriptionRegradeService: regradeSubscription: subscription exception ' + ex.getMessage());
            subscriptionModel.setErrorMessage(ex.getMessage());
            subscriptionModel.setStatus(false);
        }
        return subscriptionModel;
    } 
     
  
/*  global static SSSubscriptionModel convertSubscription(String subscriptionId) {
       SSSubscriptionModel parentSubscription = SSSubscriptionHelper.getSubscription(subscriptionId);
            SSCartModel parentCartModel = parentSubscription.cart;
            
   /*    global static SSSubscriptionModel createCCSubscription(String cartId, DateTime subscriptionStartDate,
                                                  DateTime subscriptionEndDate,String currencyCode, String locale, String paymentReferenceID,
                                                           String paymentType, SSPaymentDetailsModel paymentDetails)   */  
            //retrieve the New Cart and update the Account, Contact, Lead and Opportunity information            
            //cartManager.updateAccountAndLead(cartId, parentCartModel.accountId, parentCartModel.contactId, parentCartModel.leadId, 
            //                                 parentCartModel.opportunityId, TetrisCart.CART_TRANSACTION_TYPE_CONVERT, parentCartModel.sfId, parentCartModel.vatNumber);            
            //cartManager.updateCartWithPaymentDetails(cartId, zuoraSubscriptionId, zuoraSubscriptionNumber, paymentId);
            
            //create the new subscription
      //      String convertedSubscriptionId = SSCartHelper.createCCOrder(cartId);            
        //    ssSubModel.orderId = convertedSubscriptionId;            
          //  String userIdentityId = parentCartModel.userIdentityId;

           //SSSubscriptionHelper.updateConvertedSubscriptionAsync(convertedSubscriptionId, cartId, subscriptionId, parentCartModel.userIdentityId, 
            //                                                            slcsSubscriptionId,  slcsSubscriptionGroupId,
             //                                                             slcsClientRef, entitlementId, activityId, parentCartModel.cartLocaleId,
           //                                           zuoraSubscriptionId, zuoraSubscriptionNumber);
            
        //update SLCS details on Cart
        //System.debug('SSSubscriptionService: createSubscription: Cart Id - ' + cartId + ', User Identity Id - ' + userIdentityId + ', SLCS Subscription Id - ' + slcsSubscriptionId +  ', SLCS Subscription Group Id - ' + slcsSubscriptionGroupId + ', SLCS Client Ref - ' + slcsClientRef + ', Entitlement Id - ' + entitlementId + ', Activity Id - ' + activityId);
        //SSCartHelper.updateSLCSDetailsOnCart(cartId, userIdentityId, slcsSubscriptionId, slcsSubscriptionGroupId, slcsClientRef,  entitlementId, activityId);
        //cartManager.updateCartWithZuoraDetails(convertedCartId, zuoraSubscriptionId, zuoraSubscriptionNumber);            
    
        //update slcs details for the new (converted) subscription
      //  SSSubscriptionHelper.updateSubscription(convertedSubscriptionId, entitlementId, slcsClientRef, slcsSubscriptionGroupId, slcsSubscriptionId);
            
        //update subscription status for the old subscription (try)                        
       // SSSubscriptionHelper.updateSubscriptionStatus(subscriptionId, SSSubscription.SUBSCRIPTION_STATUS_CONVERTED, SSSubscription.SUBSCRIPTION_EVENT_CONVERT, true);
        //Status of the New subscription should not be updated but Event should be
        //SSSubscriptionHelper.updateSubscriptionStatus(convertedSubscriptionId, '', SSSubscription.SUBSCRIPTION_EVENT_CONVERT, true);

        //SSSubscriptionHelper.updateZuoraDetails(convertedSubscriptionId, parentCartModel.cartLocaleId, 
                                                   //SSCartHelper.CART_TRANSACTION_TYPE_CONVERT, zuoraSubscriptionId, zuoraSubscriptionNumber);
            
     /*   Date endDate = Date.valueOf(SSSubscription.SUBSCRIPTION_TERM_EVERGREEN);            
        SSSubscriptionHelper.updateSubscriptionDates(convertedSubscriptionId, null, endDate);             
        System.debug('SSSubscriptionConversionService: updated subscription order ' + convertedSubscriptionId);
        
                                                           }
    
    */

    /*
     * This Service is invoked to 
     *      - update details (SLCS and Zuora info) on the CC Cart supporting the Conversion Journey 
     *      - update Lead
     *      - create a New Subscription
     *      - update details (SLCS and Zuora info) on the New Subscription Object
     */ 
    
    global static SSSubscriptionModel updateSubscription(String cartId, String subscriptionId, String paymentId, 
                                                                String slcsSubscriptionId, String slcsSubscriptionGroupId, 
                                                                String slcsClientRef, String entitlementId, String activityId, 
                                                                String zuoraSubscriptionId, String zuoraSubscriptionNumber)
    {        
        SSSubscriptionModel ssSubModel = new SSSubscriptionModel();             
        //SSCartHelper cartManager = new SSCartHelper();
        //SSSubscriptionHelper SSSubscriptionHelper = new SSSubscriptionHelper();
        System.debug('SSSubscriptionConversionService: convertSubscription: zuoraSubscriptionId ' + zuoraSubscriptionId);        
        System.debug('SSSubscriptionConversionService: convertSubscription: zuoraSubscriptionNumber ' + zuoraSubscriptionNumber);        
        System.debug('SSSubscriptionConversionService: convertSubscription: parent subscriptionId ' + subscriptionId);        
        
        try {
            SSSubscriptionModel parentSubscription = SSSubscriptionHelper.getSubscription(subscriptionId);
            SSCartModel parentCartModel = parentSubscription.cart;
            
            //retrieve the New Cart and update the Account, Contact, Lead and Opportunity information            
            //cartManager.updateAccountAndLead(cartId, parentCartModel.accountId, parentCartModel.contactId, parentCartModel.leadId, 
            //                                 parentCartModel.opportunityId, TetrisCart.CART_TRANSACTION_TYPE_CONVERT, parentCartModel.sfId, parentCartModel.vatNumber);            
            //cartManager.updateCartWithPaymentDetails(cartId, zuoraSubscriptionId, zuoraSubscriptionNumber, paymentId);
            
            //create the new subscription
            String convertedSubscriptionId = SSCartHelper.createCCOrder(cartId);            
            ssSubModel.orderId = convertedSubscriptionId;            
            String userIdentityId = parentCartModel.userIdentityId;

           //SSSubscriptionHelper.updateConvertedSubscriptionAsync(convertedSubscriptionId, cartId, subscriptionId, parentCartModel.userIdentityId, 
            //                                                            slcsSubscriptionId,  slcsSubscriptionGroupId,
             //                                                             slcsClientRef, entitlementId, activityId, parentCartModel.cartLocaleId,
           //                                           zuoraSubscriptionId, zuoraSubscriptionNumber);
            
        //update SLCS details on Cart
        //System.debug('SSSubscriptionService: createSubscription: Cart Id - ' + cartId + ', User Identity Id - ' + userIdentityId + ', SLCS Subscription Id - ' + slcsSubscriptionId +  ', SLCS Subscription Group Id - ' + slcsSubscriptionGroupId + ', SLCS Client Ref - ' + slcsClientRef + ', Entitlement Id - ' + entitlementId + ', Activity Id - ' + activityId);
        SSCartHelper.updateSLCSDetailsOnCart(cartId, userIdentityId, slcsSubscriptionId, slcsSubscriptionGroupId, slcsClientRef,  entitlementId, activityId);
        //cartManager.updateCartWithZuoraDetails(convertedCartId, zuoraSubscriptionId, zuoraSubscriptionNumber);            
    
        //update slcs details for the new (converted) subscription
        SSSubscriptionHelper.updateSubscription(convertedSubscriptionId, entitlementId, slcsClientRef, slcsSubscriptionGroupId, slcsSubscriptionId);
            
        //update subscription status for the old subscription (try)                        
        SSSubscriptionHelper.updateSubscriptionStatus(subscriptionId, SSSubscription.SUBSCRIPTION_STATUS_CONVERTED, SSSubscription.SUBSCRIPTION_EVENT_CONVERT, true);
        //Status of the New subscription should not be updated but Event should be
        SSSubscriptionHelper.updateSubscriptionStatus(convertedSubscriptionId, '', SSSubscription.SUBSCRIPTION_EVENT_CONVERT, true);

        //SSSubscriptionHelper.updateZuoraDetails(convertedSubscriptionId, parentCartModel.cartLocaleId, 
                                                   //SSCartHelper.CART_TRANSACTION_TYPE_CONVERT, zuoraSubscriptionId, zuoraSubscriptionNumber);
            
        Date endDate = Date.valueOf(SSSubscription.SUBSCRIPTION_TERM_EVERGREEN);            
        SSSubscriptionHelper.updateSubscriptionDates(convertedSubscriptionId, null, endDate);             
        System.debug('SSSubscriptionConversionService: updated subscription order ' + convertedSubscriptionId);
        
        }
        catch (SSCartException ex) {
            ssSubModel.setErrorMessage(ex.getMessage());
            ssSubModel.setStatus(false);
        }
        catch (SSSubscriptionException ex) {
            ssSubModel.setErrorMessage(ex.getMessage());
            ssSubModel.setStatus(false);
        }
        return ssSubModel;
    }  
    
        /*
     * This service returns the Subscription details for Cancellation
     */
    
    global static SSSubscriptionModel getSubscription(String subscriptionId, List<String> subscriptionItemIds)
    {        
        SSSubscriptionModel objSubscription = new SSSubscriptionModel();             
        //SSSubscriptionHelper SSSubscriptionHelper = new SSSubscriptionHelper();
        try {
            System.debug('SSSubscriptionCancellationService: getSubscriptionDetailsForCancellation: subscriptionId ' + subscriptionId);
            //retrieve the current subscription details
            SSSubscriptionHelper.getSubscription(subscriptionId);                
            //check if all items in the subscription are selected for Cancellation
            if (subscriptionItemIds != null) {
                List<SSSubscriptionItemModel> selectedProductList = new List<SSSubscriptionItemModel>();
                for (String subscriptionItemId :  subscriptionItemIds) {
                    for (SSSubscriptionItemModel selectedProduct : objSubscription.subscribedProducts) {
                        if (selectedProduct.subscriptionItemId.equals(subscriptionItemId)) {
                            
                            selectedProductList.add(selectedProduct);
                        }
                    }
                }
                System.debug('SSSubscriptionCancellationService: getSubscriptionDetailsForCancellation: Products selected for Cancellation ' + selectedProductList);
                objSubscription.subscribedProducts = selectedProductList;
            }
            
            //retrieve the SLCS Subscription IDs corresponding to the Product Selected
            //the products might be part of the same SLCS Subscription or different SLCS Subscriptions
           List<String> slcsSubscriptionIdList = new List<String>();
            String slcsIds = '';
            /*
            for (SSSubscriptionItemModel subscriptionProduct: objSubscription.subscribedProducts) {
                if (slcsIds.indexOf(subscriptionProduct.slcsSubscriptionId) < 0) {
                    slcsIds += subscriptionProduct.slcsSubscriptionId + ',';
                    slcsSubscriptionIdList.add(subscriptionProduct.slcsSubscriptionId);                   
                }
            }
            SSSubscription.slcsSubscriptionIdList = slcsSubscriptionIdList;
            System.debug('SSSubscriptionCancellationService: getSubscriptionDetailsForCancellation: slcsSubscriptionIdList ' + slcsSubscriptionIdList);
            System.debug('SSSubscriptionCancellationService: getSubscriptionDetailsForCancellation: zuoraAccountId ' + SSSubscription.billing.zuoraAccountZuoraId);
            SSSubscription.zuoraAccountId = SSSubscription.billing.zuoraAccountZuoraId;                                                    
            String zuoraSubscriptionSFID = SSSubscription.zuoraSubscriptionSFID;
                            */
            //determine if the current subscription is a Trial or a Buy 
            //based on a Zuora Subscription being associated with it
            /*
            if (String.isNotBlank(zuoraSubscriptionSFID)) {
                SSSubscription.isTrial = false;
            }
            else {
                SSSubscription.isTrial = true;                
            }   
            */
            objSubscription.setStatus(true);
        }
        catch (SSCartException ex) {
            objSubscription.setErrorMessage(ex.getMessage());
            objSubscription.setStatus(false);
        } 
        catch (SSSubscriptionException ex) {
            objSubscription.setErrorMessage(ex.getMessage());
            objSubscription.setStatus(false);
        }
        return objSubscription;
    }             
    
    
    global static SSSubscriptionModel updateSubscription(String subscriptionId, 
                                                                String zuoraSubscriptionId, String zuoraSubscriptionNumber, 
                                                                String cancellationDate)
    {        
        SSSubscriptionModel ssSubModel = new SSSubscriptionModel();             
        //SSSubscriptionHelper SSSubscriptionHelper = new SSSubscriptionHelper();
        SSCartHelper cartManager = new SSCartHelper();
        try {
            ssSubModel = SSSubscriptionHelper.getSubscription(subscriptionId);            
            SSCartModel cart = ssSubModel.cart; 
            String cartId = cart.cartId;
            System.debug('TetrisSubCancelUpdateService: updateSubscription: cancellationDate ' + cancellationDate);

            String subscriptionStatus = '';
            String subscriptionEvent = '';
            
            if (Date.valueOf(cancellationDate) > Date.today()) {
                subscriptionStatus = SSSubscription.SUBSCRIPTION_STATUS_CANCELLATION_SCHEDULED;  
            }
            else {
                subscriptionStatus = SSSubscription.SUBSCRIPTION_STATUS_CANCELLATION_COMPLETED;                                
            }
            
            subscriptionEvent = SSSubscription.SUBSCRIPTION_EVENT_CANCEL;
            //SSSubscriptionHelper.updateCancelledSubscriptionAsync(subscriptionId, cartId,  zuoraSubscriptionId, 
            //                                            zuoraSubscriptionNumber, cancellationDate, 
             //                                          subscriptionStatus, subscriptionEvent) ;          
                  //  cartManager.updateCartWithZuoraDetails(cartId, zuoraSubscriptionId, zuoraSubscriptionNumber);            
            
        //update subscription for the new (regraded) subscription
        //SSSubscriptionHelper.updateZuoraDetails(subscriptionId, null, null, zuoraSubscriptionId, zuoraSubscriptionNumber); 
        SSSubscriptionHelper.updateSubscriptionDates(subscriptionId, null, Date.valueOf(cancellationDate));
        SSSubscriptionHelper.updateSubscriptionStatus(subscriptionId, subscriptionStatus, subscriptionEvent, true);  
        /*
        if (subscriptionStatus.equalsIgnoreCase(SSSubscription.SUBSCRIPTION_STATUS_CANCELLATION_SCHEDULED)) {
            Tetris_Subscription_Job__c subscriptionJob = new Tetris_Subscription_Job__c();
            subscriptionJob.Cancellation_Date__c = Date.valueOf(cancellationDate);
            subscriptionJob.CC_Order__c = subscriptionId;
            subscriptionJob.Status__c = 'Created';
            subscriptionJob.Subscription_Action__c = 'Cancel SLCS Subscription';
            subscriptionJob.Subscription_Ids__c = subscriptionId;
            insert subscriptionJob;                
        }                                                           
*/
            
            ssSubModel.setStatus(true);            
        }
        catch (SSCartException ex) {
            ssSubModel.setErrorMessage(ex.getMessage());
            ssSubModel.setStatus(false);
        }
        catch (SSSubscriptionException ex) {
            ssSubModel.setErrorMessage(ex.getMessage());
            ssSubModel.setStatus(false);
        }
        return ssSubModel;
    }  
    
    
  
    global static SSSubscriptionRegradeModel upgradeSubscription(String parentSubscriptionId, List<SSCartItemModel> newCartItems,string regradeType)
    {        
        SSSubscriptionRegradeModel subscriptionUpgradeRequest = new SSSubscriptionRegradeModel();

        //SSSubscriptionHelper subscriptionManager = new SSSubscriptionHelper();
        SSCartHelper cartManager = new SSCartHelper();
        Map<String, String> subscriptionEvent = getSubscriptionEvent(regradeType);

        String newSubscriptionStatus = (String)subscriptionEvent.get('newSubscriptionStatus');
        String newSubscriptionEvent = (String)subscriptionEvent.get('newSubscriptionEvent');
        String parentSubscriptionStatus = (String)subscriptionEvent.get('parentSubscriptionStatus');
        String parentSubscriptionEvent = (String)subscriptionEvent.get('parentSubscriptionEvent');
        
        try {            
            //Step 1 - Retrieve info from Parent Subscription
            System.debug('SSSubscriptionRegradeService: regradeSubscription: enter');
            //retrieve the Cart ID, User Identity Id, Account ID, Contact Id, Lead Id, Opportunity ID tied to the old subscription id
            SSSubscriptionModel parentSubscription = SSSubscriptionHelper.getSubscription(parentSubscriptionId);
            System.debug('SSSubscriptionRegradeService: regradeSubscription: parentSubscription ' + parentSubscription);
            
            /*
            //regrades are currently allowed on expired Subscriptions. this constraing will be enabled if the business condition changes
            if ((parentSubscription.products != null) && (parentSubscription.products.size() > 0)) {
                Date productSubscriptionEndDate = parentSubscription.products[0].subscriptionEndDate;
                if ((productSubscriptionEndDate != null) && (productSubscriptionEndDate < Date.today())) {
                    throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_SUBSCRIPTION_REGRADE_PARENT_SUBSCRIPTION_EXPIRED);                
                }                
            }
            */            
            Map<String, Object> regradedCart = createNewCart(parentSubscription, newCartItems, regradeType, cartManager);  
            String regradedCartId = (String)regradedCart.get('cartId');
            String regradedCartSfId = (String)regradedCart.get('cartSfId');
            SSCartModel parentCartModel = (SSCartModel)regradedCart.get('parentCart');
            String parentCartId = parentCartModel.cartId;
            
            addCoupon(regradedCartId, newCartItems, parentCartModel.cartLocale, parentCartModel.currencyCode);
            //applyTax(regradedCartId, companyCode, 
                   //  customerCode, parentCartModel.country,
                             //  parentCartModel.taxCode, parentCartModel.vatNumber);
            //createLead(regradedCartId, newCartItems, parentCartModel, regradeType, cartManager, parentCartId); 
                        
            //create the new subscription
            String regradedSubscriptionId = SSCartHelper.createCCOrder(regradedCartId);    
            System.debug('SSSubscriptionRegradeService: regradeSubscription: regradedSubscriptionId ' + regradedSubscriptionId);
                                   
            String zuoraAccountId = '';
            String zuoraAccountZuoraId = '';
            String zuoraSubscriptionId = '';
            /*
            if ((parentSubscription.billing != null) && (String.isNotBlank(parentSubscription.billing.zuoraAccountId))) {
                zuoraAccountId = parentSubscription.billing.zuoraAccountId;
                zuoraAccountZuoraId = parentSubscription.billing.zuoraAccountZuoraId;
            }
            if (String.isNotBlank(parentCartModel.zuoraSubscriptionId)) {
                zuoraSubscriptionId = parentCartModel.zuoraSubscriptionId;
                if (String.isBlank(zuoraAccountId)) {
                    try {
                    Zuora__Subscription__c zuoraSubscription = subscriptionManager.getZuoraSubscription(zuoraSubscriptionId);
                    zuoraAccountZuoraId = zuoraSubscription.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c;
                    zuoraAccountId = zuoraSubscription.Zuora__Account__r.ID;
                    }
                    catch (Exception ex) {
                        System.debug('Exception retrieving Zuora Account for Subsctiption ' + zuoraSubscriptionId + ', ' + ex.getMessage());
                    }
                }
            }
            //return response
            subscriptionUpgradeRequest.zuoraAccountId = zuoraAccountId;
            subscriptionUpgradeRequest.zuoraAccountZuoraId = zuoraAccountZuoraId;
            //subscriptionUpgradeRequest.provisionResponse = provisionResponse;
            subscriptionUpgradeRequest.SSSubscriptionId = regradedSubscriptionId;
            subscriptionUpgradeRequest.slcsSubscriptionId = parentCartModel.slcsSubscriptionId;
            subscriptionUpgradeRequest.zuoraSubscriptionId = zuoraSubscriptionId;
            */
            subscriptionUpgradeRequest.cartId = regradedCartId;
            subscriptionUpgradeRequest.parentSubscription = parentSubscription;

            
            if (regradeType.equalsIgnoreCase('cross sell')) {
                subscriptionUpgradeRequest.isCrossSell = true;
            }
            else {
                subscriptionUpgradeRequest.isCrossSell = false;                
            }
            subscriptionUpgradeRequest.setStatus(true);
            
            
            //SSSubscriptionHelper.updateRegradeUpdateInitAsync( regradedSubscriptionId,  parentSubscriptionId,  newSubscriptionStatus, 
            //                                            newSubscriptionEvent,  parentSubscriptionStatus, 
            //                                            parentSubscriptionEvent);
            
                        //update new subscription status
            SSSubscriptionHelper.updateSubscriptionStatus(regradedSubscriptionId, newSubscriptionStatus, newSubscriptionEvent, true);
            //update parent subscription status
            SSSubscriptionHelper.updateSubscriptionStatus(parentSubscriptionId, parentSubscriptionStatus, parentSubscriptionEvent, true);

            return subscriptionUpgradeRequest;
        }
        catch (SSCartException ex) {
            System.debug('SSSubscriptionRegradeService: regradeSubscription: cart exception ' + ex.getMessage());
            subscriptionUpgradeRequest.setErrorMessage(ex.getMessage());
            subscriptionUpgradeRequest.setStatus(false);
        }
        catch (SSSubscriptionException ex) {
            System.debug('SSSubscriptionRegradeService: regradeSubscription: subscription exception ' + ex.getMessage());
            subscriptionUpgradeRequest.setErrorMessage(ex.getMessage());
            subscriptionUpgradeRequest.setStatus(false);
        }
        return subscriptionUpgradeRequest;
    } 
    
    global static SSSubscriptionRegradeModel downgradeSubscription(String parentSubscriptionId, List<SSCartItemModel> newCartItems,string regradeType)
    {        
        SSSubscriptionRegradeModel subscriptionUpgradeRequest = new SSSubscriptionRegradeModel();

        //SSSubscriptionHelper subscriptionManager = new SSSubscriptionHelper();
        SSCartHelper cartManager = new SSCartHelper();
        Map<String, String> subscriptionEvent = getSubscriptionEvent(regradeType);

        String newSubscriptionStatus = (String)subscriptionEvent.get('newSubscriptionStatus');
        String newSubscriptionEvent = (String)subscriptionEvent.get('newSubscriptionEvent');
        String parentSubscriptionStatus = (String)subscriptionEvent.get('parentSubscriptionStatus');
        String parentSubscriptionEvent = (String)subscriptionEvent.get('parentSubscriptionEvent');
        
        try {            
            //Step 1 - Retrieve info from Parent Subscription
            System.debug('SSSubscriptionRegradeService: regradeSubscription: enter');
            //retrieve the Cart ID, User Identity Id, Account ID, Contact Id, Lead Id, Opportunity ID tied to the old subscription id
            SSSubscriptionModel parentSubscription = SSSubscriptionHelper.getSubscription(parentSubscriptionId);
            System.debug('SSSubscriptionRegradeService: regradeSubscription: parentSubscription ' + parentSubscription);
            
            /*
            //regrades are currently allowed on expired Subscriptions. this constraing will be enabled if the business condition changes
            if ((parentSubscription.products != null) && (parentSubscription.products.size() > 0)) {
                Date productSubscriptionEndDate = parentSubscription.products[0].subscriptionEndDate;
                if ((productSubscriptionEndDate != null) && (productSubscriptionEndDate < Date.today())) {
                    throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_SUBSCRIPTION_REGRADE_PARENT_SUBSCRIPTION_EXPIRED);                
                }                
            }
            */            
            Map<String, Object> regradedCart = createNewCart(parentSubscription, newCartItems, regradeType, cartManager);  
            String regradedCartId = (String)regradedCart.get('cartId');
            String regradedCartSfId = (String)regradedCart.get('cartSfId');
            SSCartModel parentCartModel = (SSCartModel)regradedCart.get('parentCart');
            String parentCartId = parentCartModel.cartId;
            
            addCoupon(regradedCartId, newCartItems, parentCartModel.cartLocale, parentCartModel.currencyCode);
            //applyTax(regradedCartId, companyCode, 
                   //  customerCode, parentCartModel.country,
                             //  parentCartModel.taxCode, parentCartModel.vatNumber);
            //createLead(regradedCartId, newCartItems, parentCartModel, regradeType, cartManager, parentCartId); 
                        
            //create the new subscription
            String regradedSubscriptionId = SSCartHelper.createCCOrder(regradedCartId);    
            System.debug('SSSubscriptionRegradeService: regradeSubscription: regradedSubscriptionId ' + regradedSubscriptionId);
                                   
            String zuoraAccountId = '';
            String zuoraAccountZuoraId = '';
            String zuoraSubscriptionId = '';
            /*
            if ((parentSubscription.billing != null) && (String.isNotBlank(parentSubscription.billing.zuoraAccountId))) {
                zuoraAccountId = parentSubscription.billing.zuoraAccountId;
                zuoraAccountZuoraId = parentSubscription.billing.zuoraAccountZuoraId;
            }
            if (String.isNotBlank(parentCartModel.zuoraSubscriptionId)) {
                zuoraSubscriptionId = parentCartModel.zuoraSubscriptionId;
                if (String.isBlank(zuoraAccountId)) {
                    try {
                    Zuora__Subscription__c zuoraSubscription = subscriptionManager.getZuoraSubscription(zuoraSubscriptionId);
                    zuoraAccountZuoraId = zuoraSubscription.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c;
                    zuoraAccountId = zuoraSubscription.Zuora__Account__r.ID;
                    }
                    catch (Exception ex) {
                        System.debug('Exception retrieving Zuora Account for Subsctiption ' + zuoraSubscriptionId + ', ' + ex.getMessage());
                    }
                }
            }
            //return response
            subscriptionUpgradeRequest.zuoraAccountId = zuoraAccountId;
            subscriptionUpgradeRequest.zuoraAccountZuoraId = zuoraAccountZuoraId;
            //subscriptionUpgradeRequest.provisionResponse = provisionResponse;
            subscriptionUpgradeRequest.SSSubscriptionId = regradedSubscriptionId;
            subscriptionUpgradeRequest.slcsSubscriptionId = parentCartModel.slcsSubscriptionId;
            subscriptionUpgradeRequest.zuoraSubscriptionId = zuoraSubscriptionId;
            */
            subscriptionUpgradeRequest.cartId = regradedCartId;
            subscriptionUpgradeRequest.parentSubscription = parentSubscription;

            
            if (regradeType.equalsIgnoreCase('cross sell')) {
                subscriptionUpgradeRequest.isCrossSell = true;
            }
            else {
                subscriptionUpgradeRequest.isCrossSell = false;                
            }
            subscriptionUpgradeRequest.setStatus(true);
            
            
            //SSSubscriptionHelper.updateRegradeUpdateInitAsync( regradedSubscriptionId,  parentSubscriptionId,  newSubscriptionStatus, 
            //                                            newSubscriptionEvent,  parentSubscriptionStatus, 
            //                                            parentSubscriptionEvent);
            
                        //update new subscription status
            SSSubscriptionHelper.updateSubscriptionStatus(regradedSubscriptionId, newSubscriptionStatus, newSubscriptionEvent, true);
            //update parent subscription status
            SSSubscriptionHelper.updateSubscriptionStatus(parentSubscriptionId, parentSubscriptionStatus, parentSubscriptionEvent, true);

            return subscriptionUpgradeRequest;
        }
        catch (SSCartException ex) {
            System.debug('SSSubscriptionRegradeService: regradeSubscription: cart exception ' + ex.getMessage());
            subscriptionUpgradeRequest.setErrorMessage(ex.getMessage());
            subscriptionUpgradeRequest.setStatus(false);
        }
        catch (SSSubscriptionException ex) {
            System.debug('SSSubscriptionRegradeService: regradeSubscription: subscription exception ' + ex.getMessage());
            subscriptionUpgradeRequest.setErrorMessage(ex.getMessage());
            subscriptionUpgradeRequest.setStatus(false);
        }
        return subscriptionUpgradeRequest;
    } 
    
    global static SSSubscriptionRegradeModel upsellSubscription(String parentSubscriptionId, List<SSCartItemModel> newCartItems ,string regradeType
                                                              )
    {        
        SSSubscriptionRegradeModel subscriptionUpgradeRequest = new SSSubscriptionRegradeModel();

        //SSSubscriptionHelper subscriptionManager = new SSSubscriptionHelper();
        SSCartHelper cartManager = new SSCartHelper();
        Map<String, String> subscriptionEvent = getSubscriptionEvent(regradeType);

        String newSubscriptionStatus = (String)subscriptionEvent.get('newSubscriptionStatus');
        String newSubscriptionEvent = (String)subscriptionEvent.get('newSubscriptionEvent');
        String parentSubscriptionStatus = (String)subscriptionEvent.get('parentSubscriptionStatus');
        String parentSubscriptionEvent = (String)subscriptionEvent.get('parentSubscriptionEvent');
        
        try {            
            //Step 1 - Retrieve info from Parent Subscription
            System.debug('SSSubscriptionRegradeService: regradeSubscription: enter');
            //retrieve the Cart ID, User Identity Id, Account ID, Contact Id, Lead Id, Opportunity ID tied to the old subscription id
            SSSubscriptionModel parentSubscription = SSSubscriptionHelper.getSubscription(parentSubscriptionId);
            System.debug('SSSubscriptionRegradeService: regradeSubscription: parentSubscription ' + parentSubscription);
            
            /*
            //regrades are currently allowed on expired Subscriptions. this constraing will be enabled if the business condition changes
            if ((parentSubscription.products != null) && (parentSubscription.products.size() > 0)) {
                Date productSubscriptionEndDate = parentSubscription.products[0].subscriptionEndDate;
                if ((productSubscriptionEndDate != null) && (productSubscriptionEndDate < Date.today())) {
                    throw new SSSubscriptionException(SSSubscriptionException.EXCEPTION_SUBSCRIPTION_REGRADE_PARENT_SUBSCRIPTION_EXPIRED);                
                }                
            }
            */            
            Map<String, Object> regradedCart = createNewCart(parentSubscription, newCartItems, regradeType, cartManager);  
            String regradedCartId = (String)regradedCart.get('cartId');
            String regradedCartSfId = (String)regradedCart.get('cartSfId');
            SSCartModel parentCartModel = (SSCartModel)regradedCart.get('parentCart');
            String parentCartId = parentCartModel.cartId;
            
            addCoupon(regradedCartId, newCartItems, parentCartModel.cartLocale, parentCartModel.currencyCode);
            //applyTax(regradedCartId, companyCode, 
                   //  customerCode, parentCartModel.country,
                             //  parentCartModel.taxCode, parentCartModel.vatNumber);
            //createLead(regradedCartId, newCartItems, parentCartModel, regradeType, cartManager, parentCartId); 
                        
            //create the new subscription
            String regradedSubscriptionId = SSCartHelper.createCCOrder(regradedCartId);    
            System.debug('SSSubscriptionRegradeService: regradeSubscription: regradedSubscriptionId ' + regradedSubscriptionId);
                                   
            String zuoraAccountId = '';
            String zuoraAccountZuoraId = '';
            String zuoraSubscriptionId = '';
            /*
            if ((parentSubscription.billing != null) && (String.isNotBlank(parentSubscription.billing.zuoraAccountId))) {
                zuoraAccountId = parentSubscription.billing.zuoraAccountId;
                zuoraAccountZuoraId = parentSubscription.billing.zuoraAccountZuoraId;
            }
            if (String.isNotBlank(parentCartModel.zuoraSubscriptionId)) {
                zuoraSubscriptionId = parentCartModel.zuoraSubscriptionId;
                if (String.isBlank(zuoraAccountId)) {
                    try {
                    Zuora__Subscription__c zuoraSubscription = subscriptionManager.getZuoraSubscription(zuoraSubscriptionId);
                    zuoraAccountZuoraId = zuoraSubscription.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c;
                    zuoraAccountId = zuoraSubscription.Zuora__Account__r.ID;
                    }
                    catch (Exception ex) {
                        System.debug('Exception retrieving Zuora Account for Subsctiption ' + zuoraSubscriptionId + ', ' + ex.getMessage());
                    }
                }
            }
            //return response
            subscriptionUpgradeRequest.zuoraAccountId = zuoraAccountId;
            subscriptionUpgradeRequest.zuoraAccountZuoraId = zuoraAccountZuoraId;
            //subscriptionUpgradeRequest.provisionResponse = provisionResponse;
            subscriptionUpgradeRequest.SSSubscriptionId = regradedSubscriptionId;
            subscriptionUpgradeRequest.slcsSubscriptionId = parentCartModel.slcsSubscriptionId;
            subscriptionUpgradeRequest.zuoraSubscriptionId = zuoraSubscriptionId;
            */
            subscriptionUpgradeRequest.cartId = regradedCartId;
            subscriptionUpgradeRequest.parentSubscription = parentSubscription;

            
            if (regradeType.equalsIgnoreCase('cross sell')) {
                subscriptionUpgradeRequest.isCrossSell = true;
            }
            else {
                subscriptionUpgradeRequest.isCrossSell = false;                
            }
            subscriptionUpgradeRequest.setStatus(true);
            
            
            //SSSubscriptionHelper.updateRegradeUpdateInitAsync( regradedSubscriptionId,  parentSubscriptionId,  newSubscriptionStatus, 
            //                                            newSubscriptionEvent,  parentSubscriptionStatus, 
            //                                            parentSubscriptionEvent);
            
                        //update new subscription status
            SSSubscriptionHelper.updateSubscriptionStatus(regradedSubscriptionId, newSubscriptionStatus, newSubscriptionEvent, true);
            //update parent subscription status
            SSSubscriptionHelper.updateSubscriptionStatus(parentSubscriptionId, parentSubscriptionStatus, parentSubscriptionEvent, true);

            return subscriptionUpgradeRequest;
        }
        catch (SSCartException ex) {
            System.debug('SSSubscriptionRegradeService: regradeSubscription: cart exception ' + ex.getMessage());
            subscriptionUpgradeRequest.setErrorMessage(ex.getMessage());
            subscriptionUpgradeRequest.setStatus(false);
        }
        catch (SSSubscriptionException ex) {
            System.debug('SSSubscriptionRegradeService: regradeSubscription: subscription exception ' + ex.getMessage());
            subscriptionUpgradeRequest.setErrorMessage(ex.getMessage());
            subscriptionUpgradeRequest.setStatus(false);
        }
        return subscriptionUpgradeRequest;
    } 
    
    /*
     * Function that returns Subscription Status and Events 
     * based on Regrade Type for both Parent Subscription and 
     * the New Subscription
     */  
    global static Map<String, String> getSubscriptionEvent(String regradeType) {
        String newSubscriptionStatus = 'Active';
        String newSubscriptionEvent = '';
        String parentSubscriptionStatus = '';
        String parentSubscriptionEvent = '';
        
        if (regradeType.equalsIgnoreCase(SSSubscription.SUBSCRIPTION_REGRADE_TYPE_CROSSSELL)) {
            newSubscriptionEvent = SSSubscription.SUBSCRIPTION_EVENT_CROSS_SELL;  
        }
        else if (regradeType.equalsIgnoreCase(SSSubscription.SUBSCRIPTION_REGRADE_TYPE_UPSELL)) {
            newSubscriptionEvent = SSSubscription.SUBSCRIPTION_EVENT_UPSELL;  
            parentSubscriptionStatus = SSSubscription.SUBSCRIPTION_STATUS_UPSELL;
            parentSubscriptionEvent = SSSubscription.SUBSCRIPTION_EVENT_UPSELL;                      
        }
        else if (regradeType.equalsIgnoreCase(SSSubscription.SUBSCRIPTION_REGRADE_TYPE_UPGRADE)) {
            newSubscriptionEvent = SSSubscription.SUBSCRIPTION_EVENT_UPGRADE;  
            parentSubscriptionStatus = SSSubscription.SUBSCRIPTION_STATUS_UPGRADED;
            parentSubscriptionEvent = SSSubscription.SUBSCRIPTION_EVENT_UPGRADE;                                          
        }
        else if (regradeType.equalsIgnoreCase(SSSubscription.SUBSCRIPTION_REGRADE_TYPE_DOWNGRADE)) {
            newSubscriptionEvent = SSSubscription.SUBSCRIPTION_EVENT_DOWNGRADE;  
            parentSubscriptionStatus = SSSubscription.SUBSCRIPTION_STATUS_DOWNGRADED;
            parentSubscriptionEvent = SSSubscription.SUBSCRIPTION_EVENT_DOWNGRADE;                                                              
        }  
        Map<String, String> subscriptionEvent = new Map<String, String>();
        subscriptionEvent.put('newSubscriptionStatus', newSubscriptionStatus);
        subscriptionEvent.put('newSubscriptionEvent', newSubscriptionEvent);
        subscriptionEvent.put('parentSubscriptionStatus', parentSubscriptionStatus);
        subscriptionEvent.put('parentSubscriptionEvent', parentSubscriptionEvent);
        return subscriptionEvent;
    }
    
    /*
     * Function to create a New Cart based on a Parent Cart. 
     * New Cart to be used for the Regraded Subscription
     */ 
    global static Map<String, Object> createNewCart(SSSubscriptionModel parentSubscription, 
                                                    List<SSCartItemModel> newCartItems, 
                                                    String regradeType, SSCartHelper cartManager) {
        SSCartModel parentCartModel = parentSubscription.cart;            
        System.debug('SSSubscriptionRegradeService: createNewCart: cartID ' + parentCartModel.cartId);
        System.debug('SSSubscriptionRegradeService: regradeSubscription: parent cart info retrieved ' + parentCartModel);
                
        cartManager = new SSCartHelper(SSSubscription.STOREFRONT_DEFAULT, SSSubscription.STOREFRONT_DEFAULT_USER_NAME,  parentCartModel.cartLocale, parentCartModel.currencyCode);
        //Need to pass storefront,portalUser,locale
        String cartId = SSCartHelper.createCart(SSSubscription.STOREFRONT_DEFAULT,'','');
        System.debug('Cart created - ID ' + cartId);
        
        //update the details from Parent Cart to Child Cart
        ccrz__E_Cart__c cart = SSCartHelper.getCartByEncryptedId(cartId);
        cart.ccrz__Name__c = parentCartModel.cartNumber + ' - Product Regrade';
        cart.ccrz__CartId__c = cartId;
        cart.Locale__c = parentCartModel.cartLocaleId;
        //cart.Country__c = parentCartModel.country;
        cart.Parent_Cart__c = parentCartModel.sfId;
        //cart.VAT_Number__c = parentCartModel.vatNumber;
        //cart.Tax_Code__c = parentCartModel.taxCode;
        //cart.ccrz__User__c = cartUser;
        //cart.User_Identity_ID__c = parentCartModel.userIdentityId;
        //cart.SLCS_Subscription_Group_ID__c = parentCartModel.slcsSubscriptionGroupId;
        cart.ccrz__CurrencyISOCode__c = parentCartModel.currencyCode;
        
        /*
        cart.CurrencyIsoCode = parentCartModel.currencyCode;
        if (String.isNotBlank(parentCartModel.paymentMethodId)) {
            cart.Payment_Method_Id__c = parentCartModel.paymentMethodId;            
        }
        if (String.isNotBlank(parentCartModel.zuoraSubscriptionId)) {
            cart.Zuora_Subscription_ID__c = parentCartModel.zuoraSubscriptionId;   
            cart.Zuora_Subscription_Number__c = parentCartModel.zuoraSubscriptionNumber;
        }
        */
        update cart;
        //System.debug('SSSubscriptionService: regradeSubscription: Cart Id - ' + cartId + ', User Identity Id - ' + userIdentityId);
        //cartManager.updateSLCSDetailsOnCart(cartId, userIdentityId, slcsSubscriptionId, slcsSubscriptionGroupId, slcsClientReferenceNumber,  entitlementId, activityId);    

        System.debug('SSSubscriptionRegradeService: regradeSubscription: ###User Identity ID is  ' + parentCartModel.userIdentityId);
        System.debug('SSSubscriptionRegradeService: regradeSubscription:adding items to new cart ' + cart);
        SSCartHelper.addItemsToCart(cartId, '', '', null, newCartItems);  
        System.debug('SSSubscriptionRegradeService: regradeSubscription:Added items to new cart ' + cart);                                               
        SSCartHelper.updateAccountEx(cartId, parentCartModel.accountId, parentCartModel.contactId, regradeType);
        System.debug('SSSubscriptionRegradeService: regradeSubscription: items added to Cart ' + cart);
        
        Map<String, Object> regradedCart = new Map<String, Object>();
        regradedCart.put('cartId', cartId);
        regradedCart.put('cartSfId', cart.Id);
        regradedCart.put('parentCart', parentCartModel);

        return regradedCart;        
    }
    
    /*
     * Function to add a Coupon to Cart
     */ 
    global static void addCoupon(String cartId, List<SSCartItemModel> newCartItems, String cartLocale, String currencyCode) {
        SSCouponHelper couponManager = new SSCouponHelper(SSSubscription.STOREFRONT_DEFAULT, SSSubscription.STOREFRONT_DEFAULT_USER_NAME,  
                                                                    cartLocale, currencyCode);
        for (SSCartItemModel newCartItem: newCartItems) {
            //check if any of the items are components in a bundle. then need to get the 
            //coupon code for setting the bundle to set the discounted price
            system.debug('-----newCartItem.parentProductBundleSKU------'+newCartItem.parentProductBundleSKU);
            if (String.isNotBlank(newCartItem.parentProductBundleSKU)) {
                system.debug('-----cartId------'+cartId);
                system.debug('-----newCartItems------'+newCartItems);

            }
            String newCouponCode = newCartItem.couponCode;
            if (String.isNotBlank(newCouponCode)) {
                SSCouponHelper.addCouponsOnCartItems(cartId, newCouponCode);                
            }                   
        }        
    }
    
              
}