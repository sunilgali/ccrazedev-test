@RestResource(urlMapping='/SSCartRestService')
global class SSCartRestService {

  
   @HttpPost
   global static SSCartModel addProducts(String storefront, String userName, String userLocale,String userCurrency, 
   String cartName,String transactionType,List<SSCartItemModel> products)
   {
      
      SSCartModel cartModel = new SSCartModel();
      system.debug('>>>>'+transactionType);
      
      try
      {
      cartModel = SSCartHelper.createCart(storefront,userName,userLocale,userCurrency,cartName, transactionType) ;
      
      system.debug('>>>> -- cartModel '+cartModel.cartId);
      
      SSCartHelper.addItemsToCart(cartModel.cartId,products); 
      
      system.debug('>>>>>>addProducts'+cartModel.cartId);
      
      cartModel = SSCartHelper.getCart(cartModel.cartId);
            
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
    
    
    
   

}