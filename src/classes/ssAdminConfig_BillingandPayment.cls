global class ssAdminConfig_BillingandPayment {
    
    @AuraEnabled
    global static Map<String,Object> getBillingandPymentConfig(String storeFront,String configId){
        system.debug('storeFront :'+storeFront);
        system.debug('storeFront :'+configId);
        Map<String,Object> TaxConfig= CCSSBillingandPaymentsConfigImpl.getBillingandPaymentsConfig(storeFront,configId);
        return TaxConfig;
    }
    @AuraEnabled
    global static boolean saveBillingandPymentConfig(String storeFront,String BillingJson,String configId){
        Map<String,String> mapTaxConfig=new Map<String,String>();
        mapTaxConfig.put('Configuration_Type__c','Billing and Payments');
        mapTaxConfig.put('Storefront__c',storeFront);
        //mapTaxConfig.put('Active__c','true');
        mapTaxConfig.put('Storefront_Config_JSON__c',BillingJson);
        boolean flag=CCSSBillingandPaymentsConfigImpl.updateBillingandPayments(storeFront,mapTaxConfig,configId);
        return flag;
    }

}