@RestResource(urlMapping='/SSRemoveCouponFromCartService')
global class SSRemoveCouponFromCartService {
   
   @HttpPost
   global static SSCartModel removeCouponFromCart(String storefront, String userName, String userLocale, String userCurrency, String cartId, 
                                             String couponCode)  
    {
    System.debug('############################################### Remove Coupon From cart');
        SSCartModel cartModel = new SSCartModel();
        try {            
      System.debug('Cart Manager creation ');
      
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
    
   
}