global class SSCartService {

  
   
   global static SSCartModel addProducts(String storefront, String userName,String userLocale, 
   									String cartName,List<SSCartItemModel> products)
   {
      System.debug('SSCartService: addProducts: enter ' + products);
      SSCartModel cartModel = new SSCartModel();
      try
      {
      String strCartId ;
      
      System.debug('SSCartService: addProducts: checking for if product is empty ' + products);
      if(!products.Isempty())
      {
         strCartId = products[0].cartId; // If the Cart ID is already exists
      }
      
      System.debug('SSCartService: addProducts: strCartId ' + strCartId);
      if(String.IsBlank(strCartId))
      {
      SSCartModel obj =  SSCartHelper.createCart(storefront,userName,userLocale,'',cartName,'') ;
      System.debug('SSCartService: addProducts: created cart ' + obj);
          System.debug('########### '+obj);
    
      //String cartId = SSCartHelper.createCart(storefront,userName,userLocale) ;
      
      String cartId = obj.CartId ;
      System.debug('SSCartService: addProducts: cartId ' + cartId);
      
      system.debug('>>>> -- cartId '+cartId);
      
      strCartId = cartId;
      }
            System.debug('SSCartService: addProducts: checking if products is empty ' + products);

      if(!products.Isempty())
      {
      System.debug('SSCartService: addProducts: product type ' + products[0].productType);
         if(products[0].productType == 'Dynamic Kit')
         {
           SSCartHelper.addDynamicKitToCart(storefront,userName,userLocale, strCartId,  products); 
           //SSCartHelper.addItemsToCart(strCartId,  products); 
         }
         else
         {
           SSCartHelper.addItemsToCart(strCartId,  products); 
         }
      }
      
      
      system.debug('>>>>>>addProducts'+cartModel.cartId);
      
      cartModel = SSCartHelper.getCart(strCartId);
            
      system.debug('>>>>>FINAL JSON CART'+json.serialize(cartModel));
      
      system.debug('>>>>>FINAL CART'+cartModel);
      
      cartModel.setStatus(true);
      
      }
      catch (SSCartException ex) {
            cartModel.setErrorMessage(ex.getMessage());
            cartModel.setStatus(false);
      }   
        
      return cartModel;
   }
   
   global static SSBaseModel checkoutCartAndConvertLead(String cartId, String accountId, String contactId, String leadId, String opportunityId, 
                                                             String zuoraSubscriptionId, String zuoraSubscriptionNumber, 
                                                            String paymentId, String transactionType ) {  
        SSBaseModel result = new SSBaseModel();                                                        
        try{
         
            SSCartHelper.updateAccountAndLead(cartId, accountId, contactId, 
                                            opportunityId, transactionType, '', '');
            
            SSCartHelper.checkoutCartAndConvertLead(cartId, paymentId, '', null, '',
                                             leadId, opportunityId, accountId,  contactId,  
                                               zuoraSubscriptionId,  zuoraSubscriptionNumber,  transactionType); 
            result.setStatus(true);
        }
        catch (SSCartException ex) {
            result.setErrorMessage(ex.getMessage());
            result.setStatus(false);
        }   
        return result;
    }
    
   global static SSCartModel removeItemsFromCart(String cartId, 
                                             List<SSCartItemModel> products)  
    {
    System.debug('############################################### Remove Items From cart');
        SSCartModel cartModel = new SSCartModel();
        try {            
      
      SSCartHelper.removeItemsFromCart(cartId, products);    
      cartModel = SSCartHelper.getCart(cartId);
      
            cartModel.cartId = cartId;
            cartModel.setStatus(true);
        }
        catch (SSCartException ex) {
            cartModel.setErrorMessage(ex.getMessage());
            cartModel.setStatus(false);
        }
        return cartModel;


    } 

    
    global static SSCartModel removeCouponFromCart(String cartId, 
                                             String couponCode)  
    {
    System.debug('############################################### Remove Coupon From cart');
        SSCartModel cartModel = new SSCartModel();
        try {            
      
      SSCouponHelper.removeCouponFromCart(cartId, couponCode);    
      cartModel = SSCartHelper.getCart(cartId);
      
            cartModel.cartId = cartId;
            cartModel.setStatus(true);
        }
        catch (SSCartException ex) {
            cartModel.setErrorMessage(ex.getMessage());
            cartModel.setStatus(false);
        }
        return cartModel;


    } 
    
    
    global static SSCartModel addCouponsOnCart(String cartId, 
                                             String couponCode)  
    {
    System.debug('############################################### Adding Coupon From cart');
        SSCartModel cartModel = new SSCartModel();
        try {            
      
      SSCouponHelper.addCouponsOnCartItems(cartId, couponCode);    
      cartModel = SSCartHelper.getCart(cartId);
      
            cartModel.cartId = cartId;
            cartModel.setStatus(true);
        }
        catch (SSCartException ex) {
            cartModel.setErrorMessage(ex.getMessage());
            cartModel.setStatus(false);
        }
        return cartModel;


    } 
    
    global static List<String> getallStorefronts(){
       return SSCartHelper.getallStorefront();
    
    }
    

}