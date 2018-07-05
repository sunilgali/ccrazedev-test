global class SSEmailController {
    
    global static String cartId{set;get;}
    global static String orderId{set;get;}
    global static String orderType{set;get;}
    
    global static String trialDays{set;get;}
    global Contact orderContact{set;get;}
    global String existingProductInfo{set;get;}
    
    private static final String ACCOUNT_ANONYMOUS = 'CCAnonymous';
    private List<ccrz__E_Cart__c> lstCartDetails;
    private Account orderAccount{set;get;}
    private String[] subscriptionStatus = new String[]{'Suspended' , 'Inactive' , 'Cancelled', 'Expired','Upsell',
        'Cancellation Completed'};
            
            private static final String CROSS_SELL = 'crossSell';
    private static final String TRIAL = 'trial';
    
    global SSEmailController(){
        system.debug('-----SSEmailController cartId-----'+cartId);
    }
    
    global SSCartModel getProductDetails(){
        //SSCartHelper ssCartHelperObj = new SSCartHelper();
        SSCartModel ssCartModelObj = SSCartHelper.getCart(cartId);
        system.debug('----- ssCartModelObj -------'+ssCartModelObj);
        return ssCartModelObj; 
    }
    
    global String getProductNames(){
        String strProductName = '';
        Set<String> setProductName = new Set<String>();
        system.debug('----- orderId -------'+orderId);
        if(orderId!=null && orderId!='')
        {
            existingProductInfo = '';
            List<ccrz__E_OrderItem__c> lstOrderItem = fetchOrderItems(orderId);
            system.debug('----- lstOrderItem -------'+lstOrderItem);
            if(lstOrderItem!=null)
            {
                strProductName = fetchProductName(lstOrderItem , setProductName);
                strProductName = strProductName.removeEndIgnoreCase( ' and ');
                system.debug('----- setProductName -------'+setProductName);
                system.debug('----- orderAccount -------'+orderAccount);
                if(orderType!=null && orderType.equalsignorecase(CROSS_SELL) && orderAccount!=null)
                {
                    List<ccrz__E_Order__c> lstExistingOrders = [Select id from ccrz__E_Order__c where ccrz__Account__c =:orderAccount.Id and 
                                                                Subscription_Status__c not in : subscriptionStatus and id !=:orderId];
                    system.debug('--------lstExistingOrders--------------'+lstExistingOrders);
                    if(lstExistingOrders!=null && lstExistingOrders.size()>0)
                    {
                        for(ccrz__E_Order__c ccExistinOrder : lstExistingOrders)
                        {
                            lstOrderItem = fetchOrderItems(ccExistinOrder.Id);
                            system.debug('----- lstOrderItem -------'+lstOrderItem);
                            existingProductInfo += fetchProductName(lstOrderItem , setProductName);
                            
                            system.debug('----- setProductName inside-------'+setProductName);
                        }
                        existingProductInfo = existingProductInfo.removeEndIgnoreCase( ' and ');
                        system.debug('----- existingProductInfo -------'+existingProductInfo);
                    }
                }
            }
        }
        if(cartId!=null && cartId!='')
        {
            //SSCartHelper ssCartHelperObj = new SSCartHelper();
            SSCartModel ssCartModelObj = SSCartHelper.getCart(cartId);
            system.debug('----- ssCartModelObj -------'+ssCartModelObj);
            if(ssCartModelObj!=null && ssCartModelObj.cartItems!=null){
                
                orderContact = [SELECT Id, FirstName, LastName,Name, Email FROM Contact 
                                WHERE Id =: ssCartModelObj.contactId];
                List<SSCartItemModel> cartItems = ssCartModelObj.cartItems;
                for(SSCartItemModel ssCartIMObj : cartItems)
                {
                    if(orderType!=null && orderType.equalsignorecase(TRIAL))
                    {
                        trialDays = '30';
                        if(ssCartIMObj.trialLength!=null)
                        {
                            trialDays = String.valueof(ssCartIMObj.trialLength);
                        }
                        strProductName += trialDays + '-day ';
                    }
                    
                    strProductName += ssCartIMObj.productName  + ' and ';
                }
                strProductName = strProductName.removeEndIgnoreCase( ' and ');
            }
        }
        system.debug('----strProductName------'+strProductName);
        return strProductName;
    }
    
    private List<ccrz__E_OrderItem__c> fetchOrderItems(String strOrderId){
        List<ccrz__E_OrderItem__c> lstOrderItems =  [Select id, name, ccrz__Product_Name__c, ccrz__Product__r.Name,ccrz__Product__r.Trial_Period_in_Days__c,
                                                     ccrz__Product__r.Id,ccrz__Product__r.ccrz__SKU__c,ccrz__Product__r.Product_Family__c,
                                                     ccrz__Order__r.Id, ccrz__Order__r.Name, ccrz__Order__r.ccrz__Contact__r.Id,
                                                     ccrz__Order__r.ccrz__Contact__r.Name,ccrz__Order__r.ccrz__Account__r.Id
                                                     from ccrz__E_OrderItem__c where ccrz__Order__c=:strOrderId];
        if(lstOrderItems!=null && lstOrderItems.size()>0)
        {
            for(ccrz__E_OrderItem__c orderItemObject : lstOrderItems)
            {
                orderContact = orderItemObject.ccrz__Order__r.ccrz__Contact__r;
                orderAccount = orderItemObject.ccrz__Order__r.ccrz__Account__r;
            }
        }
        return lstOrderItems;
    }
    
    private String fetchProductName(List<ccrz__E_OrderItem__c> lstOrderItems , Set<String> setProductName)
    {
        String strProductName = '';
        if(lstOrderItems!=null && lstOrderItems.size()>0)
        {
            for(ccrz__E_OrderItem__c orderItemObject : lstOrderItems)
            {
                if(orderType!=null && orderType.equalsignorecase(TRIAL))
                {
                    trialDays = '30';
                    if(orderItemObject.ccrz__Product__r.Trial_Period_in_Days__c!=null)
                    {
                        trialDays = String.valueof(orderItemObject.ccrz__Product__r.Trial_Period_in_Days__c);
                    }
                    strProductName += trialDays + '-day ';
                }
                if(!setProductName.contains(orderItemObject.ccrz__Product_Name__c ))
                {
                    strProductName += orderItemObject.ccrz__Product_Name__c + ' and ';
                    setProductName.add(orderItemObject.ccrz__Product_Name__c);
                }
            }
            system.debug('-----strProductName---------'+strProductName);
        }
        return strProductName;
    }
}