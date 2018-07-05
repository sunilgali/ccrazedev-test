global  class SSProductService {

  
    global static SSProductModel getProduct(string productSKU, List<Map<String,String>> productTiers)  
    {
        String productId = SSProductHelper.getProductId(productSKU);
        if (productId!=null && !productId.equals('')) {
          return SSProductHelper.getProductInfo(productId, productTiers);        
        }
        return null;
    } 
    
      global static SSProductModel getProduct(string productSKU) {
        String productId = SSProductHelper.getProductId(productSKU);
        if (!String.isBlank(productSKU)) {
       return SSProductHelper.getProductInfo(productId, null);        
        }
        return null;
    } 
    
    global static List<SSProductModel> getAllProducts()  
    {

        //SSProductHelper productManager = new SSProductHelper();
        return SSProductHelper.getAllProducts();
    } 
    
    global static SSProductModel productDetails(String productSKU, List<Map<string,string>> tier) 
    {       
       SSProductModel product = new SSProductModel(); 
        //SSProductHelper productManager = new  SSProductHelper();
        String productId = SSProductHelper.getProductId(productSKU);
        if (productId != null) {
          return SSProductHelper.getProductInfo(productId, tier);                    
        }
        return product;
    }  
    
    global static List<SSProductModel> searchProductsEx(string searchTerm, string productId, String productSKU)  
    {
    List<SSProductModel> productList = new List<SSProductModel>();
        //SSProductHelper productManager = new SSProductHelper();
        if ((productId != null) && (!productId.equals(''))) {
            SSProductModel product = SSProductHelper.getProductInfo(productId);
            if (product != null) {
              productList.add(product);            
            }
        }
        else if ((productSKU != null) && (!productSKU.equals(''))) {
            productId = SSProductHelper.getProductId(productSKU);
            if (productId != null) {          
              SSProductModel product = SSProductHelper.getProductInfo(productId);
                productList.add(product);            
            }
        }
        else if ((searchTerm != null) && (!searchTerm.equals(''))) {
          return SSProductHelper.findProducts(searchTerm);        
        }
        return productList;
        
    }   
    
     /*
     * @description Method to fetch CrossSellProducts by its productId
     * @param       productId   SFID for the Product
     * @return      Returns the data populated in a Custom Model class with the Product Object info 
     */ 
    global static List<SSProductModel> getCrossSellProducts(String productId) {
        List<SSProductModel> crossSellProductList = new List<SSProductModel>();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'CrossSell'];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            SSProductModel crossSellProduct = new SSProductModel();
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
    global static SSProductModel getBuyProductSKU(String productId) {
        SSProductModel buyProduct = new SSProductModel();
      List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'Buy Product' LIMIT 1];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
          SSProductModel crossSellProduct = new SSProductModel();
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
    global static SSProductModel getTrialProductSKU(String productId) {
        SSProductModel trialProduct = new SSProductModel();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'Trial Product' LIMIT 1];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            SSProductModel crossSellProduct = new SSProductModel();
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
    global static List<SSProductModel> getUpSellProducts(String productId) {
        List<SSProductModel> upSellProductList = new List<SSProductModel>();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'UpSell'];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            SSProductModel upSellProduct = new SSProductModel();
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
    global static List<SSProductModel> getAddOnProducts(String productId) {
        List<SSProductModel> addOnProductList = new List<SSProductModel>();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'Add-On'];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            SSProductModel addOnProduct = new SSProductModel();
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
    global static List<SSProductModel> getMaintainanceProducts(String productId) {
        List<SSProductModel> maintainanceProductList = new List<SSProductModel>();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'Add-On'];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            SSProductModel maintainanceProduct = new SSProductModel();
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