global class SSProductDetailsController {
    
     @AuraEnabled
    global static SSProductModel getProductDetails(String productSKU){
        return SSProductService.getProduct(productSKU, null);
    }
    
    //global static Map<String, Object> getCartAndProduct(String productSKU , String cartId){
    @AuraEnabled
    global static Map<String, Object> getCartAndProduct(String cartId){
        Map<String , Object> pcMap = new Map<String , Object>();
        String productSKU = '';
        SSCartModel cartModel = null;
        if(cartId != null && cartId.length() > 0){
        	cartModel = SSCartHelper.getCart(cartId);
            List<SSCartItemModel> cartItems = cartModel.cartItems;
            for(SSCartItemModel cItem : cartItems){
                if(cItem.relatedProductParentSku == null && cItem.parentSku == null){
                    productSKU = cItem.Sku;
                }
            }
        }
        SSProductModel product = SSProductService.getProduct(productSKU, null);
        pcMap.put('product' , product);
        //pcMap.put('productSKU' , productSKU);
        /*if(cartId == null || cartId.length() == 0){
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
            try{
                String storeFront = SSCartHelper.getDefaultStorefront();
                System.debug('Stroe front = '+storeFront);
                 System.debug('Stroe front UserInfo.getUser= '+UserInfo.getName());
                 System.debug('Stroe front = UserInfo.getLocale= '+UserInfo.getLocale());
                //UserInfo.getLocale()
                
                //cartModel = SSCartService.addProducts('Microsoft', 'Microsoft Site Guest User', 'en_US' , 'Test Cart', cartItemModels);
                cartModel = SSCartService.addProducts(storeFront, UserInfo.getName(), UserInfo.getLocale() , 'Test Cart', cartItemModels);
            }catch(Exception e){
                System.debug('Exception calling cart from SSProductDetailsController = '+e);
            }
            System.debug('New Cart created -- '+cartModel.cartId); 
        }*/
        
        pcMap.put('userCart' , cartModel);
        
        return pcMap;
    }
	
    @AuraEnabled
    global static SSCartModel applyCouponToCart(String cartId , String couponCode){
        System.debug('Cart Id = '+cartId+' coupon code = '+couponCode);
        SSCouponHelper.addCouponsOnCartItems(cartId , couponCode);
        return SSCartHelper.getCart(cartId);
    }

}