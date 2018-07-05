global with sharing class SSCartProductPricingExtension extends ccrz.ccLogicProductPricing {

   
  public virtual override Map<String, Object> process(Map<String, Object> inputData){
 
    system.debug('SSCartProductPricingExtension'+inputData);
    
    // Copy Input Data Into New "Working Map" --> This Preserves The Input...
    Map<String,Object> workingMap = new Map<String, Object>(processInputData(inputData));
    
    system.debug('SSCartProductPricingExtension'+workingMap);
     
    /*
        
    // Fetch Base Price List & Price List Items Using ccApiPriceList.fetch()
    
  
    
    // Get A Complete List Of Products For Price List Fetch --> Filter Out Any Duplicate Composites
    processProductList(workingMap);
 
    // Fetch All Price Lists & Price List Items Using ccApiPriceList.fetchEntitled()
    fetchPriceListsAndItems(workingMap);
 
    // Organize Pricing Data By Sellers, SubProdTerms etc...
    processPriceListItems(workingMap);
 
    // Fetch Base Price List & Price List Items Using ccApiPriceList.fetch()
    fetchBasePriceListsAndItems(workingMap);
 
    // Determine Pricing By Product Type
    evaluatePricing(workingMap);
 
    //Fetch The Full PLI Data If Needed
    processSelectedPLIs(workingMap);
 
    //Query Attributes and Parse the Attribute Pricing JSON
    processAttributes(workingMap);
 
    // Clean Up Return Data & Return
    prepReturnData(workingMap);*/
        
         Map<String, Object> res = new Map<String, Object> {ccrz.ccApi.SUCCESS => false};
        //res.put(ccrz.ccApi.SUCCESS, true);
        System.debug('SSCartProductPricingExtension: process: return true');
        
        res = super.process(inputData);
        System.debug('SSCartProductPricingExtension: process: return true');
        
        System.debug('SSCartProductPricingExtension: process: result is .... ' +  res);
        
        
        Map<String, Object> pricingData = (Map<String, Object>)res.get(ccrz.ccAPIProduct.PRODUCTPRICINGDATA);
        
        System.debug('calling api pricingData addResults ' + pricingData);
        
        System.debug('calling api pricingData addResults JSON ' + json.serialize(pricingData));
        
        
    return res;
}

}