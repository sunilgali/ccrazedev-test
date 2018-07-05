global class SSUpgradeSummaryController {
    
    @AuraEnabled
    global static SSCartModel getTaxAmount(String cartId , String payload){
        if(payload.length() > 0){
        	SSAddressModel aModel = (SSAddressModel)JSON.deserialize(payload , SSAddressModel.class);
        	Double TaxAmount = SSCartHelper.applyTax(cartId ,'','',aModel);
        }
       return SSCartHelper.getCart(cartId);
    }
    
    @AuraEnabled
    global static SSSubscriptionModel upgradeSubscription(String cartId , String subscriptionItemId){
        System.debug('UpgradeSubscriptionController subscriptionItemId = '+subscriptionItemId);
        System.debug('UpgradeSubscriptionController cartId = '+cartId);
        SSSubscriptionModel sModel = null;
        try{
        	sModel = SSSubscriptionService.regradeSubscription(subscriptionItemId, cartId , DateTime.now() , SSSubscription.SUBSCRIPTION_REGRADE_TYPE_UPSELL);
        }
        catch(Exception e){
            System.debug('The exception from Upgrade Subscription is '+e);
        }
        System.debug('sModel = '+sModel);
        return sModel;
    }

}