global class SSCouponHelper {
    
    //private static SSContext ecommContext;
    private static final String COUPON_RULE_TYPE_GENERAL = 'General';
    private static final String COUPON_RULE_TYPE_CART_TOTAL = 'CartTotal';
    private static final String COUPON_TYPE_ABSOLUTE = 'Absolute';
    private static final String COUPON_TYPE_PERCENTAGE = 'Percentage';
    private static final String COUPON_TYPE_PRICE = 'Price';
    private static final String DEFAULT_STORE = 'DefaultStore';
    
    global SSCouponHelper() {
        SSContext ecommContext = new SSContext();
    }
    
    global SSCouponHelper(String storefront, String portalUserName, String userLocale, String userCurrency) {
        SSContext ecommContext = new SSContext(storefront, portalUserName, userLocale, userCurrency);
    }
    
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
            ccrz__E_Cart__c cart = SScartHelper.getCartByEncryptedId(cartId);
            if(cart!=null)
            {
                String strCartId = cart.Id;
                List<ccrz__E_CartItem__c> cartItems = SSCartHelper.getCartItemsByEncryptedCartId(cartId);
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
                        throw new SSCartException(SSCartException.EXCEPTION_COUPON_NOT_APPLIED);
                    }
                }
                else{
                    throw new SSCartException(SSCartException.EXCEPTION_CART_COUPON_LIMIT);
                }
            }
        }catch (Exception ex) {
            Database.rollback(sp);
            System.debug('SSCouponHelper: add coupon exception ' + ex.getMessage());
            throw new SSCartException(SSCartException.EXCEPTION_APPLY_COUPON);
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
            ccrz__E_Cart__c cart = SSCartHelper.getCartByEncryptedId(cartId);
            List<ccrz__E_CartItem__c> cartItems = SSCartHelper.getCartItemsByEncryptedCartId(cartId);
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
                        throw new SSCartException('Coupon Code not applied on the Cart. Coupon Code - ' + couponCode);
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
                throw new SSCartException('Coupon Code not applied on the Cart. Coupon Code - ' + couponCode);
            }
        }catch (Exception ex) {
            Database.rollback(sp);
            system.debug('---ex--------'+ex );
            throw new SSCartException('Coupon Code not applied on the Cart. Coupon Code - ' + couponCode);
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
            throw new SSCartException(SSCartException.EXCEPTION_INVALID_COUPON);            
        }
        return null;
    }
    
      global Static Boolean addCouponToCart(String cartId, String couponCode) {
         SSContext ecommContext = new SSContext();
        ccrz__E_Cart__c cart = SSCartHelper.getCartByEncryptedId(cartId);
        
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
       
//check if the Coupon is applied on the Cart
//
  SSContext ecommContext = new SSContext();
 ccrz__E_Cart__c cart = SSCartHelper.getCartByEncryptedId(cartId);
        
        system.debug('>>>>>'+cart.ccrz__Storefront__c);
        system.debug('>>>>>'+cart.ccrz__User__r.Name);
        system.debug('>>>>>'+cart.Locale__r.Name);
        system.debug('>>>>>'+couponCode);
        
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

   /*     SSCouponHelper couponHelper = new SSCouponHelper();
        ccrz__E_Cart__c cart = getCartByEncryptedId(cartId);
        ccrz__E_Coupon__c couponObject = couponHelper.getCouponDetailsByCouponCode(couponCode);
        SSCouponHelper tr = new SSCouponHelper();
        tr.removeCouponsFromCart(cartId, couponCode);
        return true;*/
    }
    

    
    private Static void checkCouponValidity(ccrz__E_Coupon__c couponObject){
        Date todaysDate = System.today();
        if(couponObject.ccrz__StartDate__c!=null && couponObject.ccrz__EndDate__c!=null)
        {
            if(!(todaysDate>=couponObject.ccrz__StartDate__c)){
            
              throw new SSCartException(SSCartException.EXCEPTION_INVALID_COUPON);
                
            }else if(!(couponObject.ccrz__EndDate__c>=todaysDate))
            {
                throw new SSCartException(SSCartException.EXCEPTION_EXPIRED_COUPON);
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
                throw new SSCartException(SSCartException.EXCEPTION_INVALID_AMOUNT_FOR_COUPON);
            }
            
            dblDiscountedAmount = getDiscountedAmount(couponObject , cart.ccrz__SubtotalAmount__c);
system.debug('----dblDiscountedAmount------------'+dblDiscountedAmount);
            //to check if Discounted amount is more than Cart Amount
            if(checkCartAmountWithDiscountedAmount(cart.ccrz__SubtotalAmount__c , dblDiscountedAmount))
            {
                throw new SSCartException(SSCartException.EXCEPTION_INVALID_AMOUNT_FOR_COUPON);
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
            throw new SSCartException(SSCartException.EXCEPTION_PRODUCT_COUPON_LIMIT);
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
                    /*
                    if(cartItem.ccrz__ProductType__c == 'Dynamic Kit')
                    {    
                         ccrz__E_Product__c couponProduct = getCouponProductsByCouponCode(couponObject.ccrz__CouponCode__c);
                            system.debug('-------couponProduct------------'+ couponProduct);
                            if(couponProduct==null)
                            {
                                couponProduct = createCouponProduct(couponObject);
                            }
                            cartItem.ccrz__Coupon__c = null;
                            createCouponCartItem(cart , couponProduct , couponObject , dblDiscountedAmount);
                    }
                    */
                        //cart.ccrz__TotalDiscount__c = cart.ccrz__TotalDiscount__c ==null ? 0 + dblDiscountedAmount : 
                                                      //  cart.ccrz__TotalDiscount__c + dblDiscountedAmount;
                                                        
                        cart.ccrz__TotalDiscount__c = cart.ccrz__TotalDiscount__c ==null ? 0 + cartItem.ccrz__AbsoluteDiscount__c : 
                        cart.ccrz__TotalDiscount__c + cartItem.ccrz__AbsoluteDiscount__c;
                                                        
                    system.debug('---------cart.ccrz__TotalDiscount__c after------'+cart.ccrz__TotalDiscount__c );
                    cart.Coupon_Applied__c = true;
                    update cart;
                    
                }else{
                    throw new SSCartException(SSCartException.EXCEPTION_CART_COUPON_LIMIT);
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
            throw new SSCartException(SSCartException.EXCEPTION_INVALID_COUPON);            
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
            throw new SSCartException(SSCartException.EXCEPTION_INVALID_COUPON);            
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
}