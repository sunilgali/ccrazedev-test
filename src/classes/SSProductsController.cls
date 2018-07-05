global class SSProductsController {
    
    @AuraEnabled
    global static SSCartModel addToCart(String jsonStr){

        SSCartItemModel jObject = (SSCartItemModel)JSON.deserialize(jsonStr, SSCartItemModel.class);
        String transactionType = 'buy';
		//string userLocale = 'en_US';
		//string userCurrency = 'USD';
		
		List<SSCartItemModel> cartItemModels = new List<SSCartItemModel>();
        cartItemModels.add(jObject);
        System.debug('SSCartController.addToCart - cartItemModels '+cartItemModels);
        //if(jObject.bundleComponent != null && jObject.bundleComponent.size() > 0){
        	SSCartService.removeItemsFromCart(jObject.cartId , cartItemModels);
        //}
        
        String storeFront = SSCartHelper.getDefaultStorefront();
		SSCartModel cartModel = SSCartService.addProducts(storeFront, UserInfo.getName(), UserInfo.getLocale() , 'Test Cart', cartItemModels);
        
        //SSCartModel cartModel = SSCartService.addProducts('Microsoft', 'Microsoft Site Guest User', 'en_US', 
                        //'Test Cart', cartItemModels);
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