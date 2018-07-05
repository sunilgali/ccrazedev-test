global class SSManageSubscriptionsController {
    
    @AuraEnabled 
    global static List<SSSubscriptionModel> getSubscriptions(){
        String accountId = SSAccountService.getCustomerId();
        System.debug('getSubscriptions - accountId = '+accountId);
        return SSSubscriptionHelper.getSubscriptions(null , accountId , null);
    }
    
    @AuraEnabled
    global static List<SSSubscriptionModel> cancelSubscriptionItem(String accountId , String subscriptionItemId , String billingSubscriptionId){
        System.debug('accountId = '+accountId);
        System.debug('subscriptionItemId = '+subscriptionItemId);
        System.debug('billingSubscriptionId = '+billingSubscriptionId);
        SSSubscriptionService.cancelCCSubscription(subscriptionItemId , billingSubscriptionId , accountId , Datetime.now() , '');
        
        return SSSubscriptionHelper.getSubscriptions(null , accountId , null);
    }
 
    @AuraEnabled 
    global static String getConvertSubscriptionData(String productId , String productQuantity , 
                                                         String subscriptionTermType ){
        //SSSubscriptionItemModel sModel = (SSSubscriptionItemModel)JSON.deserialize(payload, SSSubscriptionItemModel.class);
        
        SSProductModel pModel = SSProductService.getBuyProductSKU(productId);
                                                             
        List<SSCartItemModel> cModels = new List<SSCartItemModel>(); 
        SSCartItemModel ciModel = new SSCartItemModel();
        ciModel.Sku = pModel.productSKU;
        ciModel.quantity = Decimal.valueOf(productQuantity);
        ciModel.productType = 'Product';
        ciModel.subscriptionTermType = subscriptionTermType;
    	cModels.add(ciModel);
       
    	SSCartModel cart = SSCartService.addProducts(SSCartHelper.getDefaultStorefront(), UserInfo.getName(), 
                                                     UserInfo.getLocale(), 'Test Cart', cModels);
		cart.transactionType = 'Buy';
        //cart.subscriptionItemId = subscriptionItemId;
        return cart.cartId;
    }
}