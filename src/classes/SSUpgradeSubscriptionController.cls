global class SSUpgradeSubscriptionController {
    
    @AuraEnabled
    global static Map<String , Object> getSubscription(String subscriptionId){
        System.debug('UpgradeSubscriptionController subscriptionId = '+subscriptionId);
        
        SSSubscriptionModel sModel = SSSubscriptionHelper.getSubscription(subscriptionId);
        
        SSSubscriptionItemModel iModel = sModel.subscribedProducts[0];
        System.debug('iModel -----'+iModel);
        /*SSCartModel ocModel = iModel.cart;
        String userName = ocModel.portalUserName;
        String storefront = ocModel.storefront;
*/
        List<SSProductModel> upProducts = iModel.upsellProducts;
        List<SSProductModel> upsellProducts = new List<SSProductModel>();
        for(SSProductModel pModel : upProducts){
            SSProductModel npModel = SSProductHelper.getProductInfo(pModel.productId);
            //pModel.addOnProducts = SSProductHelper.getRelatedProducts(pModel.productSKU, 'Add-On');
        	//pModel.maintainanceProducts = SSProductHelper.getRelatedProducts(pModel.productSKU, 'Maintenance');
        	npModel.addOnProducts = SSProductHelper.getRelatedProducts(pModel.productSKU, 'Add-On');
        	npModel.maintainanceProducts = SSProductHelper.getRelatedProducts(pModel.productSKU, 'Maintenance');
            upsellProducts.add(npModel);
        }
        
        iModel.upsellProducts = upsellProducts;
        //for Testing
        /*SSProductModel product = SSProductService.getProduct('ADOLIGHT', null);
        product.addOnProducts = SSProductHelper.getRelatedProducts('ADOLIGHT', 'Add-On');
        product.maintainanceProducts = SSProductHelper.getRelatedProducts('ADOLIGHT', 'Maintenance');
        List<SSProductModel> lp = new List<SSProductModel>();
        lp.add(product);
        sModel.subscribedProducts[0].upsellProducts = lp;*/
        //SSCartService.addProducts('Microsoft', 'Microsoft Site Guest User', 'en_US' , 'Test Cart', cartItemModels);
        //String storefront, String userName, String userLocale, String userCurrency, String cartName, String transactionType) 
        //SSCartModel cModel = SSCartHelper.createCart(storefront , userName, 'en_US' , '' , 'Test Cart' , '' );
        SSCartModel cModel = SSCartHelper.createCart('Adobe' , 'Adobe User', 'en_US' , '' , 'Test Cart' , '' );
        Map<String , Object> sMap = new Map<String , Object>();
        sMap.put('subscription' , sModel);
        sMap.put('cart' , cModel);
        return sMap;
    }
    
    @AuraEnabled
    global static SSCartModel addToCart(String jsonStr ){
		//, String addrPayload
        SSCartItemModel jObject = (SSCartItemModel)JSON.deserialize(jsonStr , SSCartItemModel.class);
        		
		List<SSCartItemModel> cartItemModels = new List<SSCartItemModel>();
        cartItemModels.add(jObject);
        System.debug('SSUpgradeSubscriptionController.addToCart - cartItemModels '+cartItemModels);
        SSCartModel cartModel = null;
        try{
       		SSCartService.removeItemsFromCart(jObject.cartId , cartItemModels);
        	cartModel = SSCartService.addProducts('Adobe', 'Adobe User', 'en_US', 
                        'Test Cart', cartItemModels);
            //System.debug('addrPayload = '+addrPayload);
            /*if(addrPayload.length() > 0){
                SSAddressModel aModel = (SSAddressModel)JSON.deserialize(addrPayload , SSAddressModel.class);
                cartModel.taxAmount = SSCartHelper.applyTax(jObject.cartId ,'','',aModel);
            }*/
        }
        catch(Exception e){
            System.debug('SSUpgradeSubscriptionController error - '+e);
        }
        System.debug('the cart totalAmount is '+cartModel.totalAmount);
        System.debug('the cart subscriptionTermType is '+cartModel.subscriptionTermType);
        System.debug('the cart taxAmount is '+cartModel.taxAmount);
        return cartModel;
    }
    
    @AuraEnabled
    global static SSCartModel removeFromCart(String jsonStr){
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        SSCartItemModel cartItem = new SSCartItemModel();
        for(String key : results.keySet()){
            if(key.equals('cartId')){
                cartItem.cartId = (String)results.get(key);
            }
            else if(key.equalsIgnoreCase('productSKU')){
                cartItem.Sku = (String)results.get(key);
            }
        }
        List<SSCartItemModel> cartItemModels = new List<SSCartItemModel>();
        cartItemModels.add(cartItem);
        
        SSCartModel cartModel = SSCartService.removeItemsFromCart(cartItem.cartId , cartItemModels);
        return cartModel;
    }
    
}