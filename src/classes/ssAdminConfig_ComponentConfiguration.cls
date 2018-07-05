public class ssAdminConfig_ComponentConfiguration {
    @AuraEnabled
    public static Map<String,Object> getProductConfig(String storeFront,String configId,string ComponentType){
        
        
        Map<String,Object> mapProductConfig = new Map<String,Object>();
        
        List<SS_Component_Configuration__c> ComponentConfig = [Select Id, Active__c ,Component_Config_JSON__c ,Component_Type__c, Storefront__c  
                                                               from SS_Component_Configuration__c  where 
                                                               Active__c =  true and (Storefront__c =: storeFront OR Id =: configId)
                                                               and Component_Type__c =: ComponentType Limit 1];
        if(ComponentConfig != null && ComponentConfig.size()>0){   
            mapProductConfig = (Map<String,Object>)ComponentConfig[0].getPopulatedFieldsAsMap();
        }
        else{
            mapProductConfig.put('new','new');
            return mapProductConfig;
        }
        
        //Sample : {Active__c=true, Configuration_Type__c=Tax, CurrencyIsoCode=USD, Id=a3I1N000000Xzx4UAC, 
        //Storefront_Config_JSON__c={storefront:Microsoft}, Storefront__c=Microsoft}  
        
        return mapProductConfig;
    }
    
    @AuraEnabled
    public static List<String> getStorefront(){
        List<String> Strorefront=SSCartService.getallStorefronts();
        return Strorefront;
    }
    @AuraEnabled
    public static boolean upsertProductConfig(String storeFront,Map<String,String> mapTaxConfig,String configId,string ComponentType){
        
        //Sample : mapTaxConfig.put('Storefront_Config_JSON__c','{storefront:Microsoft}');
        
        Boolean isSuccess = false;
        
        List<SS_Component_Configuration__c> ComponentConfig = [Select Id from SS_Component_Configuration__c where 
                                                               Active__c =  true and (Storefront__c =: storeFront OR Id =: configId) and Component_Type__c =: ComponentType Limit 1];
        
        if(ComponentConfig != null){
            
            SS_Component_Configuration__c objSSTaxConfig = new SS_Component_Configuration__c();
            
            for(String strTaxFieldAPIName : mapTaxConfig.Keyset()){
                
                if(configId != null)
                    objSSTaxConfig = new SS_Component_Configuration__c(Id = ComponentConfig[0].Id);
                    objSSTaxConfig.put(strTaxFieldAPIName,mapTaxConfig.get(strTaxFieldAPIName));
            }
            upsert objSSTaxConfig;
            isSuccess = true;
        }
        
        return isSuccess;
        
        
    }
}