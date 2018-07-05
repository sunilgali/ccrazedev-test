global class SSPaypalSuccessController {
    
    @AuraEnabled
    global static SSAccountModel getAccountInfo(){
        SSAccountModel aModel = SSAccountService.getCustomerInfo();
        if(aModel.accountId == null){
            System.debug('The account model is null ');
            aModel = new SSAccountModel();
            SSContactModel conModel = new SSContactModel();
            SSAddressModel addModel = new SSAddressModel();
            conModel.address = addModel;
            aModel.billingContact = conModel;
        }
        return aModel;
    }
    
    @AuraEnabled
    global static Map<String, Object> getAccountAndCart(String cartId){
        Map<String , Object> rMap = new Map<String , Object>();
        SSAddressModel addModel = new SSAddressModel();
        SSAccountModel aModel = SSAccountService.getCustomerInfo();
        if(aModel.accountId == null){
            System.debug('The account model is null ');
            aModel = new SSAccountModel();
            SSContactModel conModel = new SSContactModel();
            addModel = new SSAddressModel();
            conModel.address = addModel;
            aModel.billingContact = conModel;
        }
        else{
            addModel = aModel.billingContact.address;
        }
        rMap.put('account' , aModel);
        
        Double TaxAmount = SSCartHelper.applyTax(cartId ,'','', addModel);
        
        rMap.put('cart' , SSCartHelper.getCart(cartId));
        return rMap;
    }
}