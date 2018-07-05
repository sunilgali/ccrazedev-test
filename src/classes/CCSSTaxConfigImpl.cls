/**
* @author Raja Patnaik, Docmation
* @creationDate April 20, 2017
*
* @description Implementation class to Retrive Tax config details.
*

*/
global class CCSSTaxConfigImpl implements ISSAdminConfig { 
    
    
    global static Map<String,Object> getTaxConfig(String storeFront,String configId){
        
        
        Map<String,Object> mapTaxConfig = new Map<String,Object>();
        
        List<SS_Storefront_Configuration__c> lstTaxConfig = [Select Id, Configuration_Type__c ,Active__c, Storefront__c, 
                                                             Storefront_Config_JSON__c from SS_Storefront_Configuration__c where 
        Active__c =  true and Storefront__c =: storeFront  and Configuration_Type__c = 'Tax' Limit 1];
        
        system.debug('lstTaxConfig '+lstTaxConfig.size());
        
        if(lstTaxConfig != null && lstTaxConfig.size()>0){   
            mapTaxConfig = (Map<String,Object>)lstTaxConfig[0].getPopulatedFieldsAsMap();
        }
        else{
            mapTaxConfig.put('new','new');
        }
        
        system.debug('mapTaxConfig '+ mapTaxConfig);
        
        //Sample : {Active__c=true, Configuration_Type__c=Tax, CurrencyIsoCode=USD, Id=a3I1N000000Xzx4UAC, 
        //Storefront_Config_JSON__c={storefront:Microsoft}, Storefront__c=Microsoft}  
        
        return mapTaxConfig;
    }
    
    
    
    global static boolean updateTax(String storeFront,Map<String,String> mapTaxConfig,String configId){
        
        //Sample : mapTaxConfig.put('Storefront_Config_JSON__c','{storefront:Microsoft}');
        
        Boolean isSuccess = false;
        
        List<SS_Storefront_Configuration__c> lstTaxConfig = [Select Id from SS_Storefront_Configuration__c where 
        Active__c =  true and (Storefront__c =: storeFront OR Id =: configId) and Configuration_Type__c = 'Tax' Limit 1];
        
        if(lstTaxConfig != null){
            
            SS_Storefront_Configuration__c objSSTaxConfig = new SS_Storefront_Configuration__c();
            
            for(String strTaxFieldAPIName : mapTaxConfig.Keyset()){
                
                if(configId != null)
                objSSTaxConfig = new SS_Storefront_Configuration__c(Id = lstTaxConfig[0].Id);
                
                objSSTaxConfig.put(strTaxFieldAPIName,mapTaxConfig.get(strTaxFieldAPIName));
            }
            
            system.debug('objSSTaxConfig '+objSSTaxConfig);
            
            upsert objSSTaxConfig;
            
            isSuccess = true;
        }
        
        return isSuccess;
        
        
    }
    
    global static Map<String,Object> getBillingandPaymentsConfig(String storeFront,String configId){return new Map<String,Object>();}
    
    global static boolean updateBillingandPayments(String storeFront,Map<String,String> mapTaxConfig,String configId){return true;}
    
    
}