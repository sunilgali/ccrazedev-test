global class SSPaymentController{
    
    @AuraEnabled
    global static Map<String, Object> getPayamentInitialData(){
        SSPaymentDetailsModel pModel = new SSPaymentDetailsModel();
        Map<String , Object> iMap = new Map<String, Object>();
        iMap.put('payment' , pModel);
        /* for silent post
	        iMap.put('cybersourceMetadata' , SSCustomMetadataTypeDAO.getSilentPostConfig());
        */
        iMap.put('countries' , SSCustomMetadataTypeDAO.getCountries());
        return iMap;
    }
    
    @AuraEnabled
    global static Map<String , String> getPayStates(String countryCode){
        return SSCustomMetadataTypeDAO.getStates(countryCode);
    }
    
    @AuraEnabled
    global static SSSubscriptionModel createSubscription(String cartId , String paymentModel){
        SSPaymentDetailsModel pModel = (SSPaymentDetailsModel)JSON.deserialize(paymentModel , SSPaymentDetailsModel.class);
        
        System.debug('The payment model = '+paymentModel);
        System.debug('The cart ID = '+cartId);
        
        SSSubscriptionModel sModel = SSSubscriptionservice.createCCSubscription(cartId , system.today(), '' , '' , pModel); 
        return sModel;
    }
    
    @AuraEnabled
    global static String validatePayment(String paymentModel) {
        SSPaymentDetailsModel pModel = (SSPaymentDetailsModel)JSON.deserialize(paymentModel , SSPaymentDetailsModel.class);
        //System.debug('Card Holder Name = '+pModel);
        Map<String, String> iMap = new Map<String , String>();
		iMap.put('firstName' , pModel.cardHolderName );
        iMap.put('lastName' , pModel.cardHolderName  );
        iMap.put('street' , pModel.street);
        iMap.put('city' , pModel.city); 
        iMap.put('state' , pModel.state);
        iMap.put('postalCode' , pModel.postalCode );
        iMap.put('country' , pModel.country);
        iMap.put('email' , pModel.email);
        iMap.put('currency' , SSCustomMetadataTypeDAO.getCountryCurrency(pModel.country));
        iMap.put('cardNumber' , pModel.cardNumber);
        iMap.put('expMonth' , pModel.expirationMonth+'');
        iMap.put('expYear' , pModel.expirationYear+'');
        iMap.put('cardType' , pModel.cardType);
        iMap.put('recuringSubscription' , 'NO');
        iMap.put('subAmount' , '');
        iMap.put('subNoOfPayments' , '');
        iMap.put('subAutoRenew' , '');
        iMap.put('subFrequency' , '');
        iMap.put('subStartDate' , ''); //format=20180721
        //System.debug('After populating iMap in controller');
        String retVal = '';
        Map<String , String> sMap = SSCybersourceHelper.callCybersourceSOAP(iMap);
        //System.debug('The sMap is '+sMap);
        if(sMap != null){
            if(sMap.get('decision') == 'ACCEPT'){
                retVal = sMap.get('reconciliationID');
            }
        }
        return retVal;
    }
    
}