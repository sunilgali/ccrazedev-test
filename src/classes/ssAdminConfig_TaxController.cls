public class ssAdminConfig_TaxController {
    @AuraEnabled
    public static Map<String,Object> getTaxConfig(String storeFront,String configId){
        Map<String,Object> TaxConfig= CCSSTaxConfigImpl.getTaxConfig(storeFront,configId);
        return TaxConfig;
    }
    
    @AuraEnabled
    public static boolean saveTaxConfig(String storeFront,String TaxJson,String configId){
        Map<String,String> mapTaxConfig=new Map<String,String>();
        mapTaxConfig.put('Configuration_Type__c','Tax');
        mapTaxConfig.put('Storefront__c',storeFront);
        //mapTaxConfig.put('Active__c','true');
        mapTaxConfig.put('Storefront_Config_JSON__c',TaxJson);
        boolean flag=CCSSTaxConfigImpl.updateTax(storeFront,mapTaxConfig,configId);
        return flag;
    }

}