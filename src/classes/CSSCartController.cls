global class CSSCartController {
    
    @AuraEnabled
	global static SSCartModel addToCart(String storefront, String userName, String userLocale, String userCurrency, 
                                         String cartId, String cartName, String cartItemsJson, String transactionType, String bundleComponentJson)
   	{
        userName = UserInfo.getName();
        userLocale = 'en_US';
        userCurrency = 'USD';
        cartName = storefront + '-' + UserInfo.getName() + '-' + DateTime.now();
        
        System.debug('CSSCartController: addToCart: storefront ' + storefront);
        System.debug('CSSCartController: addToCart: cartitems ..... ' + cartItemsJson);    
        List<SSCartItemModel> cartItemList  = (List<SSCartItemModel>)JSON.deserialize(cartItemsJson, List<SSCartItemModel>.class);
        System.debug('CSSCartController: addToCart: deserialized to cart item');    
        List<SSCartItemModel> cartItems = new List<SSCartItemModel>();
        
        List<bundleChildComponents> bundleComponents = null;
        
        if (!String.isBlank(bundleComponentJson)) {
    	    System.debug('CSSCartController: addToCart: deserialize bundle components');    
            bundleComponents = (List<bundleChildComponents>)JSON.deserialize(bundleComponentJson, List<bundleChildComponents>.class);
	        System.debug('CSSCartController: addToCart: deserialize successful');    
        }
        
        if (cartItemList[0].Sku.equalsIgnoreCase('ADOILL')) {            
List<SSCartItemModel> lstSSCartItemModel = new List<SSCartItemModel>();
List<bundleChildComponents> lstBundle = new List<bundleChildComponents>();

SSCartItemTierModel objTierProd = new SSCartItemTierModel(); 
objTierProd.tierAttribute = '26 - 100';
objTierProd.attributeValue= '27';
            
bundleChildComponents objBundleTierProd = new bundleChildComponents();
objBundleTierProd.childProductType = 'Tiered';
objBundleTierProd.childProductSKU = 'ADOLIGHT';
objBundleTierProd.quantity = 9;
objBundleTierProd.tier = new List<SSCartItemTierModel>();
objBundleTierProd.tier.add(objTierProd); 
lstBundle.add(objBundleTierProd);
 
SSCartItemModel products = new SSCartItemModel();
products.Sku = 'ADOILL';
products.quantity = 1.0;
products.productType = 'Dynamic Kit';
products.subscriptionTermType = 'Yearly';
products.bundleComponent = new List<bundleChildComponents>();
products.bundleComponent.addall(lstBundle);
lstSSCartItemModel.add(products);
 cartItems = lstSSCartItemModel;
            
        }
        else {
            for (SSCartItemModel cartItem : cartItemList) {
                cartItem.quantity = Decimal.valueOf(cartItem.cartItemQuantity);
                if (bundleComponents != null) {
                    cartItem.bundleComponent = bundleComponents;
                }
                cartItems.add(cartItem);
            }
            
        }
       
		
        System.debug('CSSCartController: addToCart: adding products to cart ' + cartItems);    
		SSCartModel cart = SSCartService.addProducts(storefront, userName, userLocale, cartName, cartItems);                      
		System.debug('CSSController: addToCart: Cart returned '+ json.serialize(cart));                                    
        return cart;
    }


}