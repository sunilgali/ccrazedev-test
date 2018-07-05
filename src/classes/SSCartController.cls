global class SSCartController {
    
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
        SSCartModel cartModel = SSCartService.addProducts('Microsoft', 'Microsoft Site Guest User', 'en_US', 'USD', 
                        'Test Cart',transactionType , cartItemModels);
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
    
    @AuraEnabled
    global static SSCartModel createCart(String productSKU){
		SSCartModel model = new SSCartModel();
        model.totalAmount = 91.50;
        model.cartType = 'Testing Cart.....';
        return model;
    }
    
    @AuraEnabled
    global static SSProductModel getProductDetails(String productSKU){
        return SSProductService.getProduct(productSKU, null);
    }
    
    @AuraEnabled
    global static Map<String, Object> getCartAndProduct(String productSKU){
        Map<String , Object> pcMap = new Map<String , Object>();
        SSProductModel product = SSProductService.getProduct(productSKU, null);
        pcMap.put('product' , product);
        List<SSCartItemModel> cartItemModels = new List<SSCartItemModel>();
        if(product.isBundledProduct){
            SSCartItemModel cModel = new SSCartItemModel();
            cModel.Sku = product.productSKU;
            cModel.subscriptionTermType = 'Monthly';
            cModel.productType = product.productType;
            cModel.quantity = 1;
            List<SSProductModel> bundles = product.bundleComponents;
            List<bundleChildComponents> cProducts = new List<bundleChildComponents>();
            for(SSProductModel bundle : bundles){
                if(!bundle.bundleComponentIsOptional){
                    bundleChildComponents childProduct = new bundleChildComponents();
                    childProduct.childProductType = bundle.productType;
                    childProduct.childProductSKU  = bundle.productSKU;
                    childProduct.quantity = 1;
                    cProducts.add(childProduct);
            	}
            }
            cModel.bundleComponent = cProducts;
            cartItemModels.add(cModel);
        }
        else if(product.isTierPriced){
            SSCartItemModel cModel = new SSCartItemModel();
            cModel.Sku = product.productSKU;
            cModel.subscriptionTermType = 'Monthly';
            cModel.productType = product.productType;
            cModel.quantity = 1;
            List<SSCartItemTierModel> tiers = new List<SSCartItemTierModel>();
            
            SSCartItemTierModel tier = new SSCartItemTierModel();
            tier.tierAttribute = product.price[0].tierPriceList[0].tierDescription;
            tier.attributeValue = '1';
            tiers.add(tier);
            cModel.tier = tiers;
            cartItemModels.add(cModel);
        }
        else{
            SSCartItemModel cModel = new SSCartItemModel();
            cModel.Sku = product.productSKU;
            cModel.subscriptionTermType = 'Monthly';
            cModel.productType = product.productType;
            cModel.quantity = 1;
            cartItemModels.add(cModel);
        }
        SSCartModel cartModel = SSCartService.addProducts('Microsoft', 'Microsoft Site Guest User', 'en_US', 'USD', 
                        'Test Cart', 'buy' , cartItemModels);
        pcMap.put('userCart' , cartModel);
        return pcMap;
    }
	
    @AuraEnabled
    global static SSCartModel applyToCartCoupon(String cartId , String couponCode){
        System.debug('Cart Id = '+cartId+' coupon code = '+couponCode);
        SSCouponHelper.addCouponsOnCartItems(cartId , couponCode);
        return SSCartHelper.getCart(cartId);
    }
}