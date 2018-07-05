global class  CSSCartHelper{
        
    private static final Set<String> EUCountries = new Set<String> {'IE', 'FR','DE','ES'}; 
            
    global static CSSCartModel getCartBySFID(String cartId) {
        ccrz__E_Cart__c cart = getCartById(cartId);
        return getCartInfo(cart);
    }
    
    global static CSSCartModel getCart(String cartId) {
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        return getCartInfo(cart);
    }
    
   	global static Decimal applyTax(String cartId, String taxCode, String vatNumber,CSSAddressModel billingAddress){
        Double taxAmount = 0;
        ccrz__E_Cart__c cart = CSSCartHelper.getCartByEncryptedId(cartId);
        List<Tax_Config__c> lstOrderItems = [Select Id, Tax_Service_Class__c
                                                     from Tax_Config__c Limit 1];
        if(!lstOrderItems.IsEmpty())
        {       
            system.debug('>>>>>>>'+lstOrderItems[0].Tax_Service_Class__c);         
            Type typeTaxCls = Type.forName(lstOrderItems[0].Tax_Service_Class__c);
            if(typeTaxCls == null) {
            	System.debug(LoggingLevel.Error, 'Failed to find type for ['+lstOrderItems[0].Tax_Service_Class__c+']');
            	throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_TAX_CLASS);
            }
            ICSSTaxService taxService = (ICSSTaxService)typeTaxCls.newInstance();
            system.debug('>>>>>>>'+typeTaxCls);
            taxAmount = taxService.calculateTax(taxCode,cart.ccrz__SubtotalAmount__c,billingAddress);
            
        }
        else
        {
           throw new CSSCartException(CSSCartException.EXCEPTION_NO_CONFIG_RECORD_FOUND);
        }
        
        //Saving tax Info on Cart 
        saveTaxInfo(cart,taxAmount,vatNumber,taxCode,billingAddress.country);
	   	return taxAmount;
   }

    global static CSSBillingAccountModel createBillingSubscription(String cartId,CSSAccountModel account, CSSContactModel contact, DateTime subscriptionStartDate,
                                                  String currencyCode, String locale, String paymentReferenceID,
                                                           String paymentType, CSSPaymentDetailsModel paymentDetails) {

        CSSBillingAccountModel billingModel = new CSSBillingAccountModel();
        
        List<Billing_Config__c> lstbillingEngine = [Select Id, Create_Subscription_Class__c
                                                     from Billing_Config__c Limit 1];
      
        if(!lstbillingEngine.IsEmpty())
        {           
          	Type typeCreateBillingSubscriptionCls = Type.forName(lstbillingEngine[0].Create_Subscription_Class__c);
            if (typeCreateBillingSubscriptionCls == null) {
            	System.debug(LoggingLevel.Error, 'Failed to find type for ['+lstbillingEngine[0].Create_Subscription_Class__c+']');
             	throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_BILLING_SUBSCRIPTION_CLASS);
            }
            
			ICSSBillingSubscription billingCreateSubscription = (ICSSBillingSubscription)typeCreateBillingSubscriptionCls.newInstance();
            billingModel = billingCreateSubscription.createSubscription(cartId, account, contact,subscriptionStartDate, currencyCode, locale, 
                                                                        paymentReferenceID, paymentType, paymentDetails);
        }
        else {
           throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_BILLING_SUBSCRIPTION_CLASS);
        }   
   		return billingModel;
   	}
    
	global static CSSBillingAccountModel createCrossSellBillingSubscription(String cartId,String billingAccountId, String ccSubscriptionId, 
                                                     DateTime subscriptionStartDate, String currencyCode, String locale, 
                                                     String paymentReferenceID, String paymentType, CSSPaymentDetailsModel paymentDetails) {

        CSSBillingAccountModel billingModel = new CSSBillingAccountModel();
        List<Billing_Config__c> lstbillingEngine = [Select Id, Cross_Sell_Subscription_Class__c
                                                     from Billing_Config__c Limit 1];
      
        if(!lstbillingEngine.IsEmpty())
        {
        	Type typeCrossSellBillingSubscriptionCls = Type.forName(lstbillingEngine[0].Cross_Sell_Subscription_Class__c);
            
            if (typeCrossSellBillingSubscriptionCls == null) {
            	System.debug(LoggingLevel.Error, 'Failed to find type for ['+lstbillingEngine[0].Cross_Sell_Subscription_Class__c+']');
             	throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_BILLING_SUBSCRIPTION_CLASS);
           	}
            
            ICSSCrossSellBillingSubscription billingCrossSellSubscription = (ICSSCrossSellBillingSubscription)typeCrossSellBillingSubscriptionCls.newInstance();
            
            billingModel = billingCrossSellSubscription.createCrossSellSubscription(cartId, ccSubscriptionId,billingAccountId,subscriptionStartDate, currencyCode, locale, paymentType,
                                                                        paymentReferenceID,  paymentDetails);
        }
        else {
           throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_BILLING_SUBSCRIPTION_CLASS);
        }
   
   		return billingModel;
	}   
    
    global static CSSCartModel getCartInfo(ccrz__E_Cart__c cart) {
        CSSCartModel cartInfo = new CSSCartModel();
        cartInfo.encryptedCartId = cart.ccrz__EncryptedId__c;
        cartInfo.cartId = cart.Id;
        cartInfo.cartNumber = cart.Name;
       	Boolean isBillingAcountRequired = CSSCartHelper.isBillingAccountRequired(cart.ccrz__EncryptedId__c);
        if(isBillingAcountRequired){
        	cartInfo.transactionType  ='Buy';   
        }
        else{
            cartInfo.transactionType ='Trial';
        }
        cartInfo.cartStatus = cart.ccrz__CartStatus__c;
        cartInfo.cartType = cart.ccrz__CartType__c;
        cartInfo.cartLocale = cart.Locale__r.Name;
        cartInfo.cartLocaleId = cart.Locale__c;
        //cartInfo.country = cart.Country__c;
        cartInfo.billTo = cart.ccrz__BillTo__c;
        cartInfo.portalUserName =cart.ccrz__User__r.Name;
        
        cartInfo.currencyCode = cart.ccrz__CurrencyISOCode__c;
        cartInfo.totalAmount = cart.ccrz__TotalAmount__c;
        cartInfo.subTotalAmount = cart.ccrz__SubtotalAmount__c;
        cartInfo.adjustmentAmount = cart.ccrz__AdjustmentAmount__c;
        cartInfo.adjustmentReason = cart.ccrz__AdjustmentReason__c;
        cartInfo.storefront = cart.ccrz__Storefront__c;
        
        Decimal taxAmount = cart.ccrz__TaxAmount__c;
        
        Decimal taxPercentage = 0;
        if ((taxAmount != null) && (taxAmount > 0) && cart.ccrz__SubtotalAmount__c>0) {
            cartInfo.taxAmount = taxAmount;
            taxPercentage = taxAmount/cart.ccrz__SubtotalAmount__c;
            taxPercentage = taxPercentage.setScale(2, RoundingMode.HALF_UP) * 100;
            cartInfo.taxPercentage = taxPercentage;
        }
        cartInfo.taxExemptFlag = cart.ccrz__TaxExemptFlag__c;
        cartInfo.taxSubtotalAmount = cart.ccrz__TaxSubTotalAmount__c;
        cartInfo.totalDiscount = cart.ccrz__TotalDiscount__c;
        cartInfo.vatNumber = cart.VAT_Number__c;
        
        cartInfo.accountId = cart.ccrz__Account__c;
        cartInfo.contactId = cart.ccrz__Contact__c;
        //cartInfo.leadId = cart.Lead__c;
        cartInfo.opportunityId = cart.Opportunity__c;
        cartInfo.taxCode = cart.Tax_Code__c;
        cartInfo.buyerEmail = cart.ccrz__BuyerEmail__c;
        
        //cartInfo.transactionReferenceNumber = cart.Transaction_Reference_Number__c;
        //Zuora_Subscription_ID__c
        //Zuora_Payment_ID__c 
        cartInfo.paymentMethodId = cart.Payment_Transaction_ID__c;
        
        List<CSSCartItemModel> cartItems = new List<CSSCartItemModel>();
        
        List<ccrz__E_CartItem__c> cartItemsList = getCartItemsByEncryptedCartId(cart.ccrz__EncryptedId__c);
        for (ccrz__E_CartItem__c cartItem : cartItemsList) {
            CSSCartItemModel cartItemModel = getCartItemInfo(cartItem);
            if (taxPercentage > 0) {
                cartItemModel.taxPercentage = taxPercentage;
                Decimal cartItemTaxAmount = cartItemModel.subAmount * (taxPercentage/100);
                cartItemTaxAmount = cartItemTaxAmount.setScale(2, RoundingMode.HALF_UP);
                cartItemModel.taxAmount = cartItemTaxAmount;
                
                
            }
            cartItems.add(cartItemModel);
        }
        cartInfo.cartItemList = cartItems;
        return cartInfo;
    }
    
    global static CSSCartItemModel getCartItemInfo(ccrz__E_CartItem__c cartItem) {        
        CSSCartItemModel cartItemModel = new CSSCartItemModel();
        CSSProductModel product = new CSSProductModel();
        product.productType = cartItem.ccrz__ProductType__c;
        String productId = cartItem.ccrz__Product__c;
        product.productId = productId;
        String productSKU = cartItem.ccrz__Product__r.ccrz__SKU__c;
        product.productSKU = productSKU;
        //Vikram: Commenting this code. check later
        //if(cartItem.ccrz__ParentCartItem__c != null)
        //	cartItemModel.product.parentSKU = cartItem.ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c;
        
        if(cartItem.ccrz__Product__r.Trial_Period_in_Days__c   !=null)
        {
            product.trialLength = cartItem.ccrz__Product__r.Trial_Period_in_Days__c;
        }
        
        product.shortDescription = cartItem.ccrz__Product__r.ccrz__ShortDesc__c;
        product.longDescription = cartItem.ccrz__Product__r.ccrz__LongDesc__c;
        product.productName = cartItem.ccrz__Product__r.Name;
        product.productType = cartItem.ccrz__ProductType__c;
        Boolean isTierPriced = CSSProductHelper.isTierPriced(productId);
        product.tierPriced = isTierPriced;
        
        cartItemModel.product = product;
        
        
        cartItemModel.absoluteDiscount = cartItem.ccrz__AbsoluteDiscount__c;
        cartItemModel.adjustmentAmount = cartItem.ccrz__AdjustmentAmount__c;
        
        //Vikram: why do you need related product type when you are retrieving cart item info
        //cartItemModel.relatedProductType = cartItem.Related_Product_Type__c;
        //cartItemModel.relatedProductParentSku = cartItem.ccrz__DisplayProduct__r.ccrz__SKU__c;
        
        cartItemModel.cartItemId = cartItem.Id;
        cartItemModel.cartItemNumber = cartItem.Name;
        cartItemModel.cartItemType = cartItem.ccrz__cartItemType__c;
        //cartItemModel.category = cartItem.ccrz__category__r.name;
        cartItemModel.comments = cartItem.ccrz__Comments__c;
        //cartItemModel.contractEffectiveDate = cartItem.Contract_Effective_Date__c;
        //cartItemModel.contractStartDate = cartItem.Contract_Start_Date__c;
        cartItemModel.couponPurpose = cartItem.ccrz__Coupon__r.Coupon_Purpose__c;
        cartItemModel.couponCode = cartItem.ccrz__Coupon__r.ccrz__CouponName__c;//cartItem.ccrz__Coupon__r.Name;
        cartItemModel.couponType = cartItem.ccrz__Coupon__r.ccrz__CouponType__c;
        cartItemModel.couponShortDescription = cartItem.ccrz__Coupon__r.Short_Description__c;
        cartItemModel.couponLongDescription = cartItem.ccrz__Coupon__r.Long_Description__c;
        cartItemModel.percentageDiscount = cartItem.ccrz__PercentDiscount__c;
        cartItemModel.price = cartItem.ccrz__Price__c;
        cartItemModel.pricingType = cartItem.ccrz__PricingType__c;
        cartItemModel.quantity = cartItem.ccrz__Quantity__c;
        cartItemModel.subAmount = cartItem.ccrz__SubAmount__c;
        String subProdTermId = cartItem.ccrz__SubProdTerm__c;
        cartItemModel.subProdTermId = subProdTermId;
        cartItemModel.subscriptionDuration = cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentCount__c;
        cartItemModel.subscriptionFrequency = cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequency__c;
        cartItemModel.subscriptionTermType = cartItem.ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c;
        //SSProductHelper    productManager = new SSProductHelper   ();
        //cartItemModel.sageInternalProduct = cartItem.ccrz__Product__r.Sage_Product__c ;
        cartItemModel.parentBundleSku = cartItem.Bundle_Product_SKU__c;
        cartItemModel.parentBundleDescription = cartItem.Bundle_Product_Description__c;
        cartItemModel.tierDescription = cartItem.Tier_Description__c;
        
        return cartItemModel;
    }
    
    global static ccrz__E_Cart__c getCartById(String cartId){
        try {
            System.debug('Cart ID is ' + cartId);
            return [SELECT Id, ccrz__Storefront__c,  CurrencyIsoCode, Locale__c, ccrz__BillTo__c,   
                    Opportunity__c, Locale__r.Name, ccrz__CurrencyISOCode__c, Transaction_Type__c,  
                    ccrz__CartType__c, ccrz__TotalAmount__c, ccrz__CartStatus__c, ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, 
                    ccrz__TaxSubTotalAmount__c, ccrz__TotalQuantity__c, ccrz__Contact__c, ccrz__Account__c, ccrz__AdjustmentAmount__c, 
                    ccrz__AdjustmentReason__c, ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, ccrz__BuyerEmail__c, 
                    ccrz__BuyerCompanyName__c, ccrz__TaxExemptFlag__c, Name, ccrz__EncryptedId__c, ccrz__AnonymousId__c, 
                    Parent_Cart__c,Coupon_Applied__c, ccrz__TotalDiscount__c, VAT_Number__c, Confirmation_Email_Sent__c,
                    ccrz__PaymentMethod__c, Tax_Code__c,Payment_Transaction_ID__c,ccrz__User__r.Name
                    
                    FROM ccrz__E_Cart__c 
                    WHERE Id =: cartId LIMIT 1];
        }
        catch (System.QueryException ex) {
            System.debug('getCartById: exception ' + ex.getMessage());
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);            
        }
    }
    
    global static ccrz__E_Cart__c getCartByEncryptedId(String encryptedId) {
        try {
            return [SELECT Id, ccrz__Storefront__c, CurrencyIsoCode, Locale__c, ccrz__BillTo__c, ccrz__User__r.Name,  
                    Opportunity__c, Locale__r.Name, ccrz__CurrencyISOCode__c, Transaction_Type__c,  
                    ccrz__CartType__c, ccrz__TotalAmount__c, ccrz__CartStatus__c, ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, 
                    ccrz__TaxSubTotalAmount__c, ccrz__TotalQuantity__c, ccrz__Contact__r.FirstName,ccrz__Contact__r.LastName,
                    ccrz__Contact__r.email,ccrz__Contact__r.phone,ccrz__Contact__r.MailingStreet,ccrz__Contact__r.MailingCity,
                    ccrz__Contact__r.MailingState,ccrz__Contact__r.MailingCountry,ccrz__Contact__r.MailingPostalCode,
                    ccrz__Account__r.Id,ccrz__Account__r.Name, ccrz__AdjustmentAmount__c, 
                    ccrz__AdjustmentReason__c, ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, ccrz__BuyerEmail__c, 
                    ccrz__BuyerCompanyName__c, ccrz__TaxExemptFlag__c, Name, ccrz__EncryptedId__c, ccrz__AnonymousId__c, 
                    Parent_Cart__c,Coupon_Applied__c, ccrz__TotalDiscount__c, VAT_Number__c, Confirmation_Email_Sent__c,
                    ccrz__PaymentMethod__c, Tax_Code__c,Payment_Transaction_ID__c  
                    
                    FROM ccrz__E_Cart__c
                    WHERE ccrz__EncryptedId__c =: encryptedId LIMIT 1];            
        }
        catch (System.QueryException ex) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);            
        }
    }
    
    global static String getContactEmailFromCart(ccrz__E_Cart__c targetCart) {
        System.debug('Entering GetContactEmailFromCart...');
        System.debug('Target cart to inspect => ' + targetCart);    
        String result = null;
        try {
            String contactId = targetCart.ccrz__Contact__c;
            Contact cartContact = [SELECT Id, FirstName, LastName, Email, 
                                   MailingStreet, MailingCity, MailingState, MailingPostalCode,
                                   Account.Name, Account.Id, Account.BillingStreet FROM Contact WHERE Id =:contactId LIMIT 1];
            if(cartContact != null) {
                result =  cartContact.Email;
            }
            
        } catch (Exception ex) {
            System.debug('GetContactEmailFromCart: Exception Message: ' + ex.getMessage());
            System.debug('GetContactEmailFromCart: Exception ' + ex);
        }
        System.debug('Exiting GetContactEmailFromCart...');      
        return result;
    }    
    
    global static List<ccrz__E_CartItem__c> getCartItemsByCartId(String cartId) {
        return [SELECT Id, Name, ccrz__ItemTotal__c, ccrz__SubAmount__c, ccrz__PricingType__c, ccrz__PercentDiscount__c, 
                ccrz__Coupon__c, ccrz__AdjustmentAmount__c, ccrz__AbsoluteDiscount__c, Billing_Product_Rate_Plan_ID__c,ccrz__E_CartItem__c.ccrz__ParentProduct__c,
                ccrz__Price__c, ccrz__Product__r.Name, ccrz__Product__r.Id, ccrz__Product__r.ccrz__TaxRateId__c, 
                ccrz__Product__c, Coupon_Message__c, 
                ccrz__Product__r.ccrz__EndDate__c, ccrz__Product__r.ccrz__StartDate__c, 
                ccrz__SubProdTerm__c, ccrz__Coupon__r.Name, ccrz__Coupon__r.ccrz__CouponName__c, ccrz__Coupon__r.ccrz__CouponType__c,
                ccrz__cartItemType__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Subscription_Duration__c, ccrz__Subscription_Frequency__c, 
                ccrz__ParentCartItem__c, ccrz__Product__r.Is_Trial_Product__c, ccrz__Category__r.Name,
                ccrz__Product__r.Trial_Period_in_Days__c  , ccrz__Quantity__c, 
                ccrz__ProductType__c, ccrz__Comments__c,
                ccrz__Product__r.ccrz__ShortDesc__c, ccrz__Product__r.ccrz__LongDesc__c, ccrz__Coupon__r.Short_Description__c, 
                ccrz__Coupon__r.Long_Description__c, Bundle_Product_SKU__c, Bundle_Product_Description__c, Tier_Description__c 
                FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.Id =: cartId];
    }
    
    global static List<ccrz__E_CartItem__c> getCartItemsByEncryptedCartId(String cartId){
        
        return [SELECT Id, Name, ccrz__ItemTotal__c, ccrz__SubAmount__c, ccrz__PricingType__c, ccrz__PercentDiscount__c, ccrz__Coupon__c, ccrz__AdjustmentAmount__c, ccrz__AbsoluteDiscount__c, Billing_Product_Rate_Plan_ID__c,ccrz__E_CartItem__c.ccrz__ParentProduct__c,
                ccrz__Price__c, ccrz__Product__r.Name, ccrz__Product__r.Id, ccrz__Product__r.ccrz__TaxRateId__c,   ccrz__Product__c, Coupon_Message__c,
                ccrz__Product__r.ccrz__EndDate__c, ccrz__Product__r.ccrz__StartDate__c, ccrz__SubProdTerm__c, ccrz__Coupon__r.Name, ccrz__Coupon__r.ccrz__CouponName__c, ccrz__Coupon__r.ccrz__CouponType__c,
                ccrz__cartItemType__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Subscription_Duration__c, ccrz__Subscription_Frequency__c, ccrz__ParentCartItem__c,ccrz__ParentCartItem__r.ccrz__ProductType__c ,ccrz__Product__r.Is_Trial_Product__c, ccrz__Category__r.Name,
                ccrz__Product__r.Trial_Period_in_Days__c   , ccrz__Quantity__c, ccrz__ProductType__c, ccrz__Comments__c,ccrz__Coupon__r.Coupon_Purpose__c,ccrz__DisplayProduct__r.ccrz__SKU__c, Related_Product_Type__c,
                ccrz__Product__r.ccrz__ShortDesc__c, ccrz__Product__r.ccrz__LongDesc__c , ccrz__Coupon__r.Short_Description__c, ccrz__Coupon__r.ccrz__CouponCode__c,
                ccrz__Coupon__r.Long_Description__c, Bundle_Product_SKU__c, Bundle_Product_Description__c, Tier_Description__c,ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c,
                ccrz__SubProdTerm__r.ccrz__InstallmentFrequencyUOM__c,ccrz__SubProdTerm__r.ccrz__InstallmentCount__c,ccrz__SubProdTerm__r.ccrz__InstallmentFrequency__c 
                FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.ccrz__EncryptedId__c =: cartId];
    }
    
    global static String createCart(String storefront,String portalUserName,String userLocale) {
        system.debug('>>>'+storefront);
        system.debug('>>>'+portalUserName);
        system.debug('>>>>>'+userLocale);
        
        CSSContext ccContext = new CSSContext();
        System.debug('CSSCartHelper: createCart: enter');
        ccrz.ccContext ctx = ccContext.getCCContextForAnonymousUser(storefront, portalUserName, userLocale) ;
        System.debug('CSSCartHelper: createCart: retrieved context for anonymous user'+ ctx);
        Map<String,Object> ccMap = ccContext.getCCApiVersion();
        
        //create new cart
        Map<String, Object> createResults = ccrz.ccApiCart.create(ccMap);
        System.debug('CSSCartHelper: createCart: creating cart');
        ccrz.ccLog.log(LoggingLevel.DEBUG,'SAGE','CCServiceUtility : createCart : createResults :' + createResults); 
        Boolean wasSuccessful = (Boolean) createResults.get(ccrz.ccApi.SUCCESS);
        String cartId = (String) createResults.get(ccrz.ccApiCart.CART_ENCID);
        
        if (wasSuccessful == false) {
            throw new CSSCartException(CSSCartException.EXCEPTION_CREATE_CART);
        }
        System.debug('#########################Cart Id is ' + cartId);
        return cartId;
    }
    
    global static Boolean addToCart(String cartId, List<Map<String, Object>> lineDataList) {
        CSSContext ecommContext = new CSSContext();
        //add item to cart
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        
        system.debug('addToCart>>>>>'+cart.ccrz__Storefront__c);
        system.debug('addToCart>>>>>'+cart.ccrz__User__r.Name);
        system.debug('addToCart>>>>>'+cart.Locale__r.Name);
       
        ccrz.ccContext ctx = ecommContext.getCCContextForAnonymousUser(cart.ccrz__Storefront__c, cart.ccrz__User__r.Name, cart.Locale__r.Name) ;
        system.debug('addToCart>>>>>'+ctx);
        Map<String,Object> ccMap = ecommContext.getCCApiVersion();
        Map<String,Object> addResults = ccrz.ccApiCart.addTo(new Map<String,Object>{
            ccrz.ccApi.API_VERSION => ccMap.get(ccrz.ccApi.API_VERSION),
               ccrz.ccApiCart.CART_ENCID => cartId,
                ccrz.ccApiCart.LINE_DATA => lineDataList
           
                });
        System.debug('calling api ' + lineDataList);
        System.debug('calling api addResults' + addResults);
        Boolean wasSuccessful = (Boolean) addResults.get(ccrz.ccApi.SUCCESS);  
        if (wasSuccessful == false) {
            throw new CSSCartException(CSSCartException.EXCEPTION_ADD_TO_CART);
        }
        System.debug('add to cart status' + wasSuccessful);        
        return true;               
    }    
    
    global static String createCCOrder(String cartId) {
        String orderId = '';
        CSSContext ecommContext = new CSSContext();
        ccrz__E_Cart__c  cart = getCartByEncryptedId(cartId); 
        String cartSFID = cart.Id;
        System.debug('Order Creation1');
        String currentStatus = '';
        currentStatus = cart.ccrz__CartStatus__c;
        if (!currentStatus.equalsIgnoreCase('closed')) {
            //Cart should be in an Open Status in order to Convert into a Subscription
            //Update the Cart accordingly 
            updateCartStatus(cartId, SSCart.CART_STATUS_OPEN);
            //add item to cart
           	// ccrz.ccContext ctx = ecommContext.getCCContextForAnonymousUser();
        	ccrz.ccContext ctx = ecommContext.getCCContextForAnonymousUser(cart.ccrz__Storefront__c, cart.ccrz__User__r.Name, cart.Locale__r.Name) ; 
            Map<String,Object> ccMap = ecommContext.getCCApiVersion();
            Map<String,Object> inputData = new Map<String,Object>{
                ccrz.ccApi.API_VERSION => ccMap.get(ccrz.ccApi.API_VERSION),
                    ccrz.ccApiCart.CART_ENCID => cartId
                    };
                        
                        try{
                            System.debug('calling cart order'+inputData);
                            Map<String,Object> orderResults = ccrz.ccApiCart.place(inputData);
                            System.debug('orderResults'+orderResults);
                            //General check, since the cart id will be blank if not successful we technically do not need this.
                            Boolean wasSuccessful = (Boolean)orderResults.get(ccrz.ccApi.SUCCESS);
                            orderId = (String)orderResults.get(ccrz.ccApiCart.ORDER_ID);
                            System.debug('order id ' + orderId);
                            System.debug('order placed ' + wasSuccessful);
                            
                            //Update CurrencyISO Code on Order Item
                            updateOrderItemsAmount(cartId, orderId );
                            
                            cart = getCartByEncryptedId(cartId);    
                            String vatNumber = cart.VAT_Number__c;
                            //String country = cart.Country__c;
                            String cartLocaleId = cart.Locale__c;
                            String cartLocale = cart.Locale__r.Name;
                            String currencyISOCode = cart.ccrz__CurrencyISOCode__c;
                            Double totalAmount = cart.ccrz__TotalAmount__c;
                            Double subtTotalAmount = cart.ccrz__SubtotalAmount__c;
                            Double taxAmount = cart.ccrz__TaxAmount__c;
                            String accountId = cart.ccrz__Account__c;
                            //String paymentMethodId = cart.Payment_Method_Id__c;
                            
                            if ((vatNumber != null) && (String.isNotBlank(vatNumber))) {
                                //SSAccountHelper accountManager = new SSAccountHelper();
                                //SSAccountHelper.updateVATNumber(accountId, vatNumber);
                            }
                            //SSSubscriptionHelper subscriptionManager = new SSSubscriptionHelper();
                            List<ccrz__E_Order__c> subscriptions = SSSubscriptionHelper.getSubscriptionById(orderId);
                            //List<ccrz__E_Order__c> subscriptions = null;
                            if ((subscriptions!= null) && (subscriptions.size() > 0)) {
                                ccrz__E_Order__c subscription = subscriptions[0];
                                //subscription.Payment_Method_Id__c = paymentMethodId;
                                update subscription;
                            }
                            return orderId;
                        } catch(Exception e){
                            System.debug('createCCOrder: exception for  ' + cartId + ' - ' + e.getMessage());
                            throw new CSSCartException(CSSCartException.EXCEPTION_CREATE_SUBSCRIPTION_FROM_CART);
                        }
        }
        else {
            ccrz__E_Order__c ccOrder = [SELECT Id, Name, ccrz__OriginatedCart__c FROM ccrz__E_Order__c WHERE ccrz__OriginatedCart__c =: cartSFID LIMIT 1];
            orderId = ccOrder.Id;
        }        
        return orderId;               
    }      
    
    global static void updateOrderItemsAmount(String cartId , String orderId){
        List<ccrz__E_OrderItem__c > orderItemsList = [Select id,CurrencyIsoCode,ccrz__Order__r.Id, ccrz__Order__r.CurrencyIsoCode,
                                                     ccrz__Product__r.Id, ccrz__Price__c,ccrz__SubAmount__c,ccrz__AbsoluteDiscount__c 
                                                     from ccrz__E_OrderItem__c where ccrz__Order__r.Id=:orderId];
        CSSCartModel cart = getCart(cartId);
        List<CSSCartItemModel> cartItems = null;
        if(cart!=null && cart.cartItemList!=null)
        {
            cartItems = cart.cartItemList;
        }
        
        if(orderItemsList!=null)
        {
            for(ccrz__E_OrderItem__c ccOrderItem : orderItemsList)
            {
                ccOrderItem.CurrencyIsoCode = ccOrderItem.ccrz__Order__r.CurrencyIsoCode;
                if(cartItems!=null)
                {
                    for(CSSCartItemModel cartItem : cartItems)
                    {
                        if(cartItem.product.productId == ccOrderItem.ccrz__Product__r.Id)
                        {
                            ccOrderItem.ccrz__SubAmount__c = cartItem.subAmount ;
                            ccOrderItem.ccrz__Price__c =  cartItem.price ;
                            ccOrderItem.ccrz__AbsoluteDiscount__c = cartItem.absoluteDiscount;
                        }       
                    }
                }
            }
            update orderItemsList;
        }
    }
    
    global static Boolean isExistingCartItem(List<ccrz__E_CartItem__c> currentCartItemList, String sku) {
        Boolean cartItemExists = false;
        for (ccrz__E_CartItem__c currentCartItem: currentCartItemList) {
            String currentSKU = currentCartItem.ccrz__Product__r.ccrz__SKU__c;
            if (currentSKU.equalsIgnoreCase(sku)) {
                cartItemExists = true;
            }
        }   
        return cartItemExists;
    }
    
    global static ccrz__E_CartItem__c getCartItem(List<ccrz__E_CartItem__c> currentCartItemList, String sku) {
        ccrz__E_CartItem__c cartItem = null;
        for (ccrz__E_CartItem__c currentCartItem: currentCartItemList) {
            String currentSKU = currentCartItem.ccrz__Product__r.ccrz__SKU__c;
            if (currentSKU.equalsIgnoreCase(sku)) {
                cartItem = currentCartItem;
            }
        }   
        return cartItem;
    }
    
    global static Map<String,String> getChildSkuCoupon(List<CSSCartItemModel> cartItems,String strBundleSku)
    {
        Set<String> setChildProductSkus = new Set<String>();
        List<CSSCartItemModel> lstcartItems = new List<CSSCartItemModel>();
        //Set Coupons
       	Map<String,String> mapChildSkuCoupon = new Map<String,String>();
                 
        for (CSSCartItemModel cartItem: cartItems) {
           if(cartItem.selectedBundleComponentList != null)
             {
               for(CSSProductModel obj : cartItem.selectedBundleComponentList)
               {     
                      system.debug('>>>>>> Creating parent map'+obj);
                      if(obj.productSKU != null)
	                      setChildProductSkus.add(obj.productSKU);
               }
           } 
        }
        
        
        if(!setChildProductSkus.IsEmpty())
        {
                List<ccrz__E_Coupon__c> couponList = [SELECT Id, Name, ccrz__CouponCode__c, ccrz__SourceProduct__r.ccrz__SKU__c,ccrz__TargetProduct__r.ccrz__SKU__c
                                                      FROM ccrz__E_Coupon__c where
                                                      ccrz__StartDate__c <= today and ccrz__EndDate__c >= today and ccrz__Enabled__c = true and
                                                      ccrz__SourceProduct__r.ccrz__SKU__c =: strBundleSku and ccrz__TargetProduct__r.ccrz__SKU__c in : setChildProductSkus];
                 for(ccrz__E_Coupon__c obj: couponList)
                 {
                    mapChildSkuCoupon.put(obj.ccrz__TargetProduct__r.ccrz__SKU__c,obj.ccrz__CouponCode__c);    
                 }
        }
        
        return mapChildSkuCoupon;
    }
    
    global static List<Id> lstADCIds(List<string> lineDataAttributes)
    {
       	List<Id> lstADCIds = new List<Id>();
       	if(lineDataAttributes != null)// For ADC Product
		{   
        	for(String strADC : lineDataAttributes)
            {
            	if(strADC != null) 
                	lstADCIds.add(SSProductHelper.adcAttributeSFID(strADC));
          	}
       	}
        return lstADCIds;            
    }
    
    global static Boolean addItemsToCart(String cartId, List<CSSCartItemModel> cartItems) {
        CSSContext ecommContext = new CSSContext();
        String strProductType='';
        System.debug('retrieving cart');
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        List<ccrz__E_CartItem__c> currentCartItems = getCartItemsByEncryptedCartId(cartId);
       
        Boolean isBundledProduct = false;
        Boolean isTierPriced = false;
        String strBundleSku = '';
        System.debug('adding cart items ' + cartItems);
        List<Map<String, Object>> lineDataList = new List<Map<String, Object>>();
        List<Map<String, Object>> ChildlineDataList = new List<Map<String, Object>>();
        List<Map<String, Object>> FinallineDataList = new List<Map<String, Object>>();
        set<string> setDynamicKitMajorSKU = new set<string>();
       
        ccrz.ccApiCart.LineData parentlineData = new ccrz.ccApiCart.LineData();//For Dynamic Kit
        
        Map<String,Object> lineFinalDataMap = new Map<String, Object>();
        Map<String, String> tierPricedItems = new Map<String, String>();
        Set<string> setProdSkus = new Set<String>();
        Map<String,String> mapChildSkuCoupon = new Map<String,String>();
        Map<String,String> mapRelatedProductSKU = new Map<String,String>();
        for (CSSCartItemModel cartItem: cartItems) {
           if (cartItem.product.productType.equals('Dynamic Kit') || cartItem.product.productType.equals('Bundle')) {
                isBundledProduct = true;
                strBundleSku = cartItem.product.productSKU;
                setDynamicKitMajorSKU.add(cartItem.product.productSKU);
           }
           
           if(isBundledProduct && strBundleSku != null)
	           mapChildSkuCoupon = getChildSkuCoupon(cartItems,strBundleSku);
           
           system.debug('>>>>>>'+mapChildSkuCoupon);
           
            //add item to cart
            String sku = cartItem.product.productSKU;
            //check if the SKU already exists in the Cart before adding
          
            //check if the SKU passed is valid
            CSSProductModel product = CSSProductHelper.getProductInfoBySKU(sku);
            if (product == null) {
                throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_PRODUCT_SKU);
            }    
            system.debug('>>>>>>' + product);            
            String subProdTermId = cartItem.subProdTermId;
            if (String.isBlank(subProdTermId))
            {
                String productId = product.productId;  
                List<Map<String, String>> subProdTermList = CSSProductHelper.getSubProdTerms(productId,cartItem.subscriptionTermType);
                if(!subProdTermList.Isempty())
                {
                  subProdTermId = subProdTermList[0].get('subscriptionTermId');
                }
                
                system.debug('>>>>>>' + subProdTermId);
            }
            Map<String,Object> lineParentDataMap = new Map<String, Object>();
            
            /*
            //Vikram: check with prasanthi about related product type
            if(cartItem.relatedProductType != null &&  cartItem.relatedProductParentSku != null)
            {
               CSSProductModel relatedProductParentSKU = CSSProductHelper.getProductInfoBySKU(cartItem.relatedProductParentSku);
               lineParentDataMap.put(ccrz.ccApiCart.LINE_DATA_PARENT_PRODUCT_SFID,relatedProductParentSKU.productId);
               
               mapRelatedProductSKU.put(cartItem.sku,cartItem.relatedProductType); 
            }
             */             
			system.debug('>>>>>> Creating parent map' );
               
            lineParentDataMap.put(ccrz.ccApiCart.LINE_DATA_SKU,cartItem.product.productSKU);
            //lineParentDataMap.put(ccrz.ccApiCart.LINE_DATA_PARENT_PRODUCT_SFID,'a0F1N00000mZRYR');
            lineParentDataMap.put(ccrz.ccApiCart.LINE_DATA_QUANTITY,cartItem.quantity);
            lineParentDataMap.put(ccrz.ccApiCart.LINE_DATA_SUBPRODTERM_SFID,subProdTermId);
               
            if(cartItem.selectedTierList != null)//for both Tier & ADC
			{
				List<String> lstattrVal = new List<String>();
                for(CSSPriceTierModel objTier : cartItem.selectedTierList) 
                {
                	system.debug('ATTRIBUTE ????????'+objTier.attributeValue);
                    //for tiered product there will always be one Tier selected
                        if(objTier.attributeValue != null && objTier.attributeValue != '' && CSSProductHelper.isTierPriced(cartItem.product.productSKU))
                               lineParentDataMap.put(ccrz.ccApiCart.LINE_DATA_QUANTITY,Decimal.ValueOf(objTier.attributeValue));
                               
                        if(objTier.tierAttribute != null && objTier.attributeValue != '' && CSSproductHelper.isADCPriced(cartItem.product.productSKU))
                               lstattrVal.add(objTier.attributeValue);//SFDC IDs
            	}
                         
                if(!lstattrVal.Isempty())// ONLY if the Product Type is ADC
                	lineParentDataMap.put(ccrz.ccApiCart.LINE_DATA_ATTRIBUTE_LIST,lstattrVal); 
           	}         
			system.debug('>>>>>> Creating parent map'+lineParentDataMap);
	        system.debug('>>>>>> Creating parent map'+cartItem.selectedBundleComponentList);
               
            if(cartItem.selectedBundleComponentList != null)
            {
				for(CSSProductModel obj : cartItem.selectedBundleComponentList)
               	{     
                	system.debug('>>>>>> Creating parent map'+obj);
                    Map<String,Object> childlineDataMap = new Map<String, Object>();
	                childlineDataMap.put(ccrz.ccApiCart.LINE_DATA_SKU,obj.productSKU);
                    childlineDataMap.put(ccrz.ccApiCart.LINE_DATA_QUANTITY,obj.bundleChildQuantity);
                    if(obj.bundleChildSelectedTierList != null)//for both Tier & ADC
                    {
                    	system.debug('>>>>>> Creating parent map'+ obj.bundleChildSelectedTierList);
                        List<String> lstattrVal = new List<String>();
                         
	                    for(CSSPriceTierModel objTier : obj.bundleChildSelectedTierList) 
                        {
                        	system.debug('ATTRIBUTE ????????'+objTier);
                            //for tiered product there will always be one Tier selected
                            	if(objTier.attributeValue != null && objTier.attributeValue != '' && CSSproductHelper.isTierPriced(obj.productSKU) )
                               		childlineDataMap.put(ccrz.ccApiCart.LINE_DATA_QUANTITY,Decimal.ValueOf(objTier.attributeValue));
                               
                               	//For ADC Product
                               	if(objTier.tierAttribute != null && objTier.attributeValue != '' && CSSproductHelper.isADCPriced(obj.productSKU) )
                               		lstattrVal.add(objTier.attributeValue);//SFDC IDs
                         	}
	                        if(!lstattrVal.Isempty())// ONLY if the Product Type is ADC
                         		childlineDataMap.put(ccrz.ccApiCart.LINE_DATA_ATTRIBUTE_LIST,lstattrVal); 
                     	}  
                        ChildlineDataList.add(childlineDataMap);
	                    system.debug('>>>>>>'+childlineDataMap);
               		}
                  	lineParentDataMap.put(ccrz.ccApiCart.LINE_DATA_MINOR_LINE_DATAS,ChildlineDataList);
             	}
               	FinallineDataList.add(lineParentDataMap);
        	}
        
        	System.debug('###############################################################');
        	boolean bResult = false;
        	String bundleId = '';
        	System.debug('added cart item lineDataList' +FinallineDataList);
	        bResult = addToCart(cartId,FinallineDataList);
    		Set<Id> setProductIds = new Set<Id>();
        	List<ccrz__E_CartItem__c> cartItemList = getCartItemsByEncryptedCartId(cartId);
            System.debug('cartItemList');
        
        	try {
            	// Dynamic Kit without Child SPTS , if this scenario exists , uncomment this code
                //Updating Related Product Type on Cart Item : Add -On, Maintence
                system.debug('mapRelatedProductSKU'+mapRelatedProductSKU);
                if(!mapRelatedProductSKU.IsEmpty()){
                	for(ccrz__E_CartItem__c cartItem : cartItemList)
                  	{
                    	if(mapRelatedProductSKU.ContainsKey(cartItem.ccrz__Product__r.ccrz__SKU__c))
                      	{
                        	cartItem.Related_Product_Type__c = mapRelatedProductSKU.get(cartItem.ccrz__Product__r.ccrz__SKU__c);
                      	}
                  }
                  update cartItemList;
 				}
        	}
	        catch (Exception ex) {
    	        System.debug('Exception applying coupon ' + ex.getMessage());
        	}
        return bResult;
    }
    
    global static void updateSubAmtOnDynamicKit(string strCartEncID,Set<String> setDynamicKitMajorSKU)
    {
        Map<Id,ccrz__E_CartItem__c> mapDynamicProd = new Map<Id,ccrz__E_CartItem__c>();
                  Double totalDiscount = 0.0;
                  Double totalCartItemPrice = 0.0;
                  String strCoupon = '';
                  
                  for(string strDynKitSKU : setDynamicKitMajorSKU){
                  
                  for (ccrz__E_CartItem__c cartItem : [Select id,ccrz__Price__c,ccrz__Coupon__r.ccrz__CouponCode__c,
                  ccrz__Cart__c,ccrz__Coupon__c,ccrz__ProductType__c,ccrz__cartItemType__c, ccrz__SubAmount__c ,
                  ccrz__AbsoluteDiscount__c,ccrz__ParentCartItem__c,ccrz__ParentCartItem__r.ccrz__ProductType__c,
                  ccrz__ParentCartItem__r.ccrz__cartItemType__c
                  from ccrz__E_CartItem__c where ccrz__Cart__r.ccrz__EncryptedId__c =: 
                  strCartEncID and (ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c =: strDynKitSKU
                  or ccrz__Product__r.ccrz__SKU__c =: strDynKitSKU)]) {
                  
                       system.debug('cartItem'+cartItem);
                       
                       if(cartItem.ccrz__ProductType__c == 'Dynamic Kit' && cartItem.ccrz__cartItemType__c == 'Major'
                       )
                       {
                         
                         system.debug('mapDynamicProd'+cartItem);
                         
                         mapDynamicProd.put(cartItem.Id,cartItem);
                         
                         strCoupon = cartItem.ccrz__Coupon__r.ccrz__CouponCode__c ;
                       }
                       else
                       {
                          //system.debug('cartItem.ccrz__AbsoluteDiscount__c'+cartItem.ccrz__AbsoluteDiscount__c);
                          //totalDiscount += cartItem.ccrz__AbsoluteDiscount__c == null ? 0:
                           //cartItem.ccrz__AbsoluteDiscount__c;
                          
                          totalCartItemPrice +=  cartItem.ccrz__Price__c;
                       }
                  
                  }
                  
                  system.debug('totalCartItemPrice'+totalCartItemPrice);
                  
                  if(!mapDynamicProd.IsEmpty())
                  {
                       
                       system.debug('mapDynamicProd'+mapDynamicProd);
                       
                       for(ccrz__E_CartItem__c cartItem :mapDynamicProd.values())
                       {
                          system.debug('cartItem'+cartItem);
                          
                          //cartItem.ccrz__SubAmount__c = - totalDiscount;
                          //cartItem.ccrz__AbsoluteDiscount__c = totalDiscount;
                          cartItem.ccrz__Coupon__c=null;
                          //Setting Coupon to NULL , to re-calculate Discount for the Major Cart Item
                          cartItem.ccrz__Price__c = totalCartItemPrice;
                       }
                       update mapDynamicProd.values();
                       
                       system.debug('cart.ccrz__EncryptedId__c'+strCartEncID);
                       
                       //Calculate the Discount based on the total price with SUM of the Price of Minor cart Items
                       if(strCoupon != null)
                       CSSCouponHelper.addCouponsOnCartItems(strCartEncID,strCoupon);
                    }
                  }
    }
    
    global static Boolean addProductBundleToCart(String cartId, String bundleSku, String bundleLabel, Decimal bundleQuantity, List<CSSCartItemModel> bundleComponents) {
        System.debug('adding bundle cart items');
        //SSProductHelper    productManager = new SSProductHelper   ();
        if (!CSSProductHelper.isValidSKU(bundleSku)) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_BUNDLE_SKU);
            
        }
        //return addItemsToCart(cartId, bundleComponents);
        return true;
    }
    
     global static Boolean addProductToCart(String encCartId, String productSku, Decimal quantity, Decimal price, Decimal subAmount, String couponCode) {
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
        System.debug('creating cart item');
        Id productId =getProductIdBySku(productSku);
        cartItem.ccrz__Product__c = productId;    
        System.debug('product retrieved');
        try {
            cartItem.ccrz__Quantity__c = quantity;
            ccrz__E_Cart__c currentCart;
            currentCart = CSSCartHelper.getCartByEncryptedId(encCartId);
            cartItem.ccrz__Cart__c = currentCart.ID;
            cartItem.ccrz__Price__c = price;
            cartItem.ccrz__SubAmount__c = subAmount;
            insert cartItem;
        }
        catch (Exception ex) {
            //ExceptionLogUtility.TetrisException te = new ExceptionLogUtility.TetrisException('Exception adding Product to Cart.' + ex.getMessage());
            //throw te;            
        }
        System.debug('cart item created');
        return true;
    }
    
    global static Boolean addCouponToCart(String cartId, String couponCode) {
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        CSSContext ecommContext = new CSSContext();
        ccrz.ccContext ctx = ecommContext.getCCContextForAnonymousUser();
        Map<String,Object> ccMap = ecommContext.getCCApiVersion();
        //add item to cart
        Map<String,Object> addResults = ccrz.ccApiCart.addTo(new Map<String,Object>{
            ccrz.ccApi.API_VERSION => ccMap.get(ccrz.ccApi.API_VERSION),
                ccrz.ccApiCart.CART_ENCID => cartId,
                ccrz.ccApiCart.COUPON_CODE => couponCode
                });
        System.debug('calling api');
        Boolean wasSuccessful = (Boolean) addResults.get(ccrz.ccApi.SUCCESS);  
        System.debug('add coupon to cart status' + wasSuccessful);        
        return wasSuccessful;
    }
    
    //fix for CC bug
    //currency defaulted to USD at a Cart Item level. 
    //Overriding with the default currency for the Cart and also 
    //fix for tiered priced item not reflected correctly 
    global static Boolean updatePriceOnCartItemsByPriceType(String cartId) {
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        //cart.Transaction_Type__c = 'buy';
        //cart.Transaction_Type__c = transactionType;
        //update cart;
        
        List<ccrz__E_CartItem__c> cartItems = getCartItemsByEncryptedCartId(cartId);
        for (ccrz__E_CartItem__c cartItem: cartItems) {
            cartItem.currencyISOCode = cart.CurrencyISOCode;
            String productId = cartItem.ccrz__Product__c;
            String subProdTermId = cartItem.ccrz__SubProdTerm__c;
            Boolean isTierPriced = CSSProductHelper.isTierPriced(productId);
            System.debug('Product ' + productId + '-Tier Priced ' + isTierPriced);
            if (isTierPriced) {
                Map<String,String> productTier = new Map<String, String>();
                productTier.put('tierQuantity', String.valueOf(cartItem.ccrz__Quantity__c));
                System.debug('Passing Tier quantity for calculations ' + cartItem.ccrz__Quantity__c);
                List<Map<String, String>> subProdTermList = new List<Map<String, String>>();
                if (!String.isBlank(subProdTermId)) {
                    Map<String, String> subscriptionProductTerm = new Map<String, String>();
                    subscriptionProductTerm.put('subscriptionTermId', subProdTermId);
                    subProdTermList.add(subscriptionProductTerm);
                }
                List<CSSPriceModel> price = CSSProductHelper.getPricingInfo(productId, false, true, productTier, subProdTermList);
                System.debug('Tier Price' + price);
                if (price != null) {
                    for(CSSPriceModel objPrc : price)
                    {
                    	if(subProdTermId.equalsIgnoreCase(objPrc.subscriptionTermId)) {
                      		if( CSSProductHelper.isBucketPriceProduct(productId)){
                      			for(CSSPriceTierModel objTierPrc : objPrc.tierPriceList)
                      			{
			                        cartItem.ccrz__Price__c = objTierPrc.listPrice;
            			            System.debug('Tier list price ' + objTierPrc.listPrice);
                        			//ccrz__AbsoluteDiscount__c
                                    if (cartItem.ccrz__AbsoluteDiscount__c != null) {
                                        cartItem.ccrz__SubAmount__c = objTierPrc.listPrice - cartItem.ccrz__AbsoluteDiscount__c;                        
                                    }
                                    else {
                                        cartItem.ccrz__SubAmount__c = objTierPrc.listPrice;                            
                                    }
                      			}
                    		}
                    		else
                    		{
                      			for(CSSPriceTierModel objTierPrc : objPrc.tierPriceList)
                      			{
	                        		cartItem.ccrz__Price__c = objTierPrc.listPrice;
                        			System.debug('Tier list price ' + objTierPrc);
			                        if (cartItem.ccrz__AbsoluteDiscount__c != null) {
            			                cartItem.ccrz__SubAmount__c = objTierPrc.listPrice * cartItem.ccrz__Quantity__c ;                        
                        			}
			                        else {
            			                cartItem.ccrz__SubAmount__c = objTierPrc.listPrice * cartItem.ccrz__Quantity__c;                            
                        			}
                      			}
		                    }
        	            }
            	        system.debug('objPrc'+objPrc);//tierPriceList
                	}
              	}
            }
            cartItem.ccrz__RecurringPrice__c = cartItem.ccrz__Price__c;
            cartItem.ccrz__RecurringPriceSubAmt__c = cartItem.ccrz__SubAmount__c;
            update cartItem;            
        }
        System.debug('updates completed');
        return true;
    }
    
    global static Boolean updateCartItemCurrency(String cartId) {
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        
        List<ccrz__E_CartItem__c> cartItems = getCartItemsByEncryptedCartId(cartId);
        for (ccrz__E_CartItem__c cartItem: cartItems) {
            cartItem.currencyISOCode = cart.CurrencyISOCode;            
            update cartItem;            
        }
        
        System.debug('updates completed');
        return true;
    }
    
    global static Boolean removeCartItemsAndCoupons(Set<String> setDynamicKitProdSkus,string cartId)
    {
		List<ccrz.ccApiCart.LineData> lineDataList = new List<ccrz.ccApiCart.LineData>();
        Set<Id> lstDynamicKitItems = new Set<Id>();
        Map<String,String> mapChildSkuCoupon = new Map<String,String>();
        Set<String> setChildProductSkus = new Set<String>();  
        string strProdSFID;
        string strProdSku;
          
     	List<ccrz__E_CartItem__c> lstDelcartItem = [SELECT id FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.ccrz__EncryptedId__c = : cartId and ccrz__Product__r.ccrz__SKU__c In : setDynamicKitProdSkus];
     	delete lstDelcartItem;
		system.debug('strProdSku'+setDynamicKitProdSkus);
          
		system.debug('cartId'+cartId);
        if(!setDynamicKitProdSkus.IsEmpty())
        {
        	//Retriving Children cart item coupon details
            List<ccrz__E_CartCoupon__c> lstCartCoupons = [Select ccrz__Enabled__c, ccrz__Coupon__r.Id, ccrz__Coupon__r.ccrz__CouponCode__c,ccrz__Cart__r.ccrz__EncryptedId__c,
                                                            ccrz__Cart__c, ccrz__CartCouponId__c, Name, Id, CurrencyIsoCode,ccrz__Coupon__r.ccrz__TargetProduct__r.ccrz__SKU__c From ccrz__E_CartCoupon__c 
                                                            where ccrz__Cart__r.ccrz__EncryptedId__c =:cartId and ccrz__Coupon__r.ccrz__TargetProduct__r.ccrz__SKU__c in : setDynamicKitProdSkus];
                                                            
            system.debug('lstCartCoupons'+lstCartCoupons);
            for(ccrz__E_CartCoupon__c obj: lstCartCoupons)
            {
            	system.debug('INSIDE lstCartCoupons'+obj.ccrz__Cart__c);
                system.debug('INSIDE lstCartCoupons'+obj.ccrz__Coupon__r.ccrz__CouponCode__c);
                system.debug(' COUPON '+ obj.ccrz__Coupon__r.ccrz__TargetProduct__r.ccrz__SKU__c );
                CSSCouponHelper.removeCouponFromCart(obj.ccrz__Cart__r.ccrz__EncryptedId__c,obj.ccrz__Coupon__r.ccrz__CouponCode__c);
         	}
		}
        return true;
    }
    
    global static List<String> getAllStorefronts()
    {
    	List<String> lstAllStorefronts = new List<String>();
        List<aggregateResult> results = [Select ccrz__Storefront__c storefront from ccrz__E_Configuration__c Group by ccrz__Storefront__c];
        for (AggregateResult ar : results)  
        {
        	lstAllStorefronts.add((string)ar.get('storefront'));
      	}
        return lstAllStorefronts;   
	}
     
    global static String getDefaultStorefront()
    {
             /*
            //To return the Storefront , Please make sure we have the Store Front Accosiation setup 
            
            Map<String,Object> addResults = ccrz.ccAPIStorefront.getAccessibleDefault(new Map<String,Object>{
            ccrz.ccApi.API_VERSION => 7,
            ccrz.ccAPIStorefront.PARAM_REFTYPE  =>ccrz.ccAPIStorefront.TYPE_ACCOUNT 
              });
              
            System.debug('calling api addResults 5' + addResults);
            //TYPE_COMMUNITY, TYPE_ACCOUNT_GROUP, TYPE_ACCOUNT
            System.debug('calling api addResults JSON ' + json.serialize(addResults));
    
            String strStorefront = (String)addResults.get('sfDefault');  
            System.debug('Storefront ' + strStorefront);
            */
            /*
            string strStorefront = 'Adobe';
            if(Userinfo.getUsertype() != 'Guest')
            {
            
              system.debug('$Site.MasterLabel'+Site.getName());
              system.debug('$Site.MasterLabel'+Site.getPathPrefix() );
              system.debug('$Site.MasterLabel'+Site.getSiteType() );
              system.debug('$Site.MasterLabel'+Site.getMasterLabel() );
              system.debug('$Site.MasterLabel'+Site.getBaseUrl() );
              //system.debug('$Site.MasterLabel'+Site.getCurrentSiteUrl() );
              system.debug('$Site.MasterLabel'+Site.getAdminEmail() );
              
              
            String communityId=Network.getNetworkId();
            
            system.debug('communityId'+communityId);
            
            System.debug('#####' + ConnectApi.Communities.getCommunities());
            
            ConnectApi.Community Obj = connectapi.Communities.getCommunity(communityId);
            
            System.debug('#####' + ConnectApi.Communities.getCommunities());
            
            system.debug('>>>>>>urlvalue '+Obj);
            
            system.debug('>>>>>>urlvalue '+Obj.urlPathPrefix);
            strStorefront = Obj.urlPathPrefix;
            }
            */
            system.debug('$Site.MasterLabel'+Site.getMasterLabel() );
            return Site.getMasterLabel();   
     }
    
    global static Boolean removeItemsFromCart(String cartId, List<CSSCartItemModel> cartItems) {
        //check if a valid Cart ID is passed
        //Raja -  pending : for ADC all the cartitem will have same product sku , hence we also need to pass cartitem sfid in cartItem model
        //othrewise we have delete all the child components
        CSSContext ecommContext = new CSSContext();
        ccrz__E_Cart__c cart = CSSCartHelper.getCartByEncryptedId(cartId);
        Set<String> setDynamicKitProdSkus = new Set<String>();
        Boolean wasSuccessful = false;
        ccrz.ccContext ctx = ecommContext.getCCContextForAnonymousUser(cart.ccrz__Storefront__c, cart.ccrz__User__r.Name, cart.Locale__r.Name) ; 
       
        Map<String,Object> ccMap = ecommContext.getCCApiVersion();
        system.debug('CART'+ccMap);
        system.debug('CART'+cart);
        
        if (cart == null) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);                        
        }
        List<ccrz__E_CartItem__c> currentCartItems = getCartItemsByEncryptedCartId(cartId);
        system.debug('>>>>>>currentCartItems'+currentCartItems);//ccrz__ParentCartItem__r.ccrz__ProductType__c
        if (currentCartItems == null) {
            throw new CSSCartException(CSSCartException.EXCEPTION_EMPTY_CART_REMOVE_FAILED);                        
        }
        
        List<ccrz.ccApiCart.LineData> lineDataList = new List<ccrz.ccApiCart.LineData>();
        List<ccrz.ccApiCart.LineData> lineChildDataList = new List<ccrz.ccApiCart.LineData>();
        Set<Id> lstDynamicKitItems = new Set<Id>();
        system.debug('CART'+cartItems);
        for (CSSCartItemModel cartItem: cartItems) {
            String sku = cartItem.product.productSKU;
            String productId = CSSProductHelper.getProductId(sku);
            system.debug('CART'+productId);
            if (productId == null) {
                throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_PRODUCT_SKU);            
            }
          	if(!cartItems.Isempty())
            {
            	if(cartItems[0].product.productType == 'Dynamic Kit')
                 {
                   setDynamicKitProdSkus.add(sku);
                   
                   for(CSSProductModel obj : cartItem.selectedBundleComponentList)
                   {
                     setDynamicKitProdSkus.add(obj.productSKU);
                   }
                   //Calling remove Coupon method to delete the Coupon if any along with the cart item
                   wasSuccessful = removeCartItemsAndCoupons(setDynamicKitProdSkus,cartId);
                   break ;
                 }
         	}
            
            //check if the SKU already exists in the Cart before adding
            ccrz__E_CartItem__c existingCartItem = getCartItem(currentCartItems, sku);
            system.debug('CART'+existingCartItem);
              
            if (existingCartItem == null) {
                throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_PRODUCT_SKU);                                
            }
            
            String cartItemId = existingCartItem.Id;
            //add item to cart
            ccrz.ccApiCart.LineData lineData = new ccrz.ccApiCart.LineData();
            lineData.sku = cartItem.product.productSKU;
            lineData.sfid = cartItemId;
            lineData.qty = 1; 
            
            lineDataList.add(lineData);
            
            system.debug('lineChildDataList'+lineChildDataList);
            system.debug('CART'+lineDataList);
            System.debug('remove cart item');            
        }
         system.debug('CART'+cartId);
         
       
        Map<String,Object> removeResults = ccrz.ccApiCart.removeFrom(new Map<String,Object>{
            ccrz.ccApi.API_VERSION => ccMap.get(ccrz.ccApi.API_VERSION),
                ccrz.ccApiCart.CART_ENCID => cartId,
                ccrz.ccApiCart.LINE_DATA => lineDataList
                });
        System.debug('calling remove api'+removeResults+'??????'+lineDataList);
        wasSuccessful = (Boolean) removeResults.get(ccrz.ccApi.SUCCESS);  
        System.debug('remove from cart status' + wasSuccessful);   
        return wasSuccessful;
    }
    
    global static Boolean removeCouponFromCart(String cartId, String couponCode) {
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        ccrz__E_Coupon__c couponObject = CSSCouponHelper.getCouponDetailsByCouponCode(couponCode);
        //SSCouponHelper tr = new SSCouponHelper();
        CSSCouponHelper.removeCouponsFromCart(cartId, couponCode);
        
        return true;
    }
    
    global static CSSTaxModel applyTaxToCart(String cartId,  String companyCode, String customerCode, String country, String postalCode, String vatNumber, Boolean isViesValidated) {
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        if (cart == null) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);                        
        }
        Decimal cartSubtotal = cart.ccrz__TaxSubTotalAmount__c;
        Decimal taxAmount = 0;
        CSSTaxModel tax = new CSSTaxModel();
        Boolean isEUCountry = EUCountries.contains(country);
        String taxCode = '';
        if ((isViesValidated) && (!String.isBlank(vatNumber)) && (isEUCountry) ) {
            tax.taxAmount = 0;
            tax.country = country;
            tax.taxRate = 0;
            tax.taxableAmount = cartSubtotal;
            tax.totalAmount = cartSubtotal;
        }
        else {
            /*
ITetrisCustomMetadataTypeDAO avaConfigMetadata = TetrisDAOFactory.getCustomMetadataTypeDAO();
String configResourceName = avaConfigMetadata.getAvalaraBaseEndpoint();
Callout_Configuration__mdt avalaraConfig = TetrisCustomMetadataTypeDAO.getResourceInfo(configResourceName);
taxCode = cart.Tax_Code__c;
//if tax code is not applied at cart level then retrieve it from Product level configuration
if (String.isBlank(taxCode)) {
List<ccrz__E_CartItem__c> cartItems = getCartItemsByEncryptedCartId(cartId);
if ((cartItems != null) && (cartItems.size() > 0)) {
taxCode = cartItems[0].ccrz__Product__r.ccrz__TaxRateId__c;
}
}            
tax = TetrisTaxUtil.calculateTax(avalaraConfig.Endpoint_URL__c, avalaraConfig.Username__c, avalaraConfig.Password__c, companyCode, customerCode, taxCode, cartSubtotal, postalCode, country);
*/}
        tax.totalAmount = saveTaxInfo(cart, tax.taxAmount, vatNumber, taxCode, country);
        return tax;
    }
    
    global static CSSTaxModel applyTaxByTaxCode(String cartId, String companyCode, String customerCode, String country, 
                                               String postalCode, String taxCode, String vatNumber) 
    {
    	ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
                                                   if (cart == null) {
                                                       throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);                        
                                                   }
                                                   Decimal cartSubtotal = cart.ccrz__TaxSubTotalAmount__c;
                                                   Decimal taxAmount = 0;
                                                   CSSTaxModel tax = new CSSTaxModel();
                                                   Boolean isEUCountry = EUCountries.contains(country);
                                                   if ((!String.isBlank(vatNumber)) && (isEUCountry) ) {
                                                       tax.taxAmount = 0;
                                                       tax.country = country;
                                                       tax.taxRate = 0;
                                                       tax.taxableAmount = cartSubtotal;
                                                       tax.totalAmount = cartSubtotal;
                                                   }
                                                   else {
                                                       /*ITetrisCustomMetadataTypeDAO avaConfigMetadata = TetrisDAOFactory.getCustomMetadataTypeDAO();
String configResourceName = avaConfigMetadata.getAvalaraBaseEndpoint();
Callout_Configuration__mdt avalaraConfig = TetrisCustomMetadataTypeDAO.getResourceInfo(configResourceName);
taxCode = cart.Tax_Code__c;
//if tax code is not applied at cart level then retrieve it from Product level configuration
if (String.isBlank(taxCode)) {
List<ccrz__E_CartItem__c> cartItems = getCartItemsByEncryptedCartId(cartId);
if ((cartItems != null) && (cartItems.size() > 0)) {
taxCode = cartItems[0].ccrz__Product__r.ccrz__TaxRateId__c;
}
}            
tax = TetrisTaxUtil.calculateTax(avalaraConfig.Endpoint_URL__c, avalaraConfig.Username__c, avalaraConfig.Password__c, companyCode, customerCode, taxCode, cartSubtotal, postalCode, country);
*/}
                                                   tax.totalAmount = saveTaxInfo(cart, tax.taxAmount, vatNumber, taxCode, country);
                                                   return tax;
                                               }
    
    @Future(callout=true)
    global static void applyTaxAsync(String cartId, String companyCode, String customerCode, String country, 
                                     String postalCode, String taxCode, String vatNumber) 
    {
                                         ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
                                         if (cart == null) {
                                             throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);                        
                                         }
                                         Decimal cartSubtotal = cart.ccrz__TaxSubTotalAmount__c;
                                         Decimal taxAmount = 0;
                                         CSSTaxModel tax = new CSSTaxModel();
                                         Boolean isEUCountry = EUCountries.contains(country);
                                         if ((!String.isBlank(vatNumber)) && (isEUCountry) ) {
                                             tax.taxAmount = 0;
                                             tax.country = country;
                                             tax.taxRate = 0;
                                             tax.taxableAmount = cartSubtotal;
                                             tax.totalAmount = cartSubtotal;
                                         }
                                         else {
                                             /*ITetrisCustomMetadataTypeDAO avaConfigMetadata = TetrisDAOFactory.getCustomMetadataTypeDAO();
String configResourceName = avaConfigMetadata.getAvalaraBaseEndpoint();
Callout_Configuration__mdt avalaraConfig = TetrisCustomMetadataTypeDAO.getResourceInfo(configResourceName);
taxCode = cart.Tax_Code__c;
//if tax code is not applied at cart level then retrieve it from Product level configuration
if (String.isBlank(taxCode)) {
List<ccrz__E_CartItem__c> cartItems = cartManager.getCartItemsByEncryptedCartId(cartId);
if ((cartItems != null) && (cartItems.size() > 0)) {
taxCode = cartItems[0].ccrz__Product__r.ccrz__TaxRateId__c;
}
}            
tax = TetrisTaxUtil.calculateTax(avalaraConfig.Endpoint_URL__c, avalaraConfig.Username__c, avalaraConfig.Password__c, companyCode, customerCode, taxCode, cartSubtotal, postalCode, country);
*/}
                                         tax.totalAmount = SSCartHelper.saveTaxInfo(cart, tax.taxAmount, vatNumber, taxCode, country);
                                         SSSubscriptionHelper.updateTaxAmount(cart.Id, tax.taxAmount);
                                         
                                     }
    
    global static Decimal saveTaxInfo(ccrz__E_Cart__c cart, Decimal taxAmount, String vatNumber, String taxCode, String country) {
        if (!String.isBlank(vatNumber)) {
            cart.VAT_Number__c = vatNumber;
            //   cart.ccrz__TaxExemptFlag__c = true;            
        }
        cart.Tax_Code__c = taxCode;
        cart.ccrz__TaxAmount__c = taxAmount;
        if(taxAmount==0){
            cart.ccrz__TaxExemptFlag__c = true;
        }
        //cart.Country__c = country;
        update cart;
        
        cart = getCartByEncryptedId(cart.ccrz__EncryptedId__c);
        return cart.ccrz__TotalAmount__c;                
    }
    
    //To be removed. Regerenced in TetrisSalesforceHelper
    global static Boolean checkoutCart(String cartId, String paymentId, String paymentMethod, Decimal taxAmount, String vatNumber) {
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        if (cart == null) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);                        
        }
        
        if (!String.isBlank(vatNumber)) {
            cart.VAT_Number__c = vatNumber;
            //   cart.ccrz__TaxExemptFlag__c = true;            
        }
        if (taxAmount != null) {
            cart.ccrz__TaxAmount__c = taxAmount;
        }
        cart.ccrz__CartStatus__c = 'Provision Pending';
        if (!String.isBlank(paymentId)) {
            //cart.Zuora_Payment_ID__c = paymentId;
        }
        if (!String.isBlank(paymentMethod)) {
            cart.ccrz__PaymentMethod__c = paymentMethod;
        }
        system.debug('-------cart.ccrz__CartType__c--------'+cart.Transaction_Type__c);
        if(cart.Transaction_Type__c!=null && (cart.Transaction_Type__c=='trial' || cart.Transaction_Type__c=='buy'))
        {
            cart.Confirmation_Email_Sent__c = true;
        }
        update cart;
        return true;        
    }
    
    global static Boolean updateAccount(String cartId, String accountId, String contactId, String storefront) {
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        if (cart == null) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);                        
        }
        if (contactId == null) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CONTACT_ID);                                    
        }
        
        Contact cartContact = [SELECT Id, FirstName, LastName, Email, Phone, 
                               MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, 
                               Account.Name, Account.Id, Account.BillingStreet FROM Contact WHERE Id =:contactId LIMIT 1];
        
        if (cartContact != null) {
            cart.ccrz__Account__c = accountId;
            cart.ccrz__Contact__c = contactId;
            cart.ccrz__ContractId__c = contactId;  
            cart.ccrz__BuyerCompanyName__c = cartContact.Account.Name;
            cart.ccrz__BuyerEmail__c = cartContact.Email;
            cart.ccrz__BuyerFirstName__c = cartContact.FirstName;
            cart.ccrz__BuyerLastName__c = cartContact.LastName;
            cart.ccrz__BuyerPhone__c = cartContact.Phone;
            cart.ccrz__EffectiveAccountID__c = accountId;
            cart.ccrz__Storefront__c =storefront;
            cart.ccrz__AnonymousId__c = false;
            // cart.ccrz__BillTo__c = null;
            cart.ccrz__CartStatus__c = SSCart.CART_STATUS_ACCOUNT_CREATED;
            
        }
        update cart;
        return true;
        
    }
    
    global static Boolean updateAccountEx(String cartId, String accountId, String contactId, String transactionType) {
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        if (cart == null) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);                        
        }
        if (contactId == null) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CONTACT_ID);                                    
        }
        
        Contact cartContact = [SELECT Id, FirstName, LastName, Email, Phone, 
                               MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, 
                               Account.Name, Account.Id, Account.BillingStreet FROM Contact WHERE Id =:contactId LIMIT 1];
        
        if (cartContact != null) {
            String billToAddressId = createCartContactAddress(cartContact.MailingStreet, '', cartContact.MailingCity, cartContact.MailingState, 
                                                              cartContact.MailingPostalCode, cartContact.MailingCountry,  cartContact.Email,
                                                              cartContact.FirstName, cartContact.LastName);
            System.debug('TetrisCartManager: updateAccountEx: billToAddressId ' + billToAddressId);
            cart.ccrz__Account__c = accountId;
            cart.ccrz__Contact__c = contactId;
            cart.ccrz__BuyerCompanyName__c = cartContact.Account.Name;
            cart.ccrz__BuyerEmail__c = cartContact.Email;
            cart.ccrz__BuyerFirstName__c = cartContact.FirstName;
            cart.ccrz__BuyerLastName__c = cartContact.LastName;
            cart.ccrz__BuyerPhone__c = cartContact.Phone;
            cart.ccrz__EffectiveAccountID__c = accountId;
           // cart.ccrz__Storefront__c = storefront;
            cart.ccrz__AnonymousId__c = false;
            cart.ccrz__BillTo__c = billToAddressId;
            cart.ccrz__ValidationStatus__c = SSCart.CART_VALIDATION_STATUS_VALIDATED;
            cart.ccrz__CartStatus__c = SSCart.CART_STATUS_ACCOUNT_CREATED;
            
            if (transactionType == null)
                transactionType = '';
            if (transactionType.equalsIgnoreCase('try'))
                transactionType = 'trial';
            transactionType = transactionType.toLowerCase();
            if (!String.isBlank(transactionType)) {
                cart.Transaction_Type__c = transactionType;            
            }
            
            update cart;
            
        }        
        return true;        
    }
    
    global static Boolean updateAccountAndLead(String cartId, String accountId, String contactId, String opportunityId, 
                                               String transactionType, String parentCartId, String vatNumber) 
    {
                                                   ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
                                                   system.debug('>>>>>'+cart.ccrz__Storefront__c);
        system.debug('>>>>>'+cart.ccrz__User__r.Name);
        system.debug('>>>>>'+cart.Locale__r.Name);
                                                   if (cart == null) {
                                                       throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);                        
                                                   }
                                                   if (contactId == null) {
                                                       throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CONTACT_ID);                                    
                                                   }
                                                   
                                                   Contact cartContact = [SELECT Id, FirstName, LastName, Email, Phone, 
                                                                          MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, 
                                                                          Account.Name, Account.Id, Account.BillingStreet FROM Contact WHERE Id =:contactId LIMIT 1];
                                                   
                                                   if (cartContact != null) {
                                                       String billToAddressId = createCartContactAddress(cartContact.MailingStreet, '', cartContact.MailingCity, cartContact.MailingState, 
                                                                                                         cartContact.MailingPostalCode, cartContact.MailingCountry,  cartContact.Email,
                                                                                                         cartContact.FirstName, cartContact.LastName);
                                                       System.debug('TetrisCartManager: updateAccountAndLead: billToAddressId ' + billToAddressId);
                                                       cart.ccrz__Account__c = accountId;
                                                       cart.ccrz__Contact__c = contactId;
                                                       cart.ccrz__ContractId__c = contactId;  
                                                       cart.ccrz__BuyerCompanyName__c = cartContact.Account.Name;
                                                       cart.ccrz__BuyerEmail__c = cartContact.Email;
                                                       cart.ccrz__BuyerFirstName__c = cartContact.FirstName;
                                                       cart.ccrz__BuyerLastName__c = cartContact.LastName;
                                                       cart.ccrz__BuyerPhone__c = cartContact.Phone;
                                                       cart.ccrz__EffectiveAccountID__c = accountId;
                                                       //cart.ccrz__Storefront__c = cart.ccrz__Storefront__c;//storefront;
                                                       cart.ccrz__AnonymousId__c = false;
                                                       cart.ccrz__BillTo__c = billToAddressId;
                                                       cart.ccrz__ValidationStatus__c = SSCart.CART_VALIDATION_STATUS_VALIDATED;
                                                       cart.ccrz__CartStatus__c = SSCart.CART_STATUS_ACCOUNT_CREATED;
                                                       if (!String.isBlank(parentCartId)) {
                                                           cart.Parent_Cart__c = parentCartId;                
                                                       }
                                                       
                                                       if (!String.isBlank(vatNumber)) {
                                                           cart.VAT_Number__c = vatNumber;                
                                                       }
                                                       //if (!String.isBlank(leadId)) {
                                                           //cart.Lead__c = leadId;
                                                      // }
                                                       if (!String.isBlank(opportunityId)) {
                                                           cart.Opportunity__c = opportunityId;
                                                       }
                                                       
                                                       if (transactionType == null)
                                                           transactionType = '';
                                                       if (transactionType.equalsIgnoreCase('try'))
                                                       {
                                                           transactionType = 'trial';
                                                           cart.Confirmation_Email_Sent__c = true;
                                                       }
                                                       transactionType = transactionType.toLowerCase();
                                                       if (!String.isBlank(transactionType)) {
                                                           cart.Transaction_Type__c = transactionType;            
                                                       }
                                                       
                                                       update cart;
                                                       
                                                   }        
                                                   return true;        
                                               }
    
    global static Boolean updateLead(String cartId,  String leadId, String opportunityId) 
    {
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        if (cart == null) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);                        
        }
        if (!String.isBlank(leadId)) {
            //cart.Lead__c = leadId;
        }
        if (!String.isBlank(opportunityId)) {
            cart.Opportunity__c = opportunityId;
        }
        
        update cart;
        
        return true;        
    }
    
    global static Boolean updateCartStatus(String cartId, String status) {
        
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        if (cart == null) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);                        
        }
        cart.ccrz__CartStatus__c = status;
        //this Validation status is needed by CloudCraze if Cart is managed through API
        cart.ccrz__ValidationStatus__c = CSSCart.CART_VALIDATION_STATUS_VALIDATED;
        update cart;
        return true;
    }
        
    global static String createCartContactAddress(String addressLine1, String addressLine2, String city, String state, 
                                                  String zipCode, String country,  String email,
                                                  String firstName, String lastName) {
                                                      ccrz__E_ContactAddr__c address = new ccrz__E_ContactAddr__c();
                                                      address.ccrz__AddressFirstline__c = addressLine1;        
                                                      address.ccrz__AddressSecondline__c = addressLine2;
                                                      address.ccrz__City__c = city;
                                                      address.ccrz__State__c = state;
                                                      
                                                      //address.ccrz__Country__c = country;
                                                      address.ccrz__Email__c = email;
                                                      address.ccrz__FirstName__c = firstName;
                                                      address.ccrz__LastName__c = lastName;
                                                      insert address;
                                                      
                                                      return address.Id;
                                                  }
    
    global static Boolean checkoutCartAndConvertLead(String cartId, String paymentId, String paymentMethod, Decimal taxAmount, String vatNumber,
                                                     string leadId,string opportunityId,string accountId, String contactId,  
                                                     string zuoraSubscriptionId, string zuoraSubscriptionNumber, String transactionType
                                                    ) 
    {
                                                        
                                                        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
                                                        if (cart == null) {
                                                            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_CART_ID);                        
                                                        }
                                                        
                                                        if (!String.isBlank(vatNumber)) {
                                                            cart.VAT_Number__c = vatNumber;
                                                            //   cart.ccrz__TaxExemptFlag__c = true;            
                                                        }
                                                        if (taxAmount != null) {
                                                            cart.ccrz__TaxAmount__c = taxAmount;
                                                        }
                                                        cart.ccrz__CartStatus__c = 'Provision Pending';
                                                        if (!String.isBlank(paymentId)) {
                                                            //cart.Zuora_Payment_ID__c = paymentId;
                                                            //cart.Payment_Method_Id__c = paymentId;
                                                        }
                                                        if (!String.isBlank(paymentMethod)) {
                                                            cart.ccrz__PaymentMethod__c = paymentMethod;
                                                        }
                                                        system.debug('-------cart.ccrz__CartType__c--------'+cart.Transaction_Type__c);
                                                        if(cart.Transaction_Type__c!=null && (cart.Transaction_Type__c=='trial' || cart.Transaction_Type__c=='buy'))
                                                        {
                                                            cart.Confirmation_Email_Sent__c = true;
                                                        }
                                                        
                                                        if (String.isNotBlank(zuoraSubscriptionId)) {
                                                            //cart.Zuora_Subscription_ID__c = zuoraSubscriptionId;
                                                            //cart.Zuora_Subscription_Number__c = zuoraSubscriptionNumber;                                         
                                                        }
                                                        update cart;
                                                        
                                                        if ((String.isNotBlank(opportunityId)) && (String.isNotBlank(accountId))) {
                                                            list<Opportunity> oppList = [SELECT Id from Opportunity WHERE AccountId =: accountId and Id=:opportunityId ];
                                                            for (Opportunity opp: oppList) {
                                                                opp.StageName = 'Closed Won';
                                                            }
                                                            update oppList;
                                                        }  
                                                        //Added for Converted Leads 03/21/2018
                                                        if ((String.isNotBlank(leadId))) {
                                                            list<Lead> leadList = [SELECT Id from lead WHERE Id =: leadId ];
                                                            for (Lead lead: leadList) {
                                                                lead.Status = 'Qualified';
                                                            }
                                                            update leadList;
                                                        }
                                                        
                                                        return true;        
                                                    }
    
    global static void updateCartWithBillingDetails(String cartId, String billingSubscriptionId, String billingSubscriptionNumber) {
        ccrz__E_Cart__c cartInfo = getCartByEncryptedId(cartId);
        if (String.isNotBlank(billingSubscriptionId)) {   
            //cartInfo.Zuora_Subscription_Number__c = zuoraSubscriptionNumber;    
            //cartInfo.Zuora_Subscription_ID__c = zuoraSubscriptionId;
            update cartInfo;                    
        }
    }    
    
    global static void updateCartWithPaymentDetails(String cartId, String zuoraSubscriptionId, String zuoraSubscriptionNumber, String paymentMethodId) {
        ccrz__E_Cart__c cartInfo = getCartByEncryptedId(cartId);
        if (String.isNotBlank(zuoraSubscriptionId)) {   
            //cartInfo.Zuora_Subscription_Number__c = zuoraSubscriptionNumber;    
            //cartInfo.Zuora_Subscription_ID__c = zuoraSubscriptionId;
        }
        //cartInfo.Payment_Method_Id__c = paymentMethodId;
        update cartInfo;                    
    }    
    
    global static void updateProductTierInfo(String cartId, String productSKU, Decimal quantity, Double price) {
        List<ccrz__E_CartItem__c> cartItems = getCartItemsByEncryptedCartId(cartId);
        for (ccrz__E_CartItem__c cartItem: cartItems) {
            String cartItemSKU = cartItem.ccrz__Product__r.ccrz__SKU__c;
            if (productSKU.equals(productSKU)) {
                cartItem.ccrz__Price__c = price;
                cartItem.ccrz__Quantity__c = quantity;
                Double absoluteDiscount = cartItem.ccrz__AbsoluteDiscount__c;
                Double percentageDiscount = cartItem.ccrz__PercentDiscount__c;
                //check for Percentage Discount first and then Absolute discount
                if (percentageDiscount != null) {
                    cartItem.ccrz__SubAmount__c = (price * (100 - percentageDiscount))/100;
                }
                else {
                    if (absoluteDiscount != null) {                        
                        cartItem.ccrz__SubAmount__c = price - absoluteDiscount;                    
                    }
                    else {
                        cartItem.ccrz__SubAmount__c = price;                    
                    }
                }
                //ccrz__Price__c
                update cartItem;
            }
        }                
    }
    
    global static Boolean checkCouponAmountApplied(ccrz__E_Cart__c cart , List<ccrz__E_CartItem__c> cartItemList) {
        CSSContext ecommContext = new CSSContext();
        for(ccrz__E_CartItem__c cartItem : cartItemList){
            system.debug('----cartItem.ccrz__Coupon__c----'+cartItem.ccrz__Coupon__c);
            system.debug('----cartItem.ccrz__AbsoluteDiscount__c----'+cartItem.ccrz__AbsoluteDiscount__c);
            if(cartItem.ccrz__Coupon__c!=null && 
               (cartItem.ccrz__AbsoluteDiscount__c==null || cartItem.ccrz__AbsoluteDiscount__c==0))
            {
                system.debug('----cartItem.ccrz__Coupon__r.ccrz__CouponCode__c----'+cartItem.ccrz__Coupon__r.ccrz__CouponCode__c);
                ccrz__E_Coupon__c couponObject = CSSCouponHelper.getCouponDetailsByCouponCode(cartItem.ccrz__Coupon__r.ccrz__CouponCode__c);
                CSSCouponHelper.updateCouponsOnCartItems(cart, cartItem, couponObject);
            }
        }
        return true;
    }
    
    global static CSSCartModel createCart(String storefront, String userName, String userLocale, String userCurrency, String cartName, String transactionType) 
    {
        System.debug('creating cart');        
        CSSCartModel cartModel = new CSSCartModel();
        try {            
            String cartId = createCart(storefront, userName, userLocale);
            System.debug('##########################Cart created - ID is ' + cartId);
            
            //fix bug with CloudCraze API not updating cart name
            ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
            cart.ccrz__Name__c = cartName;
            cart.ccrz__CartId__c = cart.Id;
            if (String.isNotBlank(transactionType)) {
            cart.Transaction_Type__c = transactionType;            
            }
            //cart.Transaction_Reference_Number__c = TetrisUtility.generateTRN();
            Locale__c localeObj = CSSAccountHelper.fetchCountryLocale(userLocale);
            if(localeObj!=null)
            {
                cart.Locale__c = localeObj.Id;
                //cart.ccrz__Storefront__c = 'Adobe';
               // cart.Country__c = userLocale.substring(3);
            }
             update cart;
            
            //cartModel =  SSCartHelper.getCart(cartId);            
            cartModel.cartId = cartId;
            cartModel.setStatus(true);
        }
        catch (Exception ex) {
            cartModel.setErrorMessage(ex.getMessage());
            cartModel.setStatus(false);            
        }
        return cartModel;
    } 
    
    global static List<ccrz__E_Cart__c> getCartsByEncryptedIds(List<String> encryptedIds){
        return [SELECT Id, Transaction_Type__c,  ccrz__TotalAmount__c, ccrz__CartStatus__c,
            ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, ccrz__TotalQuantity__c, ccrz__Contact__c, ccrz__Account__c, 
            ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, ccrz__BuyerEmail__c, ccrz__BuyerCompanyName__c,
            Name, ccrz__EncryptedId__c, Parent_Cart__c
                    FROM ccrz__E_Cart__c 
                        WHERE ccrz__EncryptedId__c IN : encryptedIds];
    }
    
   	global static Boolean removeProductFromCart(String encCartId, String productSku) {
        System.debug('removing cart item');
        Id productId = getProductIdBySku(productSku);
        System.debug('product retrieved');
        try {
            ccrz__E_Cart__c currentCart = CSSCartHelper.getCartByEncryptedId(encCartId);
            ccrz__E_CartItem__c cartItem = [SELECT id FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c =: currentCart.ID AND ccrz__Product__c =: productId limit 1];
            delete cartItem;
        }
        catch (Exception ex) {
            //ExceptionLogUtility.TetrisException te = new ExceptionLogUtility.TetrisException('Exception adding Product to Cart.' + ex.getMessage());
            //throw te;            
        }
        System.debug('cart item deleted');
        return true;
    }
    
    global static Id getCouponId(String couponName) {
        Id couponId = null;
        try {
            couponId = [select id from ccrz__E_Coupon__c where ccrz__CouponCode__c=:couponName limit 1].id;
        } 
        catch (Exception ex) {
            //ExceptionLogUtility.TetrisException te = new ExceptionLogUtility.TetrisException('Invalid Coupon Code. Unable to retrieve Coupon information.');
            //throw te;
        }
        return couponId;
    }
    
    global static Id getProductIdBySku(String productSku) {
        Id productId = null;
        try {
            productId = [select id from ccrz__E_Product__c where ccrz__SKU__c=:productSku limit 1].id;
        } 
        catch (Exception ex) {
            //ExceptionLogUtility.TetrisException te = new ExceptionLogUtility.TetrisException('Invalid Product SKU. Unable to retrieve Product information.');
            //throw te;
        }
        return productId;
    }
    
    global static Boolean priceCart(String cartId){

        ccrz.ccLog.log(LoggingLevel.DEBUG,'SAGE','In CCServiceUtility : priceCart : cartId : ' + cartId );
        Savepoint sp = Database.setSavepoint();
        Boolean wasSuccessful = false;
        try {
            ccrz.ccContext ctx = new ccrz.ccContext();
            ctx.storefront = 'Adobe';
            ccrz.cc_CallContext.initContext(ctx);

            Map<String,Object> priceResults = ccrz.ccApiCart.price(new Map<String,Object>{
                 ccrz.ccApi.API_VERSION => 1,
                 ccrz.ccApiCart.CART_ID => cartId
            });

            wasSuccessful = (Boolean) priceResults.get(ccrz.ccApi.SUCCESS);

        } catch(Exception e){
            wasSuccessful = false;
            ccrz.ccLog.log(LoggingLevel.DEBUG,'SAGE','CCServiceUtility : priceCart : exception : ' + e);

            //ExceptionLogUtility.insertErrorLog(e, 'Tetris', '', '', 
                      // CCServiceUtility.class.getName(), 'priceCart', 'High');
        }

        if(!wasSuccessful){
            Database.rollback(sp);
        }
        return wasSuccessful; 
    }
    
    global static Boolean addCouponToCart(String encCartId, String couponName, Decimal price) {
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
        System.debug('creating cart item for coupon');
        Id couponId = getCouponId(couponName);
        cartItem.ccrz__Coupon__c = couponId;    
        System.debug('coupon retrieved');
        try {
            cartItem.ccrz__cartItemType__c = 'coupon';
            ccrz__E_Cart__c currentCart;
            currentCart = getCartByEncryptedId(encCartId);
            cartItem.ccrz__Cart__c = currentCart.ID;
            cartItem.ccrz__Price__c = price;
            insert cartItem;
        }
        catch (Exception ex) {
            //ExceptionLogUtility.TetrisException te = new ExceptionLogUtility.TetrisException('Exception adding Coupon to Cart.' + ex.getMessage());
            //throw te;            
        }
        System.debug('cart item created');
        return true;
    }

    global static Boolean removeCouponFromCartEx(String encCartId, String couponName) {
        System.debug('removing cart item');
        Id couponId = getCouponId(couponName);
        System.debug('product retrieved');
        try {
            ccrz__E_Cart__c currentCart = getCartByEncryptedId(encCartId);
            ccrz__E_CartItem__c cartItem = [SELECT id FROM ccrz__E_CartItem__c WHERE ccrz__Cart__c =: currentCart.ID AND ccrz__Coupon__c =: couponId limit 1];
            delete cartItem;
        }
        catch (Exception ex) {
            //ExceptionLogUtility.TetrisException te = new ExceptionLogUtility.TetrisException('Exception removing Coupon from Cart.' + ex.getMessage());
            //throw te;            
        }
        System.debug('cart item deleted');
        return true;
    }
    
    global Static Boolean isBillingAccountRequired (String cartId) {
        Boolean IsBillingAccountRequired = false;
        List<ccrz__E_CartItem__c> cartItems = [SELECT ccrz__Product__r.ccrz__SKU__c,ccrz__Product__r.Id,ccrz__Product__r.Is_Trial_Product__c FROM ccrz__E_CartItem__c where ccrz__Cart__r.ccrz__EncryptedId__c =: cartId and ccrz__cartItemType__c= 'Major'];
        If(cartItems.size()!=0){
            for(ccrz__E_CartItem__c item: cartItems) {
                if(item.ccrz__Product__r.Is_Trial_Product__c == false) {
                   IsBillingAccountRequired = true; 
                }
            }
        }
        
        return IsBillingAccountRequired;
        
    }
    
    global static String fetchTheCart(String cartId){
        Savepoint sp = Database.setSavepoint();
        Boolean wasSuccessful = false;
        Map<String,Object> cartResults;
        try {
            CSSContext ecommContext = new CSSContext();
            ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
            ccrz.ccContext ctx = ecommContext.getCCContextForAnonymousUser(cart.ccrz__Storefront__c, cart.ccrz__User__r.Name, cart.Locale__r.Name) ; 
            cartResults =  ccrz.ccApiCart.fetch(new Map<String,Object>{
                ccrz.ccApi.API_VERSION => 7,
                ccrz.ccApiCart.CART_ID => cartId
            });
        	wasSuccessful = (Boolean) cartResults.get(ccrz.ccApi.SUCCESS);
        } catch(Exception e) {
            wasSuccessful = false;
		}

        if(!wasSuccessful){
            Database.rollback(sp);
            return String.valueOf(((Map<String, Object>) ((List<Object>) cartResults.get(ccrz.ccApiCart.CART_OBJLIST))[0]).get('totalAmount') );
        }
        return null;
    } 
    
    global static Boolean addDynamicKitToCart(String cartId, List<CSSCartItemModel> cartItems) {
        CSSContext ecommContext = new CSSContext();
        String strProductType='';
        System.debug('retrieving cart');
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        List<ccrz__E_CartItem__c> currentCartItems = getCartItemsByEncryptedCartId(cartId);
        Boolean isBundledProduct = false;
        Boolean isSuccess = false;
        String strBundleSku ;
        system.debug('adding cart items ' + cartItems);
       
        List<ccrz__E_CartItem__c> lstMinorCartItem = new List<ccrz__E_CartItem__c>();
        set<string> setDynamicKitMajorSKU = new set<string>();
        Map<String,Object> lineFinalDataMap = new Map<String, Object>();
        Set<string> setProdSkus = new Set<String>();
        Map<String,String> mapChildSkuCoupon = new Map<String,String>();
        Map<String,String> mapRelatedProductSKU = new Map<String,String>();
        
        //loop through all the Cart Items and check for bundles
        for (CSSCartItemModel cartItem: cartItems) {
           if (cartItem.product.productType.equals('Dynamic Kit') || cartItem.product.productType.equals('Bundle')) {
                isBundledProduct = true;
                strBundleSku = cartItem.product.productSKU;
                setDynamicKitMajorSKU.add(cartItem.product.productSKU);
           }
           
           //retrieve the coupon associated with the bundle
           if(isBundledProduct && strBundleSku != null)
	           mapChildSkuCoupon = getChildSkuCoupon(cartItems,strBundleSku);
           
           system.debug('>>>>>>'+mapChildSkuCoupon);
            
           //Vikram: is this check even needed
           //sku associated with the current cart item
           String sku = cartItem.product.productSKU;
           //check if the SKU passed is valid
           CSSProductModel product = CSSProductHelper.getProductInfoBySKU(sku);
           if (product == null) {
                throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_PRODUCT_SKU);
           }    
           system.debug('>>>>>>' + product);
            
            //retrieve the Subscription Prod Term ID if it is not passed or empty
            String subProdTermId = cartItem.subProdTermId;
            if (String.isBlank(subProdTermId))
            {
                String productId = product.productId;  
                List<Map<String, String>> subProdTermList = CSSProductHelper.getSubProdTerms(productId,cartItem.subscriptionTermType);
                if(!subProdTermList.Isempty())
                {
                  subProdTermId = subProdTermList[0].get('subscriptionTermId');
                }
                system.debug('>>>>>>' + subProdTermId);
            }

            ccrz__E_CartItem__c parentlineData = new ccrz__E_CartItem__c();
           	mapRelatedProductSKU = new Map<String,String>();
            system.debug('>>>>>> Creating parent map' );
               
         	parentlineData.ccrz__Product__c = product.productId;
            parentlineData.ccrz__Quantity__c = cartItem.quantity;
            parentlineData.ccrz__SubProdTerm__c = subProdTermId;
            parentlineData.ccrz__ProductType__c = 'Dynamic Kit';
            parentlineData.ccrz__cartItemType__c = 'Major';
            parentlineData.ccrz__Price__c = 0;
            parentlineData.ccrz__SubAmount__c = 0;
            parentlineData.ccrz__Cart__c = cart.Id;
            parentlineData.ccrz__StoreID__c = 'Adobe';//getDefaultStorefront
            system.debug('>>>>>> Creating parent map '+parentlineData);
            //following fields are required in order to create CC subscription using CCApi.Place
            parentlineData.ccrz__RequestDate__c = system.today();
            parentlineData.ccrz__OriginalItemPrice__c = 0;
            parentlineData.ccrz__OriginalQuantity__c = cartItem.quantity;
            parentlineData.ccrz__RecurringPrice__c = 0 ;
            parentlineData.ccrz__RecurringPriceSubAmt__c = 0;
            Insert parentlineData ; 
               
            system.debug('>>>>>> Creating parent map'+cartItem.selectedBundleComponentList);
               
         	List<ccrz__E_CartItem__c> lstChildCartItem = new List<ccrz__E_CartItem__c>();
			if(cartItem.selectedBundleComponentList != null)
            {
            	for(CSSProductModel obj : cartItem.selectedBundleComponentList)
                {     
                	system.debug('>>>>>> Creating parent map'+obj);
                    String strChildProdId = CSSProductHelper.getProductInfoBySKU(obj.productSKU).productId;
                    //Vikram: where is the selected tier information passed
                    CSSProductPriceModel objprc = CSSProductHelper.fetchProductPriceDetails
                           (obj.productSKU,CSSproductHelper.isADCPriced(obj.productSKU)?null:cartItem.subscriptionTermType);
                           
                    system.debug('objprc'+objprc);
                    ccrz__E_CartItem__c childlineData = new ccrz__E_CartItem__c();
    				childlineData.ccrz__Product__c = strChildProdId;
                    system.debug('objprc'+obj);
                           
                    if(obj.bundleChildSelectedTierList != null)
                    {
                    	List<String> lstattrVal = new List<String>();
                        List<String> lstattrID = new List<String>();
                        Map<String,String> mapattrVal = new Map<String,String>();
                                
                        for(CSSPriceTierModel objTier : obj.bundleChildSelectedTierList) 
                        {
                        	if(objTier.tierAttribute != null && objTier.attributeValue != '' && CSSproductHelper.isTierPriced(obj.productSKU))
                           	{
                            	childlineData.ccrz__Quantity__c = Decimal.ValueOf(objTier.attributeValue);
                                      
                                //For Tiered Product , Based on the Best Price List Item Id and using quantity we'll get the right price
                                Map<string,String> productTier = new Map<String,String>();
                                productTier.put('tierQuantity',objTier.attributeValue);    
                                      
                                Decimal dTieredPrc = 0 ;
                                List<CSSPriceTierModel> objTierPrice = CSSProductHelper.getTierdPricingInfo(objprc.priceListItemID,null,productTier);
                                      
                                if(objTierPrice != null)
                                {
                                      dTieredPrc = objTierPrice[0].listPrice;
                                      system.debug('dTieredPrc'+dTieredPrc);
                                }
                                childlineData.ccrz__SubAmount__c = dTieredPrc * Decimal.ValueOf(objTier.attributeValue);
                                childlineData.ccrz__Price__c = dTieredPrc ;
                          	}
                            else if(objTier.tierAttribute != null && objTier.attributeValue != '' && SSproductHelper.isADCPriced(obj.productSKU))
                           	{
                            	lstattrVal.add(objTier.attributeValue);//SFDC IDs for Attribute Product
                                lstattrID.add(objTier.tierAttribute);
                           	}
                    	}
                                
                        if(!lstattrVal.Isempty())// ONLY if the Product Type is ADC
                        {
                        	for(Integer i=0; i< lstattrVal.size(); i++){
                            Switch on i {
                            	when 0{
                                	System.debug('Switch 1');
                                    childlineData.ccrz__PrimaryAttr__c = lstattrVal.get(0);
                               	}
                                when 1{
                                	System.debug('Switch 2');
                                    childlineData.ccrz__SecondaryAttr__c = lstattrVal.get(1);
                              	}
                                when 2{
                                	System.debug('Switch 3');
                                    childlineData.ccrz__TertiaryAttr__c = lstattrVal.get(2);
                              	}
                         	}
                      	}
                                       
                        Decimal dBestPrc = adctestclass.getADCPricing(lstattrID,objprc.priceListItemID);
                        childlineData.ccrz__Quantity__c = cartItem.quantity;
                        childlineData.ccrz__SubAmount__c = dBestPrc * cartItem.quantity;
                        childlineData.ccrz__Price__c = dBestPrc ;
                  	}
        		}
                else
                {
                	childlineData.ccrz__Quantity__c = obj.bundleChildQuantity;
                    childlineData.ccrz__SubAmount__c = objprc.bestPrice * obj.bundleChildQuantity;
                    childlineData.ccrz__Price__c = objprc.bestPrice ;
               	}
                           
                childlineData.ccrz__ProductType__c = 'Product';
                childlineData.ccrz__cartItemType__c = 'Minor';
              	childlineData.ccrz__Cart__c = cart.Id;
                //following fields are required in order to create CC subscription using CCApi.Place
                childlineData.ccrz__RequestDate__c = system.today();
                childlineData.ccrz__OriginalItemPrice__c = objprc.bestPrice ;
                childlineData.ccrz__OriginalQuantity__c = obj.bundleChildQuantity;
                childlineData.ccrz__RecurringPrice__c = objprc.bestPrice ;
              	childlineData.ccrz__RecurringPriceSubAmt__c = objprc.bestPrice * obj.bundleChildQuantity;
                childlineData.ccrz__ParentCartItem__c = parentlineData.Id;
                childlineData.ccrz__StoreID__c = 'Adobe';//getDefaultStorefront;
    			lstChildCartItem.add(childlineData);
                system.debug('>>>>>>'+childlineData);
          	}
       	} 
        if(!lstChildCartItem.IsEmpty())
               Insert lstChildCartItem;
   		
        }
    
    	Set<Id> setProductIds = new Set<Id>();
    	List<ccrz__E_CartItem__c> cartItemList = getCartItemsByEncryptedCartId(cartId);
        System.debug('cartItemList');
		try {
       		for (CSSCartItemModel cartItem: cartItems) {
            	if( cartItem.couponCode != null)//Apply Coupon on parent/Major Item
                {
                	System.debug('cart.cartId ' + cart.ccrz__EncryptedId__c);
                    System.debug('cart.couponCode ' + cartItem.couponCode);
                    CSSCouponHelper.addCouponsOnCartItems( cart.ccrz__EncryptedId__c,cartItem.couponCode);
                }  
                      
                if(cartItem.selectedBundleComponentList != null)//Apply Coupon on children/Minor Item
                {
                	for(CSSProductModel obj : cartItem.selectedBundleComponentList)
                    {     
                    	system.debug('>>>>>> Creating parent map'+obj);
                        if(obj.productSKU != null)
                        {
                        	if(mapChildSkuCoupon.ContainsKey(obj.productSKU))//Mapping of Product SKU and Coupons
                            { 
                            	system.debug('>>>>parent'+cartItem.product.productSKU);
                                String strChldCoupn = mapChildSkuCoupon.get(obj.productSKU);
                                CSSCouponHelper.addCouponsOnCartItems(cart.ccrz__EncryptedId__c,strChldCoupn,cartItem.product.productSKU);
                           	}
                      	}
                   	}
            	} 
                           
                System.debug(' coupon applied successfully ' + cartItem.couponCode + ' on cart ' + cart.ccrz__EncryptedId__c);
           	}
            //Updating SubAmount : If Dynamic Kit (Parent/major) has a coupon
            if(!setDynamicKitMajorSKU.IsEmpty())
                  updateSubAmtonDynamicKit(cart.ccrz__EncryptedId__c,setDynamicKitMajorSKU);
            isSuccess = true;    
        }
        catch (Exception ex) {
            System.debug('Exception applying coupon ' + ex.getMessage());
        }
        return isSuccess;
    }
    
}