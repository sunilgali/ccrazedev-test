/**
* @author Raja Patnaik, Docmation
* @creationDate April 20, 2017
*
* @description Implementation class to Retrive Billing and Payment Config Details.
*

*/
global class CCSSBillingandPaymentsConfigImpl implements ISSAdminConfig { 
    
    
    global static Map<String,Object> getTaxConfig(String storeFront,String configId){
        return new Map<String,Object>();   
    }
    
    global static boolean updateTax(String storeFront,Map<String,String> mapTaxConfig,String configId){
        return true;
    }
    
    global static Map<String,Object> getBillingandPaymentsConfig(String storeFront,String configId){
        
        system.debug('storeFront :'+storeFront);
        system.debug('storeFront :'+configId);
         Map<String,Object> mapBillingandPaymentConfig = new Map<String,Object>();
        
         List<SS_Storefront_Configuration__c> lstBillingandPaymentsConfig = [Select Id, Configuration_Type__c ,Active__c, Storefront__c, 
                                                                            Storefront_Config_JSON__c from SS_Storefront_Configuration__c where 
                                                                            Active__c =  true and Storefront__c =: storeFront 
                                                                            and Configuration_Type__c = 'Billing and Payments' Limit 1];
        
        system.debug('lstBillingandPaymentsConfig '+lstBillingandPaymentsConfig.size());
        
        if(lstBillingandPaymentsConfig != null && lstBillingandPaymentsConfig.size()>0){   
            mapBillingandPaymentConfig = (Map<String,Object>)lstBillingandPaymentsConfig[0].getPopulatedFieldsAsMap();
        }
        else{
            mapBillingandPaymentConfig.put('new','new');
        }
        
        system.debug('mapBillingandPaymentConfig '+ mapBillingandPaymentConfig);
       
        
        return mapBillingandPaymentConfig;
        
    }
    
    
    
    global static boolean updateBillingandPayments(String storeFront,Map<String,String> mapBillingandPaymentConfig,String configId){
        
        Boolean isSuccess = false;
        
        List<SS_Storefront_Configuration__c> lstBillingandPaymentsConfig = [Select Id from SS_Storefront_Configuration__c where 
                                                                            Active__c =  true and (Storefront__c =: storeFront OR Id =: configId) and Configuration_Type__c = 'Billing and Payments' Limit 1];
        
        if(lstBillingandPaymentsConfig != null){
            
            SS_Storefront_Configuration__c objSSBillingandPaymentConfig = new SS_Storefront_Configuration__c();
            
            for(String strTaxFieldAPIName : mapBillingandPaymentConfig.Keyset()){
                
                if(configId != null)
                    objSSBillingandPaymentConfig = new SS_Storefront_Configuration__c(Id = lstBillingandPaymentsConfig[0].Id);
                
                objSSBillingandPaymentConfig.put(strTaxFieldAPIName,mapBillingandPaymentConfig.get(strTaxFieldAPIName));
            }
            
            system.debug('objSSBillingandPaymentConfig '+objSSBillingandPaymentConfig);
            
            upsert objSSBillingandPaymentConfig;
            
            isSuccess = true;
        }
        
        return isSuccess;
        
        
    }
    
    
    
    
}