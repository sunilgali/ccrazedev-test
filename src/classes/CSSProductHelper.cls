global class CSSProductHelper {
    
     /*
     * @description Method to fetch list of Products
     * @return      Returns the data populated in a Custom Model class with the Product Object 
     */ 
    global static List<CSSProductModel> getAllProducts(String storefront) {
        List<CSSProductModel> productList = new List<CSSProductModel>();
        List<ccrz__E_Product__c> products = [SELECT id, ccrz__TaxRateId__c, Is_VAT_or_Tax_Exempt__c, ccrz__Storefront__c, ccrz__ShortDesc__c,
                                                Price_Type__c
                                                ,Sold_By__c,Terms_and_Conditions__c,ccrz__Subscription_Disclaimer__c,
                                                Billing_Product_ID__c,ccrz__AlternateName__c,ccrz__Industry__c,
                                                ccrz__LongDesc__c ,Is_Trial_Product__c,Trial_Period_in_Days__c,ccrz__Taxable__c,ccrz__Quantityperunit__c,ccrz__UnitOfMeasure__c,
                                                ccrz__SKU__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductType__c,name,
                                                ccrz__ProductStatus__c,Market_Region__c,Product_Family__c,Cancellation_Period_in_Days__c,Provisioning_Product_ID__c,
                                                country__c,Product_Subscription_Type__c from ccrz__E_Product__c 
                                                where ccrz__Storefront__c =: storefront order by createddate];
        for (ccrz__E_Product__c product : products) {
            productList.add(getCoreProductInfo(product));            
        }
        System.debug('Product list returned ' + productList.size());
        return productList;
    }
    
    /*
     * @description Method to Find products by its searchTerm
     * @param       searchTerm      Search Term to fetch a product
     * @return      Returns the data populated in a Custom Model class with the Product Object info 
     */ 
    global static List<CSSProductModel> findProducts(String searchTerm) {
        List<CSSProductModel> productList = new List<CSSProductModel>();
        List<List<ccrz__E_Product__c>> productsList = [Find :searchTerm in All fields returning ccrz__E_Product__c (id,country__c, ccrz__TaxRateId__c, Is_VAT_or_Tax_Exempt__c, ccrz__Storefront__c, ccrz__ShortDesc__c,Price_Type__c,Sold_By__c,Terms_and_Conditions__c,ccrz__Subscription_Disclaimer__c,Billing_Product_ID__c,ccrz__AlternateName__c,ccrz__Industry__c,ccrz__LongDesc__c ,Is_Trial_Product__c,Trial_Period_in_Days__c,ccrz__Taxable__c,ccrz__Quantityperunit__c,ccrz__UnitOfMeasure__c,ccrz__SKU__c,ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductType__c,name,ccrz__ProductStatus__c,Market_Region__c,Product_Family__c,Cancellation_Period_in_Days__c,Provisioning_Product_ID__c)];
        for(list<ccrz__E_Product__c> products:productsList){
            for (ccrz__E_Product__c product : products) {
                productList.add(getCoreProductInfo(product));  
            }
        }
        System.debug('Product list returned ' + productList.size());
        return productList;
    }

    /*
     * @description Method to get productInfo by its productId
     * @param       productId   SFID for the Product
     * @return      Returns the data populated in a Custom Model class with the Product Object info 
     */
    global static CSSProductModel getProductInfo(String productId){        
        return getProductInfo(productId, null);
    }
    
    /*
     * @description Method to get product Id by its Sku
     * @param       sku     Product SKU
     * @return      Returns the data populated in a Custom Model class with the Product Object info 
     */
    global static String getProductId(String sku) {        
        List<ccrz__E_Product__c> productList = [select id from ccrz__E_Product__c where ccrz__SKU__c = :sku];
        if (productList.size() > 0) {
            return productList[0].id;
        }
        return null;
    }
    
     /*
     * @description Method to Validate ProductSku
     * @param       sku     Product SKU
     * @return      Returns a boolean that indicates a valid or invalid sku 
     */
    global static Boolean isValidSKU(String sku) {        
        List<ccrz__E_Product__c> productList = [select id from ccrz__E_Product__c where ccrz__SKU__c = :sku];
        if (productList.size() > 0) {
            return true;
        }
        else {
            return false;
        }
    }

    /*
     * @description Method to fetch CoreProductInfo from the CC Product Object
     * @param       prod    CC Product Object
     * @return      Returns the data populated in a Custom Model class with the Product Object info
     */ 
    global static CSSProductModel getCoreProductInfo(ccrz__E_Product__c prod) {
        CSSProductModel product = new CSSProductModel();        
        product.productId = prod.id;
        product.productType = prod.ccrz__ProductType__c;
        product.productName = prod.name;
        product.productSKU = prod.ccrz__SKU__c;
        product.storefront = prod.ccrz__Storefront__c;
        product.alternateName = prod.ccrz__AlternateName__c;
        product.productFamily = prod.Product_Family__c; 
        product.status = prod.ccrz__ProductStatus__c;
        product.country = prod.Country__c;
        product.productFamily = prod.Product_Family__c;
        product.industry = prod.ccrz__Industry__c;        
        //product.segment = prod.CC_Product_Segment__c != null ? prod.CC_Product_Segment__c.split(';') : null;        
        product.startDate = prod.ccrz__StartDate__c;
        product.endDate = prod.ccrz__EndDate__c;       
        product.longDescription = prod.ccrz__LongDesc__c;
        product.shortDescription = prod.ccrz__ShortDesc__c;        
        product.uom = prod.ccrz__UnitOfMeasure__c; 
        product.quantityPerUnit = prod.ccrz__Quantityperunit__c;
        product.trial = prod.Is_Trial_Product__c;
        product.trialLength = prod.Trial_Period_in_Days__c;
        product.taxCode = prod.ccrz__TaxRateId__c;
                            
        //this is incorrect
        product.contractDuration = prod.Trial_Period_in_Days__c;
        String disclaimer = prod.ccrz__Subscription_Disclaimer__c;
        product.subscriptionDisclaimer = disclaimer;
        
        //pricing setup for product
        product.taxable = prod.ccrz__Taxable__c;
        product.soldBy =  prod.Sold_By__c;
        product.vatRule = prod.Is_VAT_or_Tax_Exempt__c;
        //product.feeType = prod.Fee_Type__c;
        product.priceType = prod.Price_Type__c;
        //product.vatTaxExemptId = prod.VAT_Tax_Exempted__c;
        //product.currencyUnit = prod.CurrencyIsoCode;
        product.termsAndConditions  = prod.Terms_and_Conditions__c;
        product.subscriptionType = prod.Product_Subscription_Type__c;
        //product.individuallySold = prod.Sold_By__c;
        product.cancellationPeriod = prod.Cancellation_Period_in_Days__c;
        
        //zuora or subscription engine related attributes
        product.billingProductId = prod.Billing_Product_ID__c;
        //product.ratePlanId = prod.Rate_Plan_Id__c;
      //  product.tierCode = prod.Provisioning_Product_ID__c;
        product.entitlementProductId = prod.Provisioning_Product_ID__c;
        getProductMedia(product);
        return product;        
    }
    
    global static void getProductMedia(CSSProductModel product){
        //System.debug('Inside getProductMedia select ccrz__FilePath__c , ccrz__StaticResourceName__c , ccrz__MediaType__c from ccrz__E_ProductMedia__c where ccrz__Product__r.id='+product.productId);
        List<ccrz__E_ProductMedia__c > productMedia = [select ccrz__URI__c , ccrz__FilePath__c , ccrz__StaticResourceName__c , ccrz__MediaType__c , ccrz__ProductMediaSource__c from ccrz__E_ProductMedia__c where ccrz__Product__r.id=:product.productId];
        for(ccrz__E_ProductMedia__c pm : productMedia){
            //System.debug('Product Media '+pm.ccrz__MediaType__c);
            if(pm.ccrz__MediaType__c == 'Product Image Thumbnail'){
                if(pm.ccrz__ProductMediaSource__c == 'Attachment'){
                    product.productThumbnailImage = pm.ccrz__FilePath__c;
                }
                else if(pm.ccrz__ProductMediaSource__c == 'URI'){
                    product.productThumbnailImage = pm.ccrz__URI__c;
                }
                else{
                    product.productThumbnailImage = getResourceURL(pm.ccrz__StaticResourceName__c) + '/' + pm.ccrz__FilePath__c;
                }
            } 
            if(pm.ccrz__MediaType__c == 'Product Image'){
                if(pm.ccrz__ProductMediaSource__c == 'Attachment'){
                    product.productImage = pm.ccrz__FilePath__c;
                }
                else if(pm.ccrz__ProductMediaSource__c == 'URI'){
                    product.productImage = pm.ccrz__URI__c;
                }
                else{
                    product.productImage = getResourceURL(pm.ccrz__StaticResourceName__c) + '/' + pm.ccrz__FilePath__c;
                }
            }
        }
    }
    
    global static String getResourceURL(String resourceName){
        //Fetching the resource
        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];
        //Checking if the result is returned or not
        if(resourceList.size() == 1){
           //Getting namespace
           String namespace = resourceList[0].NamespacePrefix;
           //Resource URL
           return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
        }
        else return '';
    }
    
    /*
     * @description Method to fetch ProductInfo By a Product SKU
     * @param       SKU     ProductSku
     * @return      Returns the data populated in a Custom Model class with the Product Object info
     */ 
    global static CSSProductModel getProductInfoBySKU(String productSKU){        
        // [{ "ProductName": "Sage Payroll_UKI", "tierName": "Employees", "tierQuantity":"1"}]
        String productType = '';
        ccrz__E_Product__c product = null;
        List<ccrz__E_Product__c> lstProduct = [select id,Is_VAT_or_Tax_Exempt__c,Sold_By__c, ccrz__ShortDesc__c,Price_Type__c, ccrz__Storefront__c,  
                                                Terms_and_Conditions__c,ccrz__Subscription_Disclaimer__c,Billing_Product_ID__c,
                                                ccrz__AlternateName__c,ccrz__Industry__c,ccrz__LongDesc__c ,
                                                Is_Trial_Product__c,Trial_Period_in_Days__c,ccrz__Taxable__c,ccrz__Quantityperunit__c,ccrz__UnitOfMeasure__c,ccrz__SKU__c,
                                                ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductType__c,name,
                                                ccrz__ProductStatus__c,Market_Region__c,Product_Family__c,Cancellation_Period_in_Days__c,Provisioning_Product_ID__c, 
                                                ccrz__TaxRateId__c, country__c,Product_Subscription_Type__c from ccrz__E_Product__c where ccrz__SKU__c = :productSKU LIMIT 1];
        if(lstProduct!=null && lstProduct.size()>0)
        {
            product = lstProduct[0];
        }
        if (product == null)
        {
            return null;
        }
        CSSProductModel productModel = getCoreProductInfo(product);        
        return productModel;
    }    
    
     /*
     * @description Method to fetch ProductInfo By ProductId and productTiers
     * @param       productId       SFID for the product
     * @param       productTiers    List of Map of Product Tiers
     * @return      Returns the data populated in a Custom Model class with the Product Object info
     */ 
    global static CSSProductModel getProductInfo(String productId, List<Map<String,String>> productTiers){        
        // [{ "ProductName": "Sage Payroll_UKI", "tierName": "Employees", "tierQuantity":"1"}]
        String productType = '';
        ccrz__E_Product__c product = [select id,Is_VAT_or_Tax_Exempt__c, ccrz__ShortDesc__c,Price_Type__c, ccrz__Storefront__c,  
                                                Sold_By__c,Terms_and_Conditions__c,ccrz__Subscription_Disclaimer__c,Billing_Product_ID__c,
                                                ccrz__AlternateName__c,ccrz__Industry__c,ccrz__LongDesc__c ,
                                                Is_Trial_Product__c,Trial_Period_in_Days__c,ccrz__Taxable__c,ccrz__Quantityperunit__c,ccrz__UnitOfMeasure__c,ccrz__SKU__c,
                                                ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductType__c,name,
                                                ccrz__ProductStatus__c,Market_Region__c,Product_Family__c,Cancellation_Period_in_Days__c,Provisioning_Product_ID__c, 
                                                ccrz__TaxRateId__c, country__c,Product_Subscription_Type__c from ccrz__E_Product__c where id = :productId LIMIT 1];
    	return getProductDetails(product, productTiers);
    }

    global static CSSProductModel getProductAndPricingInfoById(String productId, List<Map<String,String>> productTiers){        
        String productType = '';
        ccrz__E_Product__c product = [select id,Is_VAT_or_Tax_Exempt__c, ccrz__ShortDesc__c,Price_Type__c, ccrz__Storefront__c,  
                                                Sold_By__c,Terms_and_Conditions__c,ccrz__Subscription_Disclaimer__c,Billing_Product_ID__c,
                                                ccrz__AlternateName__c,ccrz__Industry__c,ccrz__LongDesc__c ,
                                                Is_Trial_Product__c,Trial_Period_in_Days__c,ccrz__Taxable__c,ccrz__Quantityperunit__c,ccrz__UnitOfMeasure__c,ccrz__SKU__c,
                                                ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductType__c,name,
                                                ccrz__ProductStatus__c,Market_Region__c,Product_Family__c,Cancellation_Period_in_Days__c,Provisioning_Product_ID__c, 
                                                ccrz__TaxRateId__c, country__c,Product_Subscription_Type__c from ccrz__E_Product__c where id = :productId LIMIT 1];
    	return getProductDetails(product, productTiers);
    }

    global static CSSProductModel getProductAndPricingInfoBySKU(String productSKU, List<Map<String,String>> productTiers){        
        String productType = '';
        ccrz__E_Product__c product = [select id,Is_VAT_or_Tax_Exempt__c, ccrz__ShortDesc__c,Price_Type__c, ccrz__Storefront__c,  
                                                Sold_By__c,Terms_and_Conditions__c,ccrz__Subscription_Disclaimer__c,Billing_Product_ID__c,
                                                ccrz__AlternateName__c,ccrz__Industry__c,ccrz__LongDesc__c ,
                                                Is_Trial_Product__c,Trial_Period_in_Days__c,ccrz__Taxable__c,ccrz__Quantityperunit__c,ccrz__UnitOfMeasure__c,ccrz__SKU__c,
                                                ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductType__c,name,
                                                ccrz__ProductStatus__c,Market_Region__c,Product_Family__c,Cancellation_Period_in_Days__c,Provisioning_Product_ID__c, 
                                                ccrz__TaxRateId__c, country__c,Product_Subscription_Type__c from ccrz__E_Product__c where ccrz__SKU__c = :productSKU LIMIT 1];
    	return getProductDetails(product, productTiers);
    }

    global static CSSProductModel getProductDetails(ccrz__E_Product__c productInfo, List<Map<String,String>> productTiers) {
        CSSProductModel product = null;
        if (productInfo != null) {
            product = new CSSProductModel();
            ccrz__E_Product__c prod = productInfo;            
            product = getCoreProductInfo(prod);   
            system.debug('CSSProductHelper: getProductDetails: retrieved sku '+product.productSKU);
            String productType = product.productType;
            String productId = prod.Id;
            List<Map<String, String>> subProdTermList = getSubProdTerms(productId,null);
            System.debug('CSSProductHelper: getProductDetails: retrieved productType ########' + productType);
            Boolean isBundledProduct = false;
            Boolean tierPricing = false;
            if (productType.equals('Dynamic Kit') || productType.equals('Bundle')) {
                isBundledProduct = true;
                System.debug('CSSProductHelper: getProductDetails: Retrieving info for Dynamic kit');
               	product.bundleComponents = getBundledComponents(productId);
            }
            else { //check and calculate tiered pricing only for regular products. ignore product bundles or dynamic kits
                tierPricing = isTierPriced(productId);
                System.debug('retrievied tiered pricing info######');
            }
            product.isBundledProduct = isBundledProduct;
            
            //get pricing information
            product.tierPriced = tierPricing;
           	System.debug('Inside if isBundledProduct = '+isBundledProduct);
            if ((productTiers != null) && (productTiers.size() >0)) {
            	product.price = getPricingInfo(productId, isBundledProduct, tierPricing, productTiers[0], subProdTermList);                            
           	}
            else {
            	product.price = getPricingInfo(productId, isBundledProduct, tierPricing, null, subProdTermList);
                System.debug('Inside else getPricingInfo '+product.price);
          	}            
        }
        return product;
    }

    /*
     * @description Method to fetch SubProdTerms By ProductId
     * @param       productId       SFID for the Product
     * @return      Returns a List of subProdTerms
     */ 
    global static List<Map<String, String>> getSubProdTerms(String productId,String subscriptionTermType) {
        List<ccrz__E_SubProdTerm__c> subProdTermList = [select id,ccrz__OrderFrequencyUOM__c,ccrz__EffectiveStart__c,ccrz__EffectiveEnd__c,
        ccrz__OrderFrequency__c,ccrz__AutoRenew__c, ccrz__InstallmentCount__c, ccrz__InstallmentFrequency__c, ccrz__InstallmentFrequencyUOM__c 
        from ccrz__E_SubProdTerm__c where id in (select ccrz__SubProdTerm__c from ccrz__E_PriceListItem__c where ccrz__RecurringPrice__c = false 
        and ccrz__Product__r.id=:productId)];
        
        List<Map<String, String>> subscriptionTermList = new List<Map<String, String>>();
        Boolean isSPTFound = false;
        for (ccrz__E_SubProdTerm__c subProdTerm : subProdTermList) {
        
            if(subProdTerm.ccrz__InstallmentFrequencyUOM__c.equalsIgnoreCase(subscriptionTermType))
               isSPTFound = true;
            
            if(isSPTFound || subscriptionTermType == null)
            {
              Map<String, String> subscriptionInfo = new Map<String, String>();
                boolean autoRenewal = subProdTerm.ccrz__AutoRenew__c;
                boolean availableForSubscription =  true;
                
                Decimal installmentCount = subProdTerm.ccrz__InstallmentCount__c;
                Decimal installmentFrequency = subProdTerm.ccrz__InstallmentFrequency__c;
                String installmentUOM = subProdTerm.ccrz__InstallmentFrequencyUOM__c;
                String subProdTermId = subProdTerm.Id;
                
                subscriptionInfo.put('subscriptionTermId', subProdTermId);
                subscriptionInfo.put('subscriptionAutoRenewal', String.valueOf(autoRenewal));
                subscriptionInfo.put('subscriptionDuration', '');
                subscriptionInfo.put('subscriptionFrequency', String.valueOf(installmentFrequency));
                subscriptionInfo.put('subscriptionInstallmentFrequency', String.valueOf(installmentFrequency));
                subscriptionInfo.put('subscriptionInstallmentCount', String.valueOf(installmentCount));
                subscriptionInfo.put('subscriptionInstallmentUOM', String.valueOf(installmentUOM));
                subscriptionInfo.put('availableForSubscription', String.valueOf(availableForSubscription));          
                
                subscriptionTermList.add(subscriptionInfo);
                
                isSPTFound = false;
            }
        }
            
        return subscriptionTermList;        
    }
    
    
    
    /*
     * @description Method to check for a TierPriced Product By the productId
     * @param       productId       SFID or SKU for the product
     * @return      Returns a boolean that indicates whether it is a tiered Product or not
     */ 
    global static Boolean isTierPriced(String productId) {
        Boolean tieredPricingRule = false;
        list<ccrz__E_PriceListItem__c> plst = [select id,ccrz__ItemType__c,ccrz__PricingTiers__c from ccrz__E_PriceListItem__c where (ccrz__Product__r.id =:productId 
        or ccrz__Product__r.ccrz__SKU__c =:productId ) and ccrz__ItemType__c=:'tiered' limit 1];
        system.debug('>>>>'+plst);
        if(plst.size()>0){
            tieredPricingRule = true;    
        }  
        return tieredPricingRule;                   
    }
    
    /*
     * @description Method to check for a TierPriced Product By the productId
     * @param       productId       SFID or SKU for the product
     * @return      Returns a boolean that indicates whether it is of type Bucket priced Product or not
     */ 
    global static Boolean isBucketPriceProduct(String productId) {
    
        Boolean bucketPriceProduct = false;
        list<ccrz__E_Product__c> plst = [select id from ccrz__E_Product__c where (id =:productId or ccrz__SKU__c =:productId) and 
        Price_Type__c  ='Volume Pricing'];
        if(plst.size()>0){
            bucketPriceProduct = true;
        } 
        return bucketPriceProduct;                   
    }
    
    /*
     * @description Method to check for a BundlePriced Product By the productId
     * @param       productId       SFID for the product
     * @return      Returns a boolean that indicates whether it is a Bundle Product or not
     */ 
    global static Boolean isProductBundle(String productId) {
        Boolean bundledPricingRule = false;
       ccrz__E_Product__c plst = [select id from ccrz__E_Product__c where id =:productId and ccrz__ProductType__c = 'Bundle'limit 1];
        if(plst != null){
            bundledPricingRule = true;
        } 
        return bundledPricingRule;                   
    }
    
    /*
     * @description Method to check for a ADCPriced Product By the productId
     * @param       productId       SFID or SKU for the product
     * @return      Returns a boolean that indicates whether it is a ADC Product or not
     */ 
    global static Boolean isADCPriced(String productId) {
        Boolean ADCPricingRule = false;
        list<ccrz__E_Product__c> plst = [select id from ccrz__E_Product__c where (id =:productId or ccrz__SKU__c =:productId )and 
        (ccrz__PrimaryAttr__c != null OR ccrz__SecondaryAttr__c != null OR ccrz__TertiaryAttr__c != null) limit 1];
        
        if(plst.size()>0){
            ADCPricingRule = true;
        } 
        return ADCPricingRule;                   
    }
   
    /*
     * @description Method to fetch PricingInfo by productId,SubProdTermList,BundledProduct and tierPricing
     * @param       productId               SFID for the Product
     * @param       isBundledProduct        Boolean that indicates if it is a bundledProduct
     * @param       tierPricing             Boolean that indicates if it is a tierPriced Product
     * @param       subProdTermList         List Of Map of Product subProdTerm
     * @return      Returns the data populated in a Custom Model class with the Pricing Object info
     */ 
    global static List<CSSPriceModel> getPricingInfo(String productId, boolean isBundledProduct, boolean tierPricing, Map<String,String> productTier, List<Map<String, String>> subProdTermList) {
        List<CSSPriceModel> priceListItems = new List<CSSPriceModel>();          
        list<ccrz__E_PriceListItem__c> priceItemList = [select id,Name,ccrz__SubProdTerm__c, ccrz__Product__r.ccrz__UnitOfMeasure__c,ccrz__Price__c, ccrz__StartDate__c, ccrz__EndDate__c,ccrz__Product__r.name,ccrz__Pricelist__r.name,ccrz__UnitOfMeasure__c,ccrz__RecurringPrice__c,ccrz__MinQty__c,ccrz__MaxQty__c,ccrz__Pricelist__r.ccrz__CurrencyISOCode__c,ccrz__Product__r.ccrz__Sequence__c from ccrz__E_PriceListItem__c where ccrz__RecurringPrice__c = false and ccrz__Product__r.id = :productId and ccrz__StartDate__c <= TODAY and ccrz__EndDate__c >= TODAY];
        System.debug('priceItemList'+priceItemList);
        for (ccrz__E_PriceListItem__c priceListItem : priceItemList) {
            CSSPriceModel price = new CSSPriceModel();
           // sp.feeType = priceItemList[0].Fee_Type__c;
           // sp.priceType = priceItemList[0].Price_Type__c;
           String subProdTermId = priceListItem.ccrz__SubProdTerm__c;
            If (!String.IsBlank(subProdTermId)) {        
            for (Map<String, String> subscriptionProductTerm : subProdTermList) {
                String tSubProdTerm = (String)subscriptionProductTerm.get('subscriptionTermId');
                if (tSubProdTerm.equalsIgnoreCase(subProdTermId)) {
                    if(subscriptionProductTerm.get('subscriptionAutoRenewal')!=null)
                    {
                        price.subscriptionAutoRenewal = Boolean.valueOf(subscriptionProductTerm.get('subscriptionAutoRenewal'));     
                    }
                    if(subscriptionProductTerm.get('subscriptionInstallmentCount')!=null)
                    {
                        price.subscriptionInstallmentCount = Decimal.valueOf(subscriptionProductTerm.get('subscriptionInstallmentCount'));   
                    }
                    if(subscriptionProductTerm.get('subscriptionInstallmentFrequency')!=null)
                    {
                        price.subscriptionInstallmentFrequency = Decimal.valueOf(subscriptionProductTerm.get('subscriptionInstallmentFrequency'));   
                    }
                    if(subscriptionProductTerm.get('subscriptionInstallmentUOM')!=null)
                    {
                        price.subscriptionInstallmentUOM = String.valueOf(subscriptionProductTerm.get('subscriptionInstallmentUOM'));   
                    }
                    if(subscriptionProductTerm.get('availableForSubscription')!=null)
                    {
                        price.availableForSubscription = Boolean.valueOf(subscriptionProductTerm.get('availableForSubscription'));    
                    }
                    
                    price.subscriptionTermId = tSubProdTerm;
                }  
            }
            }
            price.productName = priceListItem.ccrz__Product__r.name;
            System.debug('Product Name ' + price.productName + '-' + productId);
            price.startDate = priceListItem.ccrz__StartDate__c;
            price.endDate = priceListItem.ccrz__EndDate__c;
            price.currencyCode = priceListItem.ccrz__Pricelist__r.ccrz__CurrencyISOCode__c;
            //price.listID  = priceListItem.ccrz__Pricelist__r.id; 
            //price.listItemID  = priceListItem.id; 
            //price.listName  = priceListItem.ccrz__Pricelist__r.name;
            price.priceListID = priceListItem.id;
            price.listPrice  = priceListItem.ccrz__Price__c; 
            price.minQuantity  = priceListItem.ccrz__MinQty__c;
            price.maxQuantity  = priceListItem.ccrz__MaxQty__c;
            price.recurringPrice  = priceListItem.ccrz__RecurringPrice__c;
            price.uom  = priceListItem.ccrz__UnitOfMeasure__c;            
            price.enabled = true; //priceItemList[0].ccrz__StartDate__c < system.today() ? (priceItemList[0].ccrz__EndDate__c > system.today() ? true : false) : false;
            System.debug('getPricingInfo: tierPricing ' + tierPricing);
             System.debug('############price'+price);   
            if (tierPricing) {
                //price.tierPriceList = getTierPricingInfo(priceListItem.id, priceListItem.Name, productTier, subProdTermList); 
                price.tierPriceList = getTierdPricingInfo(priceListItem.id, priceListItem.Name, productTier); 
            }
            priceListItems.add(price);
           
        }
        System.debug('priceListItems size is '+priceListItems.size());
        return priceListItems;
    }

     /*
     * @description Method to fetch Tiered PricingInfo by priceListItemId,tierAttribute,productTier and subProdTermList
     * @param       priceListItemId         SFID for the PriceListItem
     * @param       tierAttribute           Tier Attribute 
     * @param       productTier             Map of Product Tiers
     * @param       subProdTermList         List Of Map of Product subProdTerm
     * @return      Returns the data populated in a Custom Model class with the Pricing Object Tier info
     */ 
     // *******Please Do not use this method Instead use getTierdPricingInfo method ******************
    global static List<CSSPriceTierModel> getTierPricingInfo(String priceListItemId, String tierAttribute, Map<String,String> productTier, List<Map<String, String>> subProdTermList) {
        System.debug('getTierPricingInfo: priceListItemId ' + priceListItemId);
        List<CSSPriceTierModel> pricingTierList = new List<CSSPriceTierModel>();
        List<ccrz__E_RuleTargetPLI__c> pliRuleTarget = [select id,ccrz__E_Rule__r.id,ccrz__E_PriceListItem__c from ccrz__E_RuleTargetPLI__c where ccrz__E_PriceListItem__r.id = :priceListItemId limit 1];
        if (pliRuleTarget.size()>0) {
            system.debug('pliRuleTarget'+pliRuleTarget[0].ccrz__E_Rule__r.id);
            
            List<ccrz__E_PriceModifier__c> priceModifierList = [select name, id,ccrz__Quantity__c,ccrz__Amount__c,ccrz__CartTotalAmount__c from ccrz__E_PriceModifier__c where id IN (select ccrz__PriceModifier__c from ccrz__E_RulePricingModifier__c where ccrz__Rule__r.id =: pliRuleTarget[0].ccrz__E_Rule__r.id) order by ccrz__Quantity__c asc];
                           
            decimal minQuantity = 0;                                                                                                                                                                                      
            Integer iCount = 0;                                                                                                                                                                                      
            for(ccrz__E_PriceModifier__c priceModifier:priceModifierList){
                CSSPriceTierModel pricingTier = new CSSPriceTierModel();
                iCount++;
                pricingTier.tierAttribute = tierAttribute;
                decimal maxQuantity = priceModifier.ccrz__Quantity__c;
                pricingTier.maxQuantity = maxQuantity;
                pricingTier.minQuantity = minQuantity + 1;
                pricingTier.tierDescription = pricingTier.minQuantity + '-' + pricingTier.maxQuantity + ' ' + tierAttribute;
                //st.maxQuantity = min;
                pricingTier.listPrice = priceModifier.ccrz__Amount__c;
                System.debug('Retrieving Pricing based on Product TIer');
                if (productTier == null) {
                    pricingTierList.add(pricingTier);                                                            
                }
                else {
                    String sTierQuantity = (String)productTier.get('tierQuantity');
                    Decimal tierQuantity = 1;
                    if ((sTierQuantity != null) && (!sTierQuantity.equals(''))) {
                        tierQuantity = Decimal.valueOf(sTierQuantity);
                    }
                    System.debug('Retrieving tierQuantity ' + tierQuantity);
                    System.debug('Retrieving minQuantity ' + pricingTier.minQuantity);
                    System.debug('Retrieving maxQuantity ' + pricingTier.maxQuantity);
                    System.debug(' maxQuantity ' + maxQuantity);
                    System.debug(' iCount ' + iCount);
                    if (tierQuantity >= pricingTier.minQuantity) {
                        if ((pricingTier.maxQuantity != null) && (tierQuantity <= pricingTier.maxQuantity)) {
                             pricingTierList.add(pricingTier); 
                        }
                        else if (pricingTier.maxQuantity == null) {
                             pricingTierList.add(pricingTier); 
                        }
                        //if a valid match is not found for the tier then return the last tier value
                        else if ((iCount == priceModifierList.size()) && (pricingTierList.size() == 0)) {
                             pricingTierList.add(pricingTier);                             
                        }
                    }                    
                        System.debug('Retrieving tierQuantity matching price ' + pricingTierList.size());                    
                }
                minQuantity = maxQuantity;                
            }
            if (pricingTierList.size() > 0) {                
                System.debug('Retrieving  matching price ' + pricingTierList[0].listPrice);
            }
        }
        return pricingTierList;
    }
    
    /*
     * @description Method to fetch Bundled Product List by productBundle and productTiers
     * @param       productBundle           Custom Model class with the Product Object Info
     * @param       productTier             List of Map of Product Tiers
     * @return      Returns the data populated in a Custom Model class with the Product Object info
     */ 
    global static CSSProductModel getBundledProductList(CSSProductModel productBundle, List<Map<String,String>> productTiers) {
        String productId = productBundle.productId;
        System.debug('productId ' + productId);
        List<CSSProductModel> bundledProductList = new list<CSSProductModel>();
        List<ccrz__E_CompositeProduct__c> productList = [select ccrz__Optional__c,ccrz__Description__c,ccrz__Composite__r.id from ccrz__E_CompositeProduct__c where ccrz__Composite__r.id = :productId];
        System.debug('retrieved product list ' + productId);

        Double bundleListPrice = 0;
        Double bundleDiscountedPrice = 0;
        Double bundleSavingsPercentage = 0;
        system.debug('---------productTiers---------------'+productTiers);
        for (ccrz__E_CompositeProduct__c product :productList) {
            String bundledComponentId = product.ccrz__Composite__r.id;
            System.debug('retrieved bundledComponentId ' + bundledComponentId);
            //SSProductHelper productHelper = new SSProductHelper();
            CSSProductModel bundledProduct = CSSProductHelper.getProductInfo(bundledComponentId, productTiers);
            System.debug('Bundled component name ' + bundledProduct.productName);
            
            //check for bundle related coupons for the component
            Map<String, String> coupon = getBundledComponentCoupon(productId, bundledComponentId);
            System.debug('Retrieved bundle coupon  ');
            Double productListPrice = bundledProduct.price[0].listPrice;
                //check if product is based on tiered pricing. if it is then use the first tier for calculations
            if (bundledProduct.tierPriced) {
                system.debug('--------bundledProduct.price.tierPriceList------------'+bundledProduct.price[0].tierPriceList);
                Integer tieredPriceListCount = bundledProduct.price[0].tierPriceList.size();
                system.debug('--------tieredPriceListCount------------'+tieredPriceListCount);
                productListPrice = bundledProduct.price[0].tierPriceList[tieredPriceListCount-1].listPrice;
                System.debug('Tiered Product productListPrice ... ' + productListPrice);
            }
            System.debug('Checking if coupon is null  ');
            if (coupon != null) {
                System.debug('coupon is not null  ');
                String couponType = (String)coupon.get('couponType');        
                System.debug('couponType ' + couponType);
                Double discountAmount = Double.valueOf((String)coupon.get('discountAmount'));
                bundledProduct.price[0].bundledComponentPrice = getDiscountedPrice(couponType, discountAmount, productListPrice); 
            }
            else {
                bundledProduct.price[0].bundledComponentPrice = productListPrice;     
            }

            bundleListPrice += productListPrice;
            bundleDiscountedPrice += bundledProduct.price[0].bundledComponentPrice;
			bundledProduct.bundleComponentIsOptional = product.ccrz__Optional__c;
            bundledproduct.bundleComponentDescription = product.ccrz__Description__c;
            bundledProductList.add(bundledProduct);
            System.debug('Bundled Product Name ' + bundledProduct.productName);
            System.debug('Bundled Product List Price ' + productListPrice);
            System.debug('Bundled Product Discounted Price ' + bundledProduct.price[0].bundledComponentPrice);
        }
        System.debug('Bundle Product ID ' + productId);
        System.debug('Bundle Discounted price ' + bundleDiscountedPrice);
        System.debug('Bundle list price ' + bundleListPrice);
     //   productBundle.bundledProducts = bundledProductList;
        productBundle.bundleListPrice = bundleListPrice;
        productBundle.bundleDiscountedPrice = bundleDiscountedPrice;
        if (bundleListPrice != 0) {
            productBundle.bundleSavingsPercentage = ((bundleListPrice - bundleDiscountedPrice)/bundleListPrice) * 100;        
        }
        return productBundle;        
    }
    
   
    global static List<CSSProductModel> getBundledComponents(String productId) {
        List<CSSProductModel> bundledProductList = new list<CSSProductModel>();
        try {            
            List<ccrz__E_CompositeProduct__c> productList = [select ccrz__Optional__c,ccrz__Description__c,ccrz__Composite__r.id,ccrz__Component__r.id from ccrz__E_CompositeProduct__c where ccrz__Composite__r.id = :productId];
            System.debug('retrieved product list ' + productId);

            for (ccrz__E_CompositeProduct__c product :productList) {
                String bundledComponentId = product.ccrz__Component__r.id;
                //SSProductHelper productHelper = new SSProductHelper();
                CSSProductModel bundledProduct = CSSProductHelper.getProductInfo(bundledComponentId, null);
                System.debug('Bundled component name ' + bundledProduct.productName);
                bundledProduct.bundleComponentIsOptional = product.ccrz__Optional__c;
                bundledProductList.add(bundledProduct);
            }
        }
        catch (Exception ex) {}
        
        return bundledProductList;        
    }
    
    
  

    /*
     * @description Method to fetch Bundled Component Coupon by bundleProductId and bundleComponentId
     * @param       bundleProductId         SFID for the Bundle Product
     * @param       bundleComponentId       SFID for the Bundle Component
     * @return      Returns the data populated in a Map
     */ 
    global static Map<String, String> getBundledComponentCoupon(String bundleProductId, String bundleComponentId) {
        Map<String, String> coupon = null;
        system.debug('---------bundleProductId--------------'+bundleProductId);
        system.debug('---------bundleComponentId--------------'+bundleComponentId);
        List<ccrz__E_Coupon__c> couponList = [select id, name, ccrz__CouponCode__c, ccrz__CouponId__c, ccrz__CouponName__c, ccrz__CouponType__c, ccrz__DiscountAmount__c from ccrz__E_Coupon__c where ccrz__SourceProduct__c =:bundleProductId and ccrz__TargetProduct__c =:bundleComponentId];
        if (couponList.size() > 0) {
            coupon = new Map<String, String>(); 
            coupon.put('couponType', couponList[0].ccrz__CouponType__c);
            coupon.put('discountAmount', String.valueOf(couponList[0].ccrz__DiscountAmount__c));            
        }
        return coupon;        
    }
         
          /*
     * @description Method to fetch Tiered PricingInfo by priceListItemId,tierAttribute,productTier and subProdTermList
     * @param       priceListItemId         SFID for the PriceListItem
     * @param       tierAttribute           Tier Attribute 
     * @param       productTier             Map of Product Tiers
     * @param       subProdTermList         List Of Map of Product subProdTerm
     * @return      Returns the data populated in a Custom Model class with the Pricing Object Tier info
     
      
     */ 
        global static List<CSSPriceTierModel> getTierdPricingInfo(String priceListItemId, String tierAttribute, 
        Map<String,String> productTier) {
        
        //example : Map will Only have one Key / Value Pair
        //Map<string,String> productTier = new Map<String,String>();
        //productTier.put('tierQuantity','4');      
        //SSconstants.MAX_QUANITY = 9999
        
        System.debug('getTierPricingInfo: priceListItemId ' + priceListItemId);
        
        List<CSSPriceTierModel> pricingTierList = new List<CSSPriceTierModel>();
        List<Decimal> lstTierPrice= new List<Decimal>();
        Decimal minQuantity = 0;
        Integer Count = 0;
        Integer lstCounter= -1;
        Decimal deafultTierQuantity = 0;
        
        List< ccrz__E_PriceListItem__c> lstPriceLstItem = [Select id,ccrz__Price__c,ccrz__PricingTiers__c from ccrz__E_PriceListItem__c 
             where id =:priceListItemId ];
        string strPricingTierJSON = lstPriceLstItem[0].ccrz__PricingTiers__c;
        
        system.debug(' Product Tier JSON '+ strPricingTierJSON);
        
        if(strPricingTierJSON == null)
        return pricingTierList;
        
        
        Map<String, Object> mapProdTiers = (Map<String, Object>)JSON.deserializeUntyped(strPricingTierJSON);
        system.debug(' mapProdTier '+ mapProdTiers);
        List<Object>  lstPTier=(List<Object>)mapProdTiers.get('tiers');
        system.debug(' lstPTier '+ lstPTier);
        
        
        for(Object obj : lstPTier)
        {
            Map<String, Object> mapProdTier = (Map<String, Object>)obj;
            system.debug('>>>>> mapProdTiers '+mapProdTier);
            system.debug('>>>>> PRICE '+mapProdTier.get('p'));
            system.debug('>>>>> QUANTITY '+mapProdTier.get('q'));
            
            CSSPriceTierModel objTierModel = new CSSPriceTierModel();
            Decimal maxQuantity = (Decimal)mapProdTier.get('q');
           
            lstTierPrice.add((Decimal)mapProdTier.get('p'));
            system.debug('lstTierPrice'+lstTierPrice);
            
            system.debug('>>>> MAP SIZE '+productTier);
            
            //system.debug('>>>> MAP SIZE '+productTier.get('tierQuantity'));
            
            //String sTierQuantity = productTier != null?(String)productTier.get('tierquantity'):String.Valueof(SSconstants.MAX_QUANITY);
            if(productTier != null)
            deafultTierQuantity = Decimal.valueOf(productTier.get('tierQuantity'));
            
            system.debug('>>>> MAP SIZE '+deafultTierQuantity);
            
            objTierModel.minQuantity = minQuantity ;
            objTierModel.maxQuantity  = maxQuantity - 1;
            objTierModel.listPrice  = 
            Count == 0? lstPriceLstItem[0].ccrz__Price__c :lstTierPrice.get(lstCounter);
            objTierModel.tierDescription = objTierModel.minQuantity + '-' + objTierModel.maxQuantity ;
            
            if(productTier == null)           
            pricingTierList.add(objTierModel);
            
            if(deafultTierQuantity != 0 && productTier != null)
            {   
                system.debug('>>>> RANGE'+deafultTierQuantity);
                system.debug('>>>> MIN RANGE'+objTierModel.minQuantity);
                system.debug('>>>> MAX RANGE'+objTierModel.maxQuantity);
                
                if(objTierModel.minQuantity <= deafultTierQuantity && 
                  objTierModel.maxQuantity >= deafultTierQuantity)
                { 
                    system.debug('>>>> B/W THE RANGE '+deafultTierQuantity);
                    pricingTierList.add(objTierModel);
                    break;
                }
                
            }
            
            Count++;
            lstCounter++;
            minQuantity = maxQuantity;  
            
             system.debug('>>>> RANGEEEEE'+deafultTierQuantity);
             system.debug('>>>> MIN RANGE'+objTierModel.minQuantity);
             system.debug('>>>> MAX RANGE'+objTierModel.maxQuantity);
               
               
            if(lstPTier.Size() - lstCounter == 1 )//&&
            //objTierModel.minQuantity <= Decimal.Valueof(sTierQuantity) && 
            //SSconstants.MAX_QUANITY >= Decimal.Valueof(sTierQuantity))//For the Final Tier
            {
                CSSPriceTierModel objLastTierModel = new CSSPriceTierModel();
                objLastTierModel.minQuantity = (Decimal)mapProdTier.get('q');
                //objLastTierModel.maxQuantity  = SSconstants.MAX_QUANITY;
                objLastTierModel.listPrice  = (Decimal)mapProdTier.get('p');
                //objLastTierModel.tierDescription = objLastTierModel.minQuantity + '-' + objLastTierModel.maxQuantity ;
                objLastTierModel.tierDescription = objLastTierModel.minQuantity + '+' ;//+ ' To Max' ;
                       
                pricingTierList.add(objLastTierModel);
            }
        }
        
      system.debug(' Final List JSON '+ JSON.serialize(pricingTierList));
      system.debug(' Final List '+ pricingTierList);

      return pricingTierList;
     
     
     }
     
     /*
     * @description Method to fetch DiscountedPrice by discountType,discountAmount and listPrice
     * @param       discountType        The type of Discount like Percentage, Absolute etc
     * @param       discountAmount      Discount Amount
     * @param       listPrice           List Price
     * @return      Returns the newly calculated discountAmount
     */ 
    global static Double getDiscountedPrice(String discountType, Double discountAmount, Double listPrice) {
        if ((discountType != null) && (discountType.equals('Absolute'))) {
            return listPrice - discountAmount;
        }
        else if (discountType.equals('Percentage')) {
            return (listPrice - (listPrice * (discountAmount/100)));
        }
        //else {
         //   return discountAmount;
       // }
        //
        return discountAmount;
    }
    
    global static List<CSSProductModel> getRelatedProducts(String productSKU , String relationType) {
        List<CSSProductModel> relatedProductsList = new List<CSSProductModel>();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c 
        where ccrz__Product__r.ccrz__SKU__c = :productSKU and ccrz__RelatedProductType__c =: relationType];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            relatedProductsList.add(getProductInfo(relatedProduct.ccrz__RelatedProduct__r.id , null));
        }
        return relatedProductsList;
    }
    
       global static List<CSSProductModel> getAddOnProducts(String productId) {
        List<CSSProductModel> addOnProductList = new List<CSSProductModel>();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'Add-On'];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            addOnProductList.add(getProductInfo(relatedProduct.ccrz__RelatedProduct__r.id , null));
        }
        return addOnProductList;
    } 
    
     global static List<CSSProductModel> getMaintainanceProducts(String productId) {
        List<CSSProductModel>maintenanceProductList = new List<CSSProductModel>();
        List<ccrz__E_RelatedProduct__c> relatedProductList = [select ccrz__RelatedProduct__r.name,ccrz__RelatedProduct__r.ccrz__ProductType__c,ccrz__RelatedProduct__r.id,ccrz__RelatedProduct__r.ccrz__SKU__c from ccrz__E_RelatedProduct__c where ccrz__Product__c = :productId and ccrz__RelatedProductType__c = 'Maintenance'];
        for (ccrz__E_RelatedProduct__c relatedProduct: relatedProductList) {
            maintenanceProductList.add(getProductInfo(relatedProduct.ccrz__RelatedProduct__r.id , null));
        }
        return maintenanceProductList;
    } 
    
    /*
     * @description Method to fetch Tiered PricingInfo by priceListItemId,tierAttribute,productTier and subProdTermList
     * @param       priceListItemId         SFID for the PriceListItem
     * @param       tierAttribute           Tier Attribute 
     * @param       productTier             Map of Product Tiers
     * @param       subProdTermList         List Of Map of Product subProdTerm
     * @return      Returns the data populated in a Custom Model class with the Pricing Object Tier info
     */ 
    global static List<CSSPriceModel> getAttributePricingInfo(String priceListItemId, String productId) {
        System.debug('getTierPricingInfo: priceListItemId ' + priceListItemId);
        List<CSSPriceModel> priceListItems = new List<CSSPriceModel>();
        
        
        List<ccrz__E_PriceListItem__c> lstAttrPricing = [SELECT Id, Name, ccrz__Pricelist__c, ccrz__AttributePricing__c, ccrz__StartDate__c, ccrz__EndDate__c, ccrz__MaxQty__c, ccrz__Price__c, ccrz__SubProdTerm__c, ccrz__ItemType__c, ccrz__PricelistItemId__c, ccrz__PricingTiers__c, ccrz__Product__c FROM ccrz__E_PriceListItem__c where id =: priceListItemId and ccrz__Product__c =:productId limit 1];
        if (lstAttrPricing.size()>0) {
        
            system.debug('lstAttrPricing'+lstAttrPricing[0].ccrz__AttributePricing__c);
            
            
            for(ccrz__E_PriceListItem__c priceListItem : lstAttrPricing)
            {
              
              CSSPriceModel price = new CSSPriceModel();
              price.attributePricing = priceListItem.ccrz__AttributePricing__c;  // JSON Type
              price.productName = priceListItem.ccrz__Product__r.name;
              System.debug('Product Name ' + price.productName + '-' + productId);
              price.startDate = priceListItem.ccrz__StartDate__c;
              price.endDate = priceListItem.ccrz__EndDate__c;
              price.currencyCode = priceListItem.ccrz__Pricelist__r.ccrz__CurrencyISOCode__c;
              //price.listID  = priceListItem.ccrz__Pricelist__r.id; 
              //price.listItemID  = priceListItem.id; 
              //price.listName  = priceListItem.ccrz__Pricelist__r.name;
             //price.listPrice  = priceListItem.ccrz__Price__c; 
              price.minQuantity  = priceListItem.ccrz__MinQty__c;
              price.maxQuantity  = priceListItem.ccrz__MaxQty__c;
              price.recurringPrice  = priceListItem.ccrz__RecurringPrice__c;
              
              priceListItems.add(price);
    
            }
        }                      
            
        return priceListItems;
    }
    
    global Static Boolean isTrial (String productsku) {
        Boolean isTrial = false;
         list<ccrz__E_Product__c> plst = [Select Id,Is_Trial_Product__c,ccrz__SKU__c,Trial_Period_in_Days__c from ccrz__E_Product__c where ccrz__SKU__c=:productSku and Is_Trial_Product__c = true];
        if(plst.size()>0){
            isTrial = true;
        } 
        return isTrial;   
    } 
    
    global Static String adcAttributeSFID (String strAttributeId) {
        
        String sfid = '';
         
        list<ccrz__E_Attribute__c> plst = [Select Id,ccrz__DisplayName__c from ccrz__E_Attribute__c where ccrz__AttributeID__c =: strAttributeId Limit 1];
        if(plst.size()>0){
            sfid = plst[0].Id;
        } 
        return sfid;   
    }  
    
    
    global Static CSSProductPriceModel fetchProductPriceDetails(string strProductSKU,string strTermType)
    {
        CSSProductPriceModel productPrice = new CSSProductPriceModel();
        Map<String, Object> objProductInfoMap = new Map<String, Object>();

        //Anonymous context shouldn't be defaulted for getting the price information
        SSContext ecommContext = new SSContext();        
        ccrz.ccContext ctx = ecommContext.getCCContextForAnonymousUser() ;         
        Map<String,Object> ccMap = ecommContext.getCCApiVersion();
         
        CSSProductModel ProductSKU = CSSProductHelper.getProductInfoBySKU(strProductSKU);
        
        system.debug('PRODUCT SFDC ID '+ ProductSKU.productId);        
        system.debug('PRODUCT strTermType '+ strTermType);
       
        objProductInfoMap = ccrz.ccAPIProduct.fetch(new Map<String, Object>{
            ccrz.ccApi.API_VERSION => ccMap.get(ccrz.ccApi.API_VERSION),
            ccrz.ccAPIProduct.PARAM_INCLUDE_PRICING => TRUE,
            ccrz.ccApiProduct.PARAM_INCLUDE_SELLERS => TRUE,
            ccrz.ccAPIProduct.PRODUCTID => ProductSKU.productId
        });
        
		System.debug('calling api addResults JSON Class : SSProductHelper' + json.serialize(objProductInfoMap));
        Boolean wasSuccessful = (Boolean) objProductInfoMap.get(ccrz.ccApi.SUCCESS);  
            
        System.debug('calling api addResults Class : SSProductHelper' + wasSuccessful);
            
		if(strTermType != null)
        {
            //Below Code give the best price If Product has SPTs and A Term Type (Monthly/Weekly/Daily/Yearly etc) Provided
        	Map<String, Object> mapSptByProd = (Map<String, Object>)objProductInfoMap.get('sptByProdId');                
            if(mapSptByProd != null){
                string strselSubProdTerm;
                system.debug(' mapSptByProd '+ mapSptByProd);
                List<Map<String, Object>> lstOfBestSptPrice = (List<Map<String, Object>>)mapSptByProd.get(ProductSKU.productId);
                system.debug(' mapOfBestSptPrice '+ lstOfBestSptPrice);
                Map<String, Object> mapPricingData = (Map<String, Object>)objProductInfoMap.get(ccrz.ccAPIProduct.PRODUCTPRICINGDATA);
                system.debug(' mapPricingData '+ mapPricingData);
                Map<String, Object> mapBestPrice = (Map<String, Object>)mapPricingData.get(ProductSKU.productId);
                Decimal minProdPrice = (Decimal)mapBestPrice.get('minSubPrice');
                Map<String, Object> subProductTerms = (Map<String, Object>)mapBestPrice.get('subProductTerms'); 
                system.debug('subProductTerms'+ subProductTerms);
                
                if(lstOfBestSptPrice != null) {
	                for(Map<String,Object> lst : lstOfBestSptPrice)
    	            {
        	            system.debug('>>>>>'+(Decimal)lst.get('productPrice'));
            	        system.debug('>>>>>'+(String)lst.get('installmentFrequencyUOM'));
                    
                	    if(strTermType.equalsIgnoreCase((String)lst.get('installmentFrequencyUOM')) && (Decimal)lst.get('productPrice') == (Decimal)mapBestPrice.get('minSubPrice'))
                    	{
                            System.debug('installmentFrequencyUOM  - Class : SSProductHelper ' + lst.get('installmentFrequencyUOM'));
                            System.debug('productPrice - Class : SSProductHelper ' + lst.get('productPrice'));
                            System.debug('subscriptionPrice - Class : SSProductHelper ' + lst.get('subscriptionPrice'));
                            
                            productPrice.bestPrice = (Decimal)lst.get('productPrice');                            
                            strselSubProdTerm = (string)lst.get('sfid');
	                    }
	                    else if(strTermType.equalsIgnoreCase((String)lst.get('installmentFrequencyUOM')))
    	                {
        	                System.debug('installmentFrequencyUOM  - Class : SSProductHelper ' + lst.get('installmentFrequencyUOM'));
            	            System.debug('productPrice - Class : SSProductHelper ' + lst.get('productPrice'));
                	        System.debug('subscriptionPrice - Class : SSProductHelper ' + lst.get('subscriptionPrice'));
                        
                    	    productPrice.bestPrice = (Decimal)lst.get('productPrice');                        
	                        strselSubProdTerm = (string)lst.get('sfid');
    	                }
        	        }
                
                
                	Map<String, Object> selSubProductTerms = (Map<String, Object>)subProductTerms.get(strselSubProdTerm); 
                    system.debug('selSubProductTerms'+ selSubProductTerms);
                
               	 	Map<String, Object> selPriceListItemId = (Map<String, Object>)selSubProductTerms.get('nonRecurringPrice');
                	system.debug('selPriceListItemId'+ selPriceListItemId);
                	productPrice.priceListItemID  = (string)selPriceListItemId.get('sfid');
                }        
              }  
            }
            else
            {
                // No SPTs
                Map<String, Object> mapPricingData = (Map<String, Object>)objProductInfoMap.get(ccrz.ccAPIProduct.PRODUCTPRICINGDATA);
                system.debug(' mapPricingData '+ mapPricingData);
                Map<String, Object> mapBestPrice = (Map<String, Object>)mapPricingData.get(ProductSKU.productId);
                system.debug(' mapBestPrice '+ mapBestPrice);
                Map<String,Object> mapBestProdPrice = (Map<String,Object>)mapBestPrice.get('productPrice');
                Map<String,Object> mapBestProdBasePrice = (Map<String,Object>)mapBestPrice.get('basePrice');
                
                productPrice.bestPrice = (Decimal)mapBestProdPrice.get('price');
                productPrice.savingPrice = (Decimal)mapBestPrice.get('savings');
                if(mapBestProdBasePrice != null)
                {
                    productPrice.basePrice = (Decimal)mapBestProdBasePrice.get('price');
                    productPrice.priceListItemID  = (string)mapBestProdBasePrice.get('sfid');
                }
                if(mapBestProdPrice != null)
                {
                    productPrice.priceListItemID  = (string)mapBestProdPrice.get('sfid');
                }
                     
                system.debug(' mapPricingData '+ mapPricingData);
            }
            
            
        return productPrice;
     }
}