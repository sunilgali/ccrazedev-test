global class SSCartSummaryController {
    
    @AuraEnabled 
    global static SSCartModel getCart(String cartId){
        return SSCartHelper.getCart(cartId);
    }
    
    @AuraEnabled
    global static SSCartModel applyTax(String cartId , String payload){
        SSAddressModel aModel = (SSAddressModel)JSON.deserialize(payload , SSAddressModel.class);
        Double TaxAmount = SSCartHelper.applyTax(cartId ,'','',aModel);
       return SSCartHelper.getCart(cartId);
    }
    
    @AuraEnabled
    global static SSSubscriptionModel createSubscription(String cartId , String paymentModel){
        SSPaymentDetailsModel pModel =new SSPaymentDetailsModel();
        if (String.isBlank(paymentModel)) {
            pModel.paymentType = 'Credit Card';
            pModel.street = 'Crest view';
            pModel.city = 'Bridgewater';
            pModel.state = 'New Jersey';
            pModel.country = 'United States';
            pModel.postalCode = '08807';
            pModel.cardType = 'Visa';
            pModel.cardNumber = '4111111111111111';
            pModel.expirationMonth = 9;
            pModel.expirationYear = 2020;
            pModel.securityCode = '121';
            pModel.cardHolderName = 'Test User';
            pModel.email = 'test@docmation.com';
        }
        else {
             pModel = (SSPaymentDetailsModel)JSON.deserialize(paymentModel , SSPaymentDetailsModel.class);
            
        }
       // pModel.state = 'New Jersey';
        System.debug('The payment model.paymentType = '+pModel.paymentType);
        System.debug('The cart ID = '+cartId);
        
        SSSubscriptionModel sModel = SSSubscriptionservice.createCCSubscription(cartId , system.today(), 
                                 pModel.paymentId == null ? '' : pModel.paymentId  , 
                                    pModel.paymentType == null ? 'Credit Card' : pModel.paymentType  , pModel); 
        return sModel;
    }
    
    
   // SSSubscriptionModel convertSubscription(String parentSubscriptionId,String cartId, String paymentReferenceID,
                //String paymentType, SSPaymentDetailsModel paymentDetails,String transactionType, DateTime subscriptionStartDate,
                                            //Boolean isBillingAccountCreated)
         
    
    @AuraEnabled
    global static SSSubscriptionModel convertSubscription(String parentSubscriptionId , String cartId , String paymentModel){
       SSPaymentDetailsModel pModel = (SSPaymentDetailsModel)JSON.deserialize(paymentModel , SSPaymentDetailsModel.class);
        System.debug('The payment model.paymentType = '+pModel.paymentType);
        System.debug('The cart ID = '+cartId);
        
        SSSubscriptionModel sModel = SSSubscriptionservice.convertSubscription(parentSubscriptionId , 
                        cartId ,  pModel.paymentId == null ? '' : pModel.paymentId  , 
                        pModel.paymentType == null ? 'Credit Card' : pModel.paymentType  , pModel,
                        'Convert' , system.today(), false); 
        return sModel;
    }
    
    @AuraEnabled
    global static SSCartModel applyCouponToCart(String cartId , String couponCode){
        System.debug('Cart Id = '+cartId+' coupon code = '+couponCode);
        SSCouponHelper.addCouponsOnCartItems(cartId , couponCode);
        return SSCartHelper.getCart(cartId);
    }
    
   @AuraEnabled
    global static SSCartModel removeItemFromCart(String payload){
        System.debug('payLoad '+payload);
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(payload);
        System.debug('results '+results);
        SSCartItemModel cartItem = new SSCartItemModel();
        for(String key : results.keySet()){
            if(key.equals('cartId')){
                cartItem.cartId = (String)results.get(key);
                System.debug('adding cart id '+(String)results.get(key));
            }
            else if(key.equalsIgnoreCase('productSKU')){
                cartItem.Sku = (String)results.get(key);
                System.debug('adding SKU '+(String)results.get(key));
            }
        }
        List<SSCartItemModel> cartItemModels = new List<SSCartItemModel>();
        cartItemModels.add(cartItem);
        
        SSCartModel cartModel = SSCartService.removeItemsFromCart(cartItem.cartId , cartItemModels);
        return cartModel;

    }
}