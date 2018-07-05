global class CSSCouponHelper {
    
    private static final String COUPON_RULE_TYPE_GENERAL = 'General';
    private static final String COUPON_RULE_TYPE_CART_TOTAL = 'CartTotal';
    private static final String COUPON_TYPE_ABSOLUTE = 'Absolute';
    private static final String COUPON_TYPE_PERCENTAGE = 'Percentage';
    private static final String COUPON_TYPE_PRICE = 'Price';
    private static final String DEFAULT_STORE = 'DefaultStore';
        
    global static Boolean addCouponsOnCartItems(String cartId , String couponCode){        
        return addCouponsOnCartItems(cartId, couponCode,null);
    }
    
    //fix for CC bug
    //Adding Multiple Coupons on Cart 
    global Static Boolean addCouponsOnCartItems(String cartId , String couponCode,String strParentSKU) {
        Savepoint sp = Database.setSavepoint();
        Boolean blnCouponApplied = false;
        Double dblDiscountedAmount = 0;
        try {
          // SSCartHelper cartHelper = new SSCartHelper();
            system.debug('--------couponCode---------'+couponCode);
            ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
            if(cart!=null)
            {
                String strCartId = cart.Id;
                List<ccrz__E_CartItem__c> cartItems = getCartItemsByEncryptedCartId(cartId);
                ccrz__E_Coupon__c couponObject = getCouponDetailsByCouponCode(couponCode);
                system.debug('--------couponObject---------'+couponObject);
                
                //checking Coupon Validity
                checkCouponValidity(couponObject);

                //If Code Code is not applied then adding the coupon code to cart and Coupon Discount Not Null
                if(couponObject!=null && couponObject.ccrz__DiscountAmount__c != null)
                {
                    //Checking and Calling Cart Coupon type 
                    if(COUPON_RULE_TYPE_CART_TOTAL == couponObject.ccrz__RuleType__c )
                    {
                        blnCouponApplied = addCouponRuleTypeCart(cart , couponObject , couponCode);
                    }
                    else if(COUPON_RULE_TYPE_GENERAL == couponObject.ccrz__RuleType__c)
                    {
                        blnCouponApplied = addCouponRuleTypeGeneral(cart , cartItems , couponObject,strParentSKU);
                    }
                    if(blnCouponApplied)
                    {
                        update cartItems;
                        //checking for the Coupon code applied to the Cart
                        Boolean blnCouponCodeNotApplied = checkCouponCodeApplied(couponCode, strCartId);
                        system.debug('--------blnCouponCodeNotApplied---------'+blnCouponCodeNotApplied);
                        if(blnCouponCodeNotApplied)
                        {
                            ccrz__E_CartCoupon__c cartCoupon = new ccrz__E_CartCoupon__c();
                            cartCoupon.ccrz__Cart__c = cart.Id;
                            cartCoupon.ccrz__Coupon__c = couponObject.Id;
                            system.debug('--------cartCoupon---------'+cartCoupon);
                            insert cartCoupon;
                        }
                    }else{
                        throw new CSSCartException(CSSCartException.EXCEPTION_COUPON_NOT_APPLIED);
                    }
                }
                else{
                    throw new CSSCartException(CSSCartException.EXCEPTION_CART_COUPON_LIMIT);
                }
            }
        }catch (Exception ex) {
            Database.rollback(sp);
            System.debug('SSCouponHelper: add coupon exception ' + ex.getMessage());
            throw new CSSCartException(CSSCartException.EXCEPTION_APPLY_COUPON);
        }
        System.debug('updates completed');
        return true;
    }
    
    global Static Boolean removeCouponsFromCart(String cartId, String couponCode) {
        Savepoint sp = Database.setSavepoint();
        Boolean wasSuccessful = false;
        Boolean blnCouponRemoved = false;
        Double dblDiscountedAmount  = 0;
        try {
            ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
            List<ccrz__E_CartItem__c> cartItems = getCartItemsByEncryptedCartId(cartId);
            ccrz__E_Coupon__c couponObject = getCouponDetailsByCouponCode(couponCode);
            //check if the Coupon is applied on the Cart
            List<ccrz__E_CartCoupon__c> lstCartCoupons = [Select ccrz__Enabled__c, ccrz__Coupon__r.Id, ccrz__Coupon__r.ccrz__CouponCode__c,
                                                            ccrz__Cart__c, ccrz__CartCouponId__c, Name, Id, CurrencyIsoCode From ccrz__E_CartCoupon__c 
                                                            where ccrz__Cart__c=:cart.Id and ccrz__Coupon__r.ccrz__CouponCode__c=:couponCode];
            system.debug('----lstCartCoupons----------'+lstCartCoupons);
            if(lstCartCoupons!=null && lstCartCoupons.size()>0)
            {
                if(COUPON_RULE_TYPE_CART_TOTAL == couponObject.ccrz__RuleType__c)
                {
                    if(cart.Coupon_Applied__c && (COUPON_TYPE_PERCENTAGE == couponObject.ccrz__CouponType__c || COUPON_TYPE_ABSOLUTE == couponObject.ccrz__CouponType__c))
                    {
                        for(ccrz__E_CartItem__c cartItem: cartItems)
                        {
                            if(cartItem.ccrz__cartItemType__c == 'Coupon' && cartItem.ccrz__Coupon__c== couponObject.Id)
                            {
                                    dblDiscountedAmount = cartItem.ccrz__AbsoluteDiscount__c;
                                delete cartItem;
                            }
                        }
                        cart.Coupon_Applied__c = false;
                        update cart;
                        blnCouponRemoved = true;
                    }else
                    {
                        throw new CSSCartException('Coupon Code not applied on the Cart. Coupon Code - ' + couponCode);
                    }
                }
                else if(COUPON_RULE_TYPE_GENERAL == couponObject.ccrz__RuleType__c)
                {
                    for (ccrz__E_CartItem__c cartItem: cartItems) {
                        
                        String productId = cartItem.ccrz__Product__c;
                        if(productId == couponObject.ccrz__TargetProduct__c && cartItem.ccrz__Coupon__c!=null)
                        {
                                dblDiscountedAmount = cartItem.ccrz__AbsoluteDiscount__c;
                                system.debug('----------dblDiscountedAmount-------'+dblDiscountedAmount);
                            cartItem.ccrz__SubAmount__c =  cartItem.ccrz__Price__c;
                            cartItem.ccrz__AbsoluteDiscount__c = null ;
                            cartItem.ccrz__PercentDiscount__c = null;
                            blnCouponRemoved = true;
                            cartItem.ccrz__Coupon__c = null;
                            update cartItem;
                        }
                    }
                }
                if(blnCouponRemoved)
                {
                    //If Cart Item and CartUpdate then Delete the Cart Coupon Record
                    delete lstCartCoupons;
                    system.debug('---------dblDiscountedAmount------'+dblDiscountedAmount);
                        system.debug('---------cart.ccrz__TotalDiscount__c before------'+cart.ccrz__TotalDiscount__c );
                        cart.ccrz__TotalDiscount__c = cart.ccrz__TotalDiscount__c - dblDiscountedAmount;
                    system.debug('---------cart.ccrz__TotalDiscount__c after------'+cart.ccrz__TotalDiscount__c );
                    update cart;
                    wasSuccessful = true;
                }
            }
            else{
                throw new CSSCartException('Coupon Code not applied on the Cart. Coupon Code - ' + couponCode);
            }
        }catch (Exception ex) {
            Database.rollback(sp);
            system.debug('---ex--------'+ex );
            throw new CSSCartException('Coupon Code not applied on the Cart. Coupon Code - ' + couponCode);
        }
        System.debug('remove coupon from cart status' + wasSuccessful);        
        return wasSuccessful;
    }
    
    //fix for CC bug
    //Adding Multiple Coupons on Cart 
    global Static Boolean updateCouponsOnCartItems(ccrz__E_Cart__c cart , ccrz__E_CartItem__c cartItem , ccrz__E_Coupon__c couponObject) {
        Savepoint sp = Database.setSavepoint();
        Boolean blnCouponApplied = false;
        Double dblDiscountedAmount = 0;
        String productId = cartItem.ccrz__Product__c;
        system.debug('----productId------------'+productId);
        system.debug('----couponObject.ccrz__TargetProduct__c------------'+couponObject.ccrz__TargetProduct__c);
        if(productId == couponObject.ccrz__TargetProduct__c )
        {
            dblDiscountedAmount = getDiscountedAmount(couponObject , cartItem.ccrz__Price__c );
            system.debug('----dblDiscountedAmount------------'+dblDiscountedAmount);
            if(COUPON_TYPE_PERCENTAGE == couponObject.ccrz__CouponType__c)
            {
                cartItem.ccrz__PercentDiscount__c = couponObject.ccrz__DiscountAmount__c;
            }
            //to Fix Coupon Type Price issue
            cartItem.ccrz__SubAmount__c = cartItem.ccrz__Price__c - dblDiscountedAmount;
            if(COUPON_TYPE_PRICE ==  couponObject.ccrz__CouponType__c)
            {
                cartItem.ccrz__SubAmount__c = dblDiscountedAmount;
            }
            cartItem.ccrz__AbsoluteDiscount__c = dblDiscountedAmount ;
            cartItem.ccrz__Coupon__c = couponObject.Id;
            blnCouponApplied = true;
            //updated the Cart Data with Discounted Price
            system.debug('---------dblDiscountedAmount------'+dblDiscountedAmount);
            system.debug('---------cart.ccrz__TotalDiscount__c before------'+cart.ccrz__TotalDiscount__c );
            cart.ccrz__TotalDiscount__c = dblDiscountedAmount;
            
            system.debug('---------cart.ccrz__TotalDiscount__c after------'+cart.ccrz__TotalDiscount__c );
            update cartItem;
            update cart;
        }        
        return blnCouponApplied;
    }
    /*
    * Fetch Coupon Details by passing Coupon Code
    *
    */
    global Static ccrz__E_Coupon__c getCouponDetailsByCouponCode(String couponCode) {
        try {
          List<ccrz__E_Coupon__c> lstCouponCode = [Select ccrz__TargetRelation__c, ccrz__TargetQty__c, ccrz__TargetProduct__c, ccrz__StartDate__c, ccrz__MinQty__c, ccrz__RuleType__c, 
                    ccrz__EndDate__c, ccrz__Enabled__c, ccrz__DiscountAmount__c, ccrz__CurrencyISOCode__c, ccrz__Coupon_Notes__c, ccrz__CouponType__c, 
                    ccrz__CouponName__c, ccrz__CouponId__c, ccrz__CouponCode__c, Period__c, Name, Id, CurrencyIsoCode,ccrz__CartTotalAmount__c
                    From ccrz__E_Coupon__c where ccrz__Enabled__c=true and ccrz__CouponCode__c =: couponCode LIMIT 1];  
           if(lstCouponCode!=null && lstCouponCode.size()>0)
           {
               return lstCouponCode[0];
           }
        }
        catch (System.QueryException ex) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_COUPON);            
        }
        return null;
    }
    
      global Static Boolean addCouponToCart(String cartId, String couponCode) {
         CSSContext ecommContext = new CSSContext();
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        
        system.debug('>>>>>'+cart.ccrz__Storefront__c);
        system.debug('>>>>>'+cart.ccrz__User__r.Name);
        system.debug('>>>>>'+cart.Locale__r.Name);
        system.debug('>>>>>'+couponCode);
        
        ccrz.ccContext ctx = ecommContext.getCCContextForAnonymousUser(cart.ccrz__Storefront__c, cart.ccrz__User__r.Name, cart.Locale__r.Name) ;
        
       // ccrz.ccContext ctx = ecommContext.getCCContextForAnonymousUser();
        Map<String,Object> ccMap = ecommContext.getCCApiVersion();
        //add item to cart
        Map<String,Object> addResults = ccrz.ccApiCart.addTo(new Map<String,Object>{
            ccrz.ccApi.API_VERSION => 7,
                ccrz.ccApiCart.CART_ENCID => cartId,
                ccrz.ccApiCart.COUPON_CODE => couponCode
                });
        System.debug('calling api');
        Boolean wasSuccessful = (Boolean) addResults.get(ccrz.ccApi.SUCCESS);  
        System.debug('add coupon to cart status' + wasSuccessful);        
        return wasSuccessful;
    }
    
    global static Boolean removeCouponFromCart(String cartId, String couponCode) {
  		CSSContext ecommContext = new CSSContext();
 		ccrz__E_Cart__c cart = SSCartHelper.getCartByEncryptedId(cartId);
        
        system.debug('>>>>>'+cart.ccrz__Storefront__c);
        ccrz.ccContext ctx = ecommContext.getCCContextForAnonymousUser(cart.ccrz__Storefront__c, cart.ccrz__User__r.Name, cart.Locale__r.Name) ;
        
		Map<String,Object> removeResults = ccrz.ccApiCart.removeFrom(new Map<String,Object>{
									ccrz.ccApi.API_VERSION => 7,
									ccrz.ccApiCart.CART_ENCID => cartId,
									ccrz.ccApiCart.COUPON_CODE => couponCode
		});

		System.debug('calling remove coupon api');
		Boolean wasSuccessful = (Boolean) removeResults.get(ccrz.ccApi.SUCCESS);  
		System.debug('remove coupon from cart status' + wasSuccessful);        
		return wasSuccessful;
    }
    
    private Static void checkCouponValidity(ccrz__E_Coupon__c couponObject){
        Date todaysDate = System.today();
        if(couponObject.ccrz__StartDate__c!=null && couponObject.ccrz__EndDate__c!=null)
        {
            if(!(todaysDate>=couponObject.ccrz__StartDate__c)){
            
              throw new CSSCartException(SSCartException.EXCEPTION_INVALID_COUPON);
                
            }else if(!(couponObject.ccrz__EndDate__c>=todaysDate))
            {
                throw new CSSCartException(SSCartException.EXCEPTION_EXPIRED_COUPON);
            }
        }
    }
    
    private Static Boolean addCouponRuleTypeCart(ccrz__E_Cart__c cart , ccrz__E_Coupon__c couponObject , String couponCode){
        Boolean blnCouponApplied = false;
        Double dblDiscountedAmount = 0;
        if(!cart.Coupon_Applied__c)
        {
            Boolean blnCartCouponApplied = false;
            if(couponObject.ccrz__CartTotalAmount__c!=null &&
                checkCartAmountWithDiscountedAmount(cart.ccrz__TotalAmount__c , Double.valueof(couponObject.ccrz__CartTotalAmount__c )))
            {
                throw new CSSCartException(SSCartException.EXCEPTION_INVALID_AMOUNT_FOR_COUPON);
            }
            
            dblDiscountedAmount = getDiscountedAmount(couponObject , cart.ccrz__SubtotalAmount__c);
			system.debug('----dblDiscountedAmount------------'+dblDiscountedAmount);
            //to check if Discounted amount is more than Cart Amount
            if(checkCartAmountWithDiscountedAmount(cart.ccrz__SubtotalAmount__c , dblDiscountedAmount))
            {
                throw new CSSCartException(SSCartException.EXCEPTION_INVALID_AMOUNT_FOR_COUPON);
            }
            if(COUPON_TYPE_PERCENTAGE == couponObject.ccrz__CouponType__c || COUPON_TYPE_ABSOLUTE == couponObject.ccrz__CouponType__c)
            {
                //Check if Coupon is added as Product or not
                //If Coupon doesnt exist then create a Product and insert a Cart Item.
                ccrz__E_Product__c couponProduct = getCouponProductsByCouponCode(couponCode);
                system.debug('-------couponProduct------------'+ couponProduct);
                if(couponProduct==null)
                {
                    couponProduct = createCouponProduct(couponObject);
                }
                
                createCouponCartItem(cart , couponProduct , couponObject , dblDiscountedAmount);
                
                blnCartCouponApplied = true;
            }
            if(blnCartCouponApplied)
            {
                    system.debug('---------dblDiscountedAmount------'+dblDiscountedAmount);
                    system.debug('---------cart.ccrz__TotalDiscount__c before------'+cart.ccrz__TotalDiscount__c );
                    cart.ccrz__TotalDiscount__c = cart.ccrz__TotalDiscount__c ==null ? 0 + dblDiscountedAmount : 
                                                    cart.ccrz__TotalDiscount__c + dblDiscountedAmount;
                system.debug('---------cart.ccrz__TotalDiscount__c after------'+cart.ccrz__TotalDiscount__c );
                cart.Coupon_Applied__c = true;
                update cart;
                blnCouponApplied = true;
            }
            system.debug('------cart-----------'+cart);
        }else
        {
            throw new CSSCartException(CSSCartException.EXCEPTION_PRODUCT_COUPON_LIMIT);
        }
        return blnCouponApplied;
    }
    
    private Static Boolean addCouponRuleTypeGeneral(ccrz__E_Cart__c cart , List<ccrz__E_CartItem__c> cartItems , ccrz__E_Coupon__c couponObject,String strParentSKU ){
        Boolean blnCouponApplied = false;
        Double dblDiscountedAmount = 0;
        
        for (ccrz__E_CartItem__c cartItem: cartItems) {
            String productId = cartItem.ccrz__Product__c;
            system.debug('----productId------------'+productId);
            system.debug('----couponObject.ccrz__TargetProduct__c------------'+couponObject.ccrz__TargetProduct__c);
            system.debug('----cartItem.ccrz__Coupon__c------------'+cartItem.ccrz__Coupon__c);
            if(productId == couponObject.ccrz__TargetProduct__c )
            {
                system.debug('----cartItem.ccrz__Coupon__c------------'+cartItem.ccrz__Coupon__c);
                
                if(null==cartItem.ccrz__Coupon__c)
                {
                        dblDiscountedAmount = getDiscountedAmount(couponObject , cartItem.ccrz__Price__c );
                    system.debug('----dblDiscountedAmount------------'+dblDiscountedAmount);
                        if(COUPON_TYPE_PERCENTAGE == couponObject.ccrz__CouponType__c)
                    {
                        cartItem.ccrz__PercentDiscount__c = couponObject.ccrz__DiscountAmount__c;
                        }
                        //to Fix Coupon Type Price issue
                        cartItem.ccrz__SubAmount__c = (cartItem.ccrz__Price__c * cartItem.ccrz__Quantity__c )- dblDiscountedAmount;
                        //cartItem.ccrz__SubAmount__c = cartItem.ccrz__SubAmount__c - (dblDiscountedAmount*cartItem.ccrz__Quantity__c);
                        if(COUPON_TYPE_PRICE ==  couponObject.ccrz__CouponType__c)
                        {
                        cartItem.ccrz__SubAmount__c = dblDiscountedAmount;
                        }
                        //cartItem.ccrz__AbsoluteDiscount__c = dblDiscountedAmount * cartItem.ccrz__Quantity__c;
                        cartItem.ccrz__AbsoluteDiscount__c = dblDiscountedAmount;
                        //ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c;

                        if(strParentSKU != null && cartItem.ccrz__ParentCartItem__c != null)
                        {
                             
                             if(cartItem.ccrz__ParentCartItem__r.ccrz__Product__r.ccrz__SKU__c == strParentSKU)
                             {
                              cartItem.ccrz__Coupon__c = couponObject.Id;
                             }
                             
                        }
                        else if(strParentSKU == null)
                        cartItem.ccrz__Coupon__c = couponObject.Id;
                        
                        
                        blnCouponApplied = true;
                        //updated the Cart Data with Discounted Price
                    system.debug('---------dblDiscountedAmount------'+dblDiscountedAmount);
                        system.debug('---------cart.ccrz__TotalDiscount__c before------'+cart.ccrz__TotalDiscount__c );
                        
                        if(cartItem.ccrz__ProductType__c == 'Dynamic Kit'){
                        
                         dblDiscountedAmount = getDiscountedAmount(couponObject , cart.ccrz__TotalAmount__c);
                         cartItem.ccrz__SubAmount__c = - dblDiscountedAmount;
                         cartItem.ccrz__AbsoluteDiscount__c = dblDiscountedAmount ;
                        }
                        //cart.ccrz__TotalDiscount__c = cart.ccrz__TotalDiscount__c ==null ? 0 + dblDiscountedAmount : 
                                                      //  cart.ccrz__TotalDiscount__c + dblDiscountedAmount;
                                                        
                        cart.ccrz__TotalDiscount__c = cart.ccrz__TotalDiscount__c ==null ? 0 + cartItem.ccrz__AbsoluteDiscount__c : 
                        cart.ccrz__TotalDiscount__c + cartItem.ccrz__AbsoluteDiscount__c;
                                                        
                    system.debug('---------cart.ccrz__TotalDiscount__c after------'+cart.ccrz__TotalDiscount__c );
                    cart.Coupon_Applied__c = true;
                    update cart;
                    
                }else{
                    throw new CSSCartException(CSSCartException.EXCEPTION_CART_COUPON_LIMIT);
                }
            }
        }
        
        
        return blnCouponApplied;
    }
    
    /*
    * Check if Coupon code applied to Cart
    * return Boolean
    */
    private Static Boolean checkCouponCodeApplied(String couponCode, String strCartId) {
        try {
            List<ccrz__E_CartCoupon__c> lstCartCoupons = [Select Id, Name, CurrencyIsoCode, ccrz__Cart__r.Id, ccrz__Coupon__r.ccrz__CouponCode__c, 
                                                            ccrz__CartCouponId__c, ccrz__Enabled__c from ccrz__E_CartCoupon__c
                                                            WHERE ccrz__Coupon__r.ccrz__CouponCode__c =: couponCode and  ccrz__Cart__r.Id=:strCartId LIMIT 1];
            return lstCartCoupons.isEmpty();
        }
        catch (System.QueryException ex) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_COUPON);            
        }
    }
    
    /*
    * Fetch Coupon Details by passing Coupon Code
    *
    */
    private Static ccrz__E_Product__c getCouponProductsByCouponCode(String couponCode) {
        try {
            List<ccrz__E_Product__c>  lstCouponProduct = [Select ccrz__Storefront__c, ccrz__SKU__c, ccrz__ProductType__c, ccrz__ProductStatus__c, Name, Id From ccrz__E_Product__c 
                    where ccrz__SKU__c =:couponCode and ccrz__ProductType__c='Coupon' and ccrz__ProductStatus__c = 'Released' limit 1];            
            if(lstCouponProduct!=null && lstCouponProduct.size()>0)
            {
                return lstCouponProduct[0];
            }                        
        }
        catch (System.QueryException ex) {
            throw new CSSCartException(CSSCartException.EXCEPTION_INVALID_COUPON);            
        }
        return null;
    }
    
    private Static ccrz__E_Product__c createCouponProduct(ccrz__E_Coupon__c couponObject){
        ccrz__E_Product__c couponProduct = new ccrz__E_Product__c();
      couponProduct.CurrencyIsoCode = couponObject.CurrencyIsoCode;
      couponProduct.Name = couponObject.ccrz__CouponCode__c;
      couponProduct.ccrz__SKU__c = couponObject.ccrz__CouponCode__c;
      couponProduct.ccrz__Storefront__c = DEFAULT_STORE;
      couponProduct.ccrz__ProductStatus__c = 'Released';
      couponProduct.ccrz__ProductType__c = 'Coupon';
      couponProduct.ccrz__StartDate__c = system.today();
      couponProduct.ccrz__EndDate__c = system.today().addYears(100);
      insert couponProduct;
      return couponProduct;
    }
    
    private Static Double getDiscountedAmount(ccrz__E_Coupon__c couponObject , Decimal totalAmount){
        Double dblDiscountedAmount = 0;
        if (COUPON_TYPE_ABSOLUTE == couponObject.ccrz__CouponType__c || COUPON_TYPE_PRICE ==  couponObject.ccrz__CouponType__c)
        {
            dblDiscountedAmount = couponObject.ccrz__DiscountAmount__c;
        }
        else if(COUPON_TYPE_PERCENTAGE == couponObject.ccrz__CouponType__c)
        {
            dblDiscountedAmount = totalAmount * (couponObject.ccrz__DiscountAmount__c/100);
        }
        return dblDiscountedAmount;
    }
    
    private Static void createCouponCartItem(ccrz__E_Cart__c cart, ccrz__E_Product__c couponProduct , ccrz__E_Coupon__c couponObject , Double dblDiscountedAmount){
        //inserting cart Item
        ccrz__E_CartItem__c cartItemObject = new ccrz__E_CartItem__c();
        cartItemObject.CurrencyIsoCode = cart.CurrencyIsoCode;
        cartItemObject.ccrz__Cart__c = cart.Id;
        cartItemObject.ccrz__Price__c = (- dblDiscountedAmount);
        cartItemObject.ccrz__Quantity__c = 1;
        cartItemObject.ccrz__Coupon__c = couponObject.Id;
        cartItemObject.ccrz__Product__c = couponProduct.Id;
        cartItemObject.ccrz__SubAmount__c =  (- dblDiscountedAmount);
        cartItemObject.ccrz__Comments__c = couponObject.ccrz__CouponCode__c +'-'+cart.Id;
        cartItemObject.ccrz__PricingType__c = 'auto';
        cartItemObject.ccrz__CartItemId__c = couponObject.ccrz__CouponCode__c +'-'+cart.Id;
        cartItemObject.ccrz__cartItemType__c = 'Coupon';
        cartItemObject.ccrz__ProductType__c = 'Coupon';
        cartItemObject.ccrz__ItemStatus__c = 'Available';
        cartItemObject.ccrz__StoreID__c = DEFAULT_STORE;
        cartItemObject.ccrz__RequestDate__c  = system.today();
        insert cartItemObject;
    }
    
    private Static Boolean checkCartAmountWithDiscountedAmount(Decimal dblCartAmount , Double dblDiscountedAmount){
        Boolean blnDiscAmtMore = false;
        if(dblDiscountedAmount>dblCartAmount){
            blnDiscAmtMore = true;
        }
        return blnDiscAmtMore;
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
    

}