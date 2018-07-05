global with sharing class SSPricingHookExtension extends ccrz.cc_hk_Pricing
{ 
    global static List<ccrz__E_PriceListItem__c> fetchPricelistItems(Map<String,Object> inputData) 
       { 
        List<ccrz__E_PriceListItem__c> lstPrcItems = new List<ccrz__E_PriceListItem__c>();
        

        System.debug('SSPricingHookExtension: process: result is .... ' +  inputData);
        
        return lstPrcItems;
        
    }
}