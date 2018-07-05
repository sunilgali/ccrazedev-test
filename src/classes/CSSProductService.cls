global class CSSProductService {
    
    global static CSSProductModel getProduct(string productSKU, List<Map<String,String>> productTiers)  
    {
        String productId = CSSProductHelper.getProductId(productSKU);
        if (productId!=null && !productId.equals('')) {
          return CSSProductHelper.getProductInfo(productId, productTiers);        
        }
        return null;
    } 
    
	global static CSSProductModel getProduct(string productSKU) {
      	String productId = CSSProductHelper.getProductId(productSKU);
        if (!String.isBlank(productSKU)) {
       		return CSSProductHelper.getProductInfo(productId, null);        
        }
        return null;
    } 
    
    global static List<CSSProductModel> getAllProducts(String storefront)  
    {
        return CSSProductHelper.getAllProducts(storefront);
    } 
    
    global static CSSProductModel getProductDetails(String productSKU, List<Map<string,string>> tier) 
    {       
        //check the logic, there should be some conditional logic to fetch based on tier, otherwise why pass
    	CSSProductModel product = new CSSProductModel(); 
        String productId = CSSProductHelper.getProductId(productSKU);
        if (productId != null) {
          return CSSProductHelper.getProductInfo(productId, tier);                    
        }
        return product;
    }  
    
    global static List<CSSProductModel> findProducts(string searchTerm, string productId, String productSKU)  
    {
	    List<CSSProductModel> productList = new List<CSSProductModel>();
        if ((productId != null) && (!productId.equals(''))) {
            CSSProductModel product = CSSProductHelper.getProductInfo(productId);
            if (product != null) {
              productList.add(product);            
            }
        }
        else if ((productSKU != null) && (!productSKU.equals(''))) {
            productId = CSSProductHelper.getProductId(productSKU);
            if (productId != null) {          
              CSSProductModel product = CSSProductHelper.getProductInfo(productId);
                productList.add(product);            
            }
        }
        else if ((searchTerm != null) && (!searchTerm.equals(''))) {
          return CSSProductHelper.findProducts(searchTerm);        
        }
        return productList;
        
    }   
    
     /*
     * @description Method to fetch CrossSellProducts by its productId
     * @param       productId   SFID for the Product
     * @return      Returns the data populated in a Custom Model class with the Product Object info 
     */ 
    global static List<CSSProductModel> getCrossSellProducts(String productId) {
        List<CSSProductModel> crossSellProductList = new List<CSSProductModel>();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'CrossSell'];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            CSSProductModel crossSellProduct = new CSSProductModel();
            crossSellProduct.productName = relatedProduct.ccrz__RelatedProduct__r.name;
            crossSellProduct.productId = relatedProduct.ccrz__RelatedProduct__r.id;
            crossSellProduct.productSKU = relatedProduct.ccrz__RelatedProduct__r.ccrz__SKU__c;
            crossSellProductList.add(crossSellProduct);
        }
        return crossSellProductList;
    }
    
    /*
     * @description Method to fetch buyProductSKU by its productId
     * @param    productId  SFID for the Product
     * @return    Returns the data populated in a Custom Model class with the Product Object info 
     */ 
    global static CSSProductModel getBuyProductSKU(String productId) {
        CSSProductModel buyProduct = new CSSProductModel();
      List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'Buy Product Version' LIMIT 1];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
          CSSProductModel crossSellProduct = new CSSProductModel();
          buyProduct.productName = relatedProduct.ccrz__RelatedProduct__r.name;
          buyProduct.productId = relatedProduct.ccrz__RelatedProduct__r.id;
          buyProduct.productSKU = relatedProduct.ccrz__RelatedProduct__r.ccrz__SKU__c;
            
        }
        return buyProduct;
    }
    
    /*
     * @description Method to fetch trailProductSKU by its productId
     * @param       productId   SFID for the Product
     * @return      Returns the data populated in a Custom Model class with the Product Object info 
     */ 
    global static CSSProductModel getTrialProductSKU(String productId) {
        CSSProductModel trialProduct = new CSSProductModel();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'Trial Product Version' LIMIT 1];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            CSSProductModel crossSellProduct = new CSSProductModel();
            trialProduct.productName = relatedProduct.ccrz__RelatedProduct__r.name;
            trialProduct.productId = relatedProduct.ccrz__RelatedProduct__r.id;
            trialProduct.productSKU = relatedProduct.ccrz__RelatedProduct__r.ccrz__SKU__c;
            
        }
        return trialProduct;
    }
   
     /*
     * @description Method to fetch UpSellProducts by its productId
     * @param       productId   SFID for the Product
     * @return      Returns the data populated in a Custom Model class with the Product Object info 
     */ 
    global static List<CSSProductModel> getUpSellProducts(String productId) {
        List<CSSProductModel> upSellProductList = new List<CSSProductModel>();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'UpSell'];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            CSSProductModel upSellProduct = new CSSProductModel();
            upSellProduct.productName = relatedProduct.ccrz__RelatedProduct__r.name;
            upSellProduct.productId = relatedProduct.ccrz__RelatedProduct__r.id;
            upSellProduct.productSKU = relatedProduct.ccrz__RelatedProduct__r.ccrz__SKU__c;
            upSellProductList.add(upSellProduct);
        }
        return upSellProductList;
    }
    
         /*
     * @description Method to fetch UpSellProducts by its productId
     * @param       productId   SFID for the Product
     * @return      Returns the data populated in a Custom Model class with the Product Object info 
     */ 
    global static List<CSSProductModel> getAddOnProducts(String productId) {
        List<CSSProductModel> addOnProductList = new List<CSSProductModel>();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'Add-On'];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            CSSProductModel addOnProduct = new CSSProductModel();
            addOnProduct.productName = relatedProduct.ccrz__RelatedProduct__r.name;
            addOnProduct.productId = relatedProduct.ccrz__RelatedProduct__r.id;
            addOnProduct.productSKU = relatedProduct.ccrz__RelatedProduct__r.ccrz__SKU__c;
            addOnProductList.add(addOnProduct);
        }
        return addOnProductList;
    } 
    
    
           /*
     * @description Method to fetch UpSellProducts by its productId
     * @param       productId   SFID for the Product
     * @return      Returns the data populated in a Custom Model class with the Product Object info 
     */ 
    global static List<CSSProductModel> getMaintainanceProducts(String productId) {
        List<CSSProductModel> maintainanceProductList = new List<CSSProductModel>();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'Add-On'];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            CSSProductModel maintainanceProduct = new CSSProductModel();
            maintainanceProduct.productName = relatedProduct.ccrz__RelatedProduct__r.name;
            maintainanceProduct.productId = relatedProduct.ccrz__RelatedProduct__r.id;
            maintainanceProduct.productSKU = relatedProduct.ccrz__RelatedProduct__r.ccrz__SKU__c;
            maintainanceProductList.add(maintainanceProduct);
        }
        return maintainanceProductList;
    } 
    
     /*
     * @description Method to fetch ProductType by its productId
     * @param       productId   SFID for the Product
     * @return      Returns the data populated in a Custom Model class with the Product Object info 
     */ 
    global static String getProductType(String productId) {
        List<ccrz__E_Product__c> productList = [select id, ccrz__ProductType__c,ccrz__PrimaryAttr__c,ccrz__SecondaryAttr__c,ccrz__TertiaryAttr__c from ccrz__E_Product__c where Id = :productId Limit 1];
        if (productList.size() > 0) {
            if(productList[0].ccrz__ProductType__c == 'Product' && 
            (productList[0].ccrz__PrimaryAttr__c != null || productList[0].ccrz__SecondaryAttr__c != null || productList[0].ccrz__TertiaryAttr__c != null))
            { 
              return 'ADC';
            }
            else
            {
              return productList[0]. ccrz__ProductType__c;
            }
        }
        return null;
    }   

}