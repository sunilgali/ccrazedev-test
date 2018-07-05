global class UpgradeSubscriptionController {
    
    @AuraEnabled
    global static SSSubscriptionModel getSubscription(String subscriptionId){
        System.debug('UpgradeSubscriptionController subscriptionId = '+subscriptionId);
        
        SSSubscriptionModel sModel = SSSubscriptionHelper.getSubscription(subscriptionId);
        
        /*List<SSProductModel> upProducts = sModel.subscribedProducts[0].upsellProducts;
        for(SSProductModel pModel : upProducts){
            pModel.addOnProducts = SSProductHelper.getRelatedProducts(pModel.productSKU, 'Add-On');
        	pModel.maintainanceProducts = SSProductHelper.getRelatedProducts(pModel.productSKU, 'Maintenance');
        }*/
        //for Testing
        SSProductModel product = SSProductService.getProduct('ADOLIGHT', null);
        product.addOnProducts = SSProductHelper.getRelatedProducts('ADOLIGHT', 'Add-On');
        product.maintainanceProducts = SSProductHelper.getRelatedProducts('ADOLIGHT', 'Maintenance');
        List<SSProductModel> lp = new List<SSProductModel>();
        lp.add(product);
        sModel.subscribedProducts[0].upsellProducts = lp;
                
        return sModel;
    }
    
    @AuraEnabled
    global static SSSubscriptionModel upgradeSubscription(String subscriptionId , String payload){
        System.debug('UpgradeSubscriptionController subscriptionId = '+subscriptionId);
        List<SSCartItemModel> cartItems = (List<SSCartItemModel>)JSON.deserialize(payload, list<SSCartItemModel>.class);
        
        System.debug('cartItems = '+cartItems);
        SSSubscriptionModel sModel = null;
        try{
        	sModel = SSSubscriptionService.regradeSubscription(subscriptionId, cartItems , DateTime.now() , SSSubscription.SUBSCRIPTION_REGRADE_TYPE_UPSELL);
        }
        catch(Exception e){
            System.debug('The exception from Upgrade Subscription is '+e);
        }
        System.debug('sModel = '+sModel);
        return sModel;
    }


}