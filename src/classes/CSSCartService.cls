global class CSSCartService {
    
    global static CSSCartModel addToCart(String storefront, String userName, String userLocale, String userCurrency, 
                                         String cartId, String cartName, List<CSSCartItemModel> cartItems)
   	{
        //retrieve product info for new items that need to be added
        //check if cart is created. if not create cart
    	CSSCartModel cartModel = new CSSCartModel();
      	try {
            if(String.IsBlank(cartId))
      		{
                String transactionType = '';
      			CSSCartModel cart =  CSSCartHelper.createCart(storefront, userName, userLocale, userCurrency, cartName, transactionType);
    			
                System.debug('CSSCartService: addToCart: cart created '+ cart);
      			cartId = cart.CartId ;
      			system.debug('CSSCartService: addToCart: cartId  '+cartId);
      		}
      		
      		if(!cartItems.Isempty())
      		{
      			system.debug('CSSCartService: addToCart: checking for product type  '+ cartItems[0].product.productType);
         		if(cartItems[0].product.productType == 'Dynamic Kit')
         		{
           			CSSCartHelper.addDynamicKitToCart(cartId,  cartItems); 
         		}
         		else
         		{
           			CSSCartHelper.addItemsToCart(cartId,  cartItems); 
         		}
      		}
            
      		system.debug('CSSCartService: addToCart: retrieving updated cart  '+ cartId);
      		cartModel = CSSCartHelper.getCart(cartId);
           	cartModel.setStatus(true);
      	}
      	catch (CSSCartException ex) {
            cartModel.setErrorMessage(ex.getMessage());
            cartModel.setStatus(false);
      	}   
        
      	return cartModel;
   	}
   
   	global static CSSBaseModel checkoutCartAndConvertLead(String cartId, String accountId, String contactId, String leadId, String opportunityId, 
                                                             String zuoraSubscriptionId, String zuoraSubscriptionNumber, 
                                                            String paymentId, String transactionType ) {  
        CSSBaseModel result = new CSSBaseModel();                                                        
        try{
         
            CSSCartHelper.updateAccountAndLead(cartId, accountId, contactId, 
                                            opportunityId, transactionType, '', '');
            
            CSSCartHelper.checkoutCartAndConvertLead(cartId, paymentId, '', null, '',
                                             leadId, opportunityId, accountId,  contactId,  
                                               zuoraSubscriptionId,  zuoraSubscriptionNumber,  transactionType); 
            result.setStatus(true);
        }
        catch (CSSCartException ex) {
            result.setErrorMessage(ex.getMessage());
            result.setStatus(false);
        }   
        return result;
    }
    
   	global static CSSCartModel removeItemsFromCart(String cartId, 
                                             List<CSSCartItemModel> cartItems)  
    {
    	System.debug('############################################### Remove Items From cart');
        CSSCartModel cartModel = new CSSCartModel();
        try {            
      		CSSCartHelper.removeItemsFromCart(cartId, cartItems);    
      		cartModel = CSSCartHelper.getCart(cartId);
      
            cartModel.cartId = cartId;
            cartModel.setStatus(true);
        }
        catch (CSSCartException ex) {
            cartModel.setErrorMessage(ex.getMessage());
            cartModel.setStatus(false);
        }
        return cartModel;


    } 

    
    global static CSSCartModel removeCouponFromCart(String cartId, 
                                             String couponCode)  
    {
	    System.debug('############################################### Remove Coupon From cart');
        CSSCartModel cartModel = new CSSCartModel();
        try {            
      		CSSCouponHelper.removeCouponFromCart(cartId, couponCode);    
      		cartModel = CSSCartHelper.getCart(cartId);
      
            cartModel.cartId = cartId;
            cartModel.setStatus(true);
        }
        catch (CSSCartException ex) {
            cartModel.setErrorMessage(ex.getMessage());
            cartModel.setStatus(false);
        }
        return cartModel;
    } 
    
    
    global static CSSCartModel addCouponsOnCart(String cartId, 
                                             String couponCode)  
    {
    	System.debug('############################################### Adding Coupon From cart');
        CSSCartModel cartModel = new CSSCartModel();
        try {            
      		CSSCouponHelper.addCouponsOnCartItems(cartId, couponCode);    
      		cartModel = CSSCartHelper.getCart(cartId);
      
            cartModel.cartId = cartId;
            cartModel.setStatus(true);
        }
        catch (SSCartException ex) {
            cartModel.setErrorMessage(ex.getMessage());
            cartModel.setStatus(false);
        }
        return cartModel;
    } 
    
    global static List<String> getAllStorefronts(){
       return CSSCartHelper.getAllStorefronts();
    }
    

}