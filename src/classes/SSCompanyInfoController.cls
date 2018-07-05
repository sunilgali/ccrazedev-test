global class SSCompanyInfoController {
    
    @AuraEnabled
	global static Map<String, Object> populateInitialData(String cartId){
        Map<String, Object> initMap = new Map<String, Object>();
        if(cartId != null && cartId.length() > 0){
        	SSCartModel cModel = SSCartHelper.getCart(cartId);
            
            System.debug('SSCompanyInfoController cartId = '+cModel.cartId);
            System.debug('SSCompanyInfoController transactionType = '+cModel.transactionType);
        	initMap.put('cart' , cModel);
        }
        initMap.put('countries' , SSCustomMetadataTypeDAO.getCountries());
        SSAccountModel aModel = SSAccountService.getCustomerInfo();
        if(aModel.accountId == null){
            System.debug('The account model is null ');
            aModel = new SSAccountModel();
            SSContactModel conModel = new SSContactModel();
            SSAddressModel addModel = new SSAddressModel();
            conModel.address = addModel;
            aModel.billingContact = conModel;
        }
        initMap.put('account' , aModel);
        System.debug('SSCompanyInfoController aModel.billingContact '+aModel.billingContact);
		return initMap;		
	}
	
	@AuraEnabled
	global static Map<String, String> getStates(String countryCode){
        return SSCustomMetadataTypeDAO.getStates(countryCode);
    }
    
    @AuraEnabled
    global static SSAccountResultModel createAccount(String jsonStr){
        System.debug(jsonStr);
        
        SSAccountModel aModel = new SSAccountModel();
    	SSContactModel contactModel = new SSContactModel();
        SSAddressModel billTo  = new  SSAddressModel();
        //String accountName = '';
		String cartId = '';
		String transactionType = '';                                  
        Map<String, Object> accountInfo = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        for(String key : accountInfo.keySet()){
            System.debug('Key = '+key + 'value = '+accountInfo.get(key));
            if(key.endsWithIgnoreCase('companyName')){
                //accountName = (String)accountInfo.get(key);
                aModel.accountName = (String)accountInfo.get(key);
            }
            else if(key.endsWithIgnoreCase('accountId')){
                aModel.accountId = (String)accountInfo.get(key);
            }
            else if(key.endsWithIgnoreCase('firstName')){
                contactModel.firstName = (String)accountInfo.get(key);
            }
            else if(key.endsWithIgnoreCase('lastName')){
                contactModel.lastName = (String)accountInfo.get(key);
            }
            else if(key.endsWithIgnoreCase('email')){
                contactModel.email = (String)accountInfo.get(key);
            }
            else if(key.endsWithIgnoreCase('phone')){
                contactModel.phone = (String)accountInfo.get(key);
            }
            else if(key.endsWithIgnoreCase('contactId')){
                contactModel.contactId = (String)accountInfo.get(key);
            }
            else if(key.endsWithIgnoreCase('transactionType')){
                transactionType = (String)accountInfo.get(key);
            }
            else if(key.endsWithIgnoreCase('cartId')){
                cartId = (String)accountInfo.get(key);
            }
            if(transactionType.equalsIgnoreCase('Buy')){
                if(key.endsWithIgnoreCase('address')){
                    billTo.streetAddress = (String)accountInfo.get(key);
                }
                if(key.endsWithIgnoreCase('country')){
                    billTo.country = (String)accountInfo.get(key);
                }
				if(key.endsWithIgnoreCase('state')){
                    billTo.state = (String)accountInfo.get(key);
                }
				if(key.endsWithIgnoreCase('city')){
                    billTo.city = (String)accountInfo.get(key);
                }
				if(key.endsWithIgnoreCase('postalCode')){
                    billTo.postalCode = (String)accountInfo.get(key);
                }
                contactModel.address = billTo;
            }
        }
        System.debug('UserInfo.getUserType() = '+UserInfo.getUserType());
        System.debug('aModel.accountId = '+aModel.accountId);
        
        SSAccountResultModel acResult = null; 
        //acResult = SSAccountService.createAccount(aModel.accountName, cartId,  transactionType, 'en_US' ,'USD' , contactModel, billTo, 'Prospecting', '');
        if(UserInfo.getUserType() == 'Guest'){ 
            System.debug('Creating account');
            acResult = SSAccountService.createAccount(aModel.accountName, cartId,  transactionType, UserInfo.getLocale() ,'USD' , 
                               contactModel, contactModel.address, transactionType.equalsIgnoreCase('buy') ? 'Closed Won' : 'Prospecting', '');
        }
        else{
            System.debug('Updating account');
        	acResult = SSAccountService.updateAccount(aModel.accountId, cartId,  aModel , transactionType, UserInfo.getLocale() ,'USD' , contactModel, contactModel.address);
        }
        System.debug('The transaction Type = '+transactionType);
        /*if(!transactionType.equalsIgnoreCase('Buy')){
        	 SSSubscriptionModel sModel = SSSubscriptionservice.createCCSubscription(cartId , system.today(), '' , '' , null); 
        }*/
        System.debug('acResult = '+acResult);
        return acResult;
    }

}