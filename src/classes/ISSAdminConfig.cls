/**
* @author Raja Patnaik, Docmation
* @creationDate April 20, 2017
*
* @description Interface to retrive tax config details.
*

*/
global interface ISSAdminConfig
{
   
   Map<String,Object> getTaxConfig(String storeFront,String configId);
   
   boolean updateTax(String storeFront,Map<String,String> mapTaxConfig,String configId);
   
   Map<String,Object> getBillingandPaymentsConfig(String storeFront,String configId);
   
   boolean updateBillingandPayments(String storeFront,Map<String,String> mapTaxConfig,String configId);
   
}