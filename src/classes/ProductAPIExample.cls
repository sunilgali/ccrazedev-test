/** 
 * Created by Joshua Feingold on 6/15/16. 
 * 
 * This is a series of examples for how to use the SteelBrick CPQ Product API. 
 */ 
@isTest 
private class ProductAPIExample { 
 
 
    private class ProductModel { 
        public Product2 record; 
        public String currencyCode; 
    } 
 
    private class QuoteModel { 
        public SBQQ__Quote__c record; 
    } 
 
    private static Product2 generic1; 
    private static Product2 pot36; 
    private static Product2 fp36; 
    private static Product2 pot24; 
    private static Product2 fp24; 
    private static Product2 blockPriced1; 
    private static Integer productCount; 
 
    private static PricebookEntry[] entries; 
 
    private static SBQQ__SearchFilter__c codeFilter; 
    private static SBQQ__SearchFilter__c nameFilter; 
    private static SBQQ__SearchFilter__c termFilter; 
    private static SBQQ__SearchFilter__c methodFilter; 
 
    private static SBQQ__QuoteProcess__c qprocess; 
    private static SBQQ__ProcessInput__c pinput; 
 
 
    private static void setUpProductsAndPrices() { 
        generic1 = new Product2(Name='MyProduct',IsActive=true); 
        pot36 = new Product2(Name='PoTProduct-36', IsActive=true, ProductCode='POT-PRO-36', SBQQ__PricingMethod__c='List', SBQQ__SubscriptionPricing__c='Percent Of Total', SBQQ__SubscriptionTerm__c=36); 
        fp36 = new Product2(Name='FixedPrice-36', IsActive=true, ProductCode='FP-36', SBQQ__PricingMethod__c='List', SBQQ__SubscriptionPricing__c='Fixed Price', SBQQ__SubscriptionTerm__c=36); 
        pot24 = new Product2(Name='PoTProduct-24', IsActive=true, ProductCode='POT-PRO-24', SBQQ__PricingMethod__c='Percent of Total', SBQQ__SubscriptionPricing__c='Percent Of Total', SBQQ__SubscriptionTerm__c=24); 
        fp24 = new Product2(Name='FixedPrice-24', IsActive=true, ProductCode='FP-24', SBQQ__PricingMethod__c='List', SBQQ__SubscriptionPricing__c='Fixed Price', SBQQ__SubscriptionTerm__c=24); 
        blockpriced1 = new Product2(Name='BlockPriced1', IsActive=true, ProductCode='BLOCKPRICE-1', SBQQ__PricingMethod__c='Block'); 
 
        Product2[] ps = new Product2[]{generic1, pot36, fp36, pot24, fp24, blockpriced1}; 
        productCount = ps.size(); 
        insert ps; 
 
        entries = new PricebookEntry[0]; 
        entries.add(new PricebookEntry(Product2Id=generic1.Id,UnitPrice=1000,IsActive=true,Pricebook2Id=Test.getStandardPricebookId())); 
        entries.add(new PricebookEntry(Product2Id=pot36.Id,UnitPrice=0,IsActive=true,Pricebook2Id=Test.getStandardPricebookId())); 
        entries.add(new PricebookEntry(Product2Id=fp36.Id,UnitPrice=2000,IsActive=true,Pricebook2Id=Test.getStandardPricebookId())); 
        entries.add(new PricebookEntry(Product2Id=pot24.Id,UnitPrice=0,IsActive=true,Pricebook2Id=Test.getStandardPricebookId())); 
        entries.add(new PricebookEntry(Product2Id=fp24.Id,UnitPrice=4000,IsActive=true,Pricebook2Id=Test.getStandardPricebookId())); 
        entries.add(new PricebookEntry(Product2Id=blockpriced1.Id,UnitPrice=5000,IsActive=true,Pricebook2Id=Test.getStandardPricebookId())); 
        insert entries; 
    } 
 
    private static void setUpSearchFilters() { 
        codeFilter = new SBQQ__SearchFilter__c(SBQQ__TargetObject__c = 'Product', SBQQ__TargetField__c = 'Product Code'); 
        nameFilter = new SBQQ__SearchFilter__c(SBQQ__TargetObject__c = 'Product', SBQQ__TargetField__c = 'Name'); 
        termFilter = new SBQQ__SearchFilter__c(SBQQ__TargetObject__c = 'Product', SBQQ__TargetField__c = String.valueOf(Product2.SBQQ__SubscriptionTerm__c)); 
        methodFilter = new SBQQ__SearchFilter__c(SBQQ__TargetObject__c = 'Product', SBQQ__TargetField__c = String.valueOf(Product2.SBQQ__PricingMethod__c)); 
    } 
 
    private static void setUpQuoteProcess() { 
        qprocess = new SBQQ__QuoteProcess__c(Name='Test'); 
        insert qprocess; 
 
        pinput = new SBQQ__ProcessInput__c(SBQQ__QuoteProcess__c=qprocess.Id, SBQQ__Active__c = true, Name = 'Test'); 
        pinput.SBQQ__InputField__c = String.valueOf(SBQQ__ProcessInput__c.SBQQ__IntegerInput__c); 
        pinput.SBQQ__Operator__c = 'equals'; 
        pinput.SBQQ__ProductField__c = String.valueOf(Product2.SBQQ__SubscriptionTerm__c); 
        insert pinput; 
    } 
 
 
    private class ProductLoadContext { 
        public Id pricebookId; 
        public String currencyCode; 
    } 
 
    testMethod static void productLoadExample() { 
        setUpProductsAndPrices(); 
 
        ProductLoadContext plc = new ProductLoadContext(); 
        plc.pricebookId = Test.getStandardPricebookId(); 
 
        Test.startTest(); 
        String productJson = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductLoader', generic1.Id, JSON.serialize(plc)); 
        ProductModel pmodel = (ProductModel)JSON.deserialize(productJson, ProductModel.class); 
        Test.stopTest(); 
 
        System.assert(pmodel != null); 
        System.assertEquals(generic1.Id, pmodel.record.Id); 
    } 
 
    private class SearchContext { 
        public String format; 
        public QuoteModel quote; 
        public SBQQ__SearchFilter__c[] filters; 
    } 
 
    testMethod static void productSearchNoFilterExampleReturnsPricebookEntries() { 
        setUpProductsAndPrices(); 
 
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(SBQQ__PricebookId__c = Test.getStandardPricebookId()); 
        QuoteModel qmodel = new QuoteModel(); 
        qmodel.record = quoteRec; 
 
        SearchContext context = new SearchContext(); 
        context.quote = qmodel; 
        context.filters = new SBQQ__SearchFilter__c[0]; 
 
        Test.startTest(); 
        String pricebookJsons = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductSearcher', null, JSON.serialize(context)); 
        PricebookEntry[] resultEntries = (PricebookEntry[])JSON.deserialize(pricebookJsons, PricebookEntry[].class); 
        Test.stopTest(); 
 
        System.assert(!resultEntries.isEmpty()); 
        System.assertEquals(productCount, resultEntries.size(), 'Should have returned everything'); 
    } 
 
    testMethod static void productSearchNoFilterExampleReturnsProductModels() { 
        setUpProductsAndPrices(); 
 
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(SBQQ__PricebookId__c = Test.getStandardPricebookId()); 
        QuoteModel qmodel = new QuoteModel(); 
        qmodel.record = quoteRec; 
 
        SearchContext context = new SearchContext(); 
        context.quote = qmodel; 
        context.filters = new SBQQ__SearchFilter__c[0]; 
        context.format = 'products'; 
 
        Test.startTest(); 
        String productJsons = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductSearcher', null, JSON.serialize(context)); 
        ProductModel[] resultModels = (ProductModel[])JSON.deserialize(productJsons, ProductModel[].class); 
        Test.stopTest(); 
 
        System.assert(!resultModels.isEmpty()); 
        System.assertEquals(productCount, resultModels.size(), 'Should have returned everything'); 
    } 
 
    testMethod static void productSearchExampleFilterByProductCode() { 
        setUpProductsAndPrices(); 
        setUpSearchFilters(); 
 
        codeFilter.SBQQ__Operator__c = 'contains'; 
        codeFilter.SBQQ__FilterValue__c = 'O'; 
        SBQQ__SearchFilter__c[] filters = new SBQQ__SearchFilter__c[]{codeFilter}; 
 
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(SBQQ__PricebookId__c = Test.getStandardPricebookId()); 
        QuoteModel qmodel = new QuoteModel(); 
        qmodel.record = quoteRec; 
 
        SearchContext context = new SearchContext(); 
        context.filters = filters; 
        context.quote = qmodel; 
 
        Test.startTest(); 
        String priceJsons = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductSearcher', null, JSON.serialize(context)); 
        PricebookEntry[] resultModels = (PricebookEntry[])JSON.deserialize(priceJsons, PricebookEntry[].class); 
        Test.stopTest(); 
        System.assert(!resultModels.isEmpty()); 
        System.assertEquals(3, resultModels.size(), 'Should have returend the 3 products with an O in the code'); 
    } 
 
    testMethod static void productSearchExampleUsingMultipleFilters() { 
        setUpProductsAndPrices(); 
        setUpSearchFilters(); 
 
        codeFilter.SBQQ__Operator__c = 'starts with'; 
        codeFilter.SBQQ__FilterValue__c = 'POT'; 
 
        termFilter.SBQQ__Operator__c = 'equals'; 
        termFilter.SBQQ__FilterValue__c = '36'; 
 
        SBQQ__SearchFilter__c[] filters = new SBQQ__SearchFilter__c[]{codeFilter, termFilter}; 
 
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(SBQQ__PricebookId__c = Test.getStandardPricebookId()); 
        QuoteModel qmodel = new QuoteModel(); 
        qmodel.record = quoteRec; 
 
        SearchContext context = new SearchContext(); 
        context.filters = filters; 
        context.quote = qmodel; 
 
        Test.startTest(); 
        String priceJsons = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductSearcher', null, JSON.serialize(context)); 
        PricebookEntry[] resultModels = (PricebookEntry[])JSON.deserialize(priceJsons, PricebookEntry[].class); 
        Test.stopTest(); 
        System.assert(!resultModels.isEmpty()); 
        System.assertEquals(1, resultModels.size(), 'Should return the 1 product with POT in the code and term = 36'); 
    } 
 
 
    private class SuggestContext { 
        public String format; 
        public QuoteModel quote; 
        public SBQQ__QuoteProcess__c process; 
    } 
 
 
    testMethod static void productSuggestExampleEmptyProcessReturnsAllRecords() { 
        setUpProductsAndPrices(); 
 
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(SBQQ__PricebookId__c = Test.getStandardPricebookId()); 
        insert quoteRec; 
        QuoteModel qmodel = new QuoteModel(); 
        qmodel.record = quoteRec; 
 
        SuggestContext context = new SuggestContext(); 
        context.quote = qmodel; 
 
        //SBQQ__QuoteProcess__c qp = new QuoteProcess__c(); 
        //context.process = qp; 
 
        Test.startTest(); 
        String priceJsons = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductSuggester', null, JSON.serialize(context)); 
        PricebookEntry[] resultModels = (PricebookEntry[])JSON.deserialize(priceJsons, PricebookEntry[].class); 
        Test.stopTest(); 
        System.assert(!resultModels.isEmpty()); 
        System.assertEquals(productCount, resultModels.size(), 'Should return everything'); 
    } 
 
    testMethod static void productSuggestExampleReturnsProductsWith36MonthTerm() { 
        setUpProductsAndPrices(); 
 
        setUpQuoteProcess(); 
 
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c(SBQQ__PricebookId__c = Test.getStandardPricebookId()); 
        insert quoteRec; 
        QuoteModel qmodel = new QuoteModel(); 
        qmodel.record = quoteRec; 
 
        SBQQ__QuoteProcess__c qp = [SELECT Id, SBQQ__ProductAutoSelected__c, SBQQ__GuidedOnly__c, 
        (SELECT SBQQ__QuoteProcess__c, Id, Name, SBQQ__Active__c, SBQQ__DisplayOrder__c, SBQQ__InputField__c, SBQQ__Operator__c, SBQQ__ProductField__c, SBQQ__IntegerInput__c FROM SBQQ__Inputs__r) 
        FROM SBQQ__QuoteProcess__c WHERE Id =: qprocess.Id 
        ]; 
        qp.SBQQ__Inputs__r[0].SBQQ__IntegerInput__c = 36; 
        SuggestContext context = new SuggestContext(); 
        context.quote = qmodel; 
        context.process = qp; 
 
        Test.startTest(); 
        String priceJsons = SBQQ.ServiceRouter.load('ProductAPI.ProductSuggester', null, JSON.serialize(context)); 
        PricebookEntry[] resultModels = (PricebookEntry[])JSON.deserialize(priceJsons, PricebookEntry[].class); 
        Test.stopTest(); 
 
        System.assert(!resultModels.isEmpty()); 
        System.assertEquals(2, resultModels.size(), 'Should return the 2 entries with terms of 36'); 
    } 
}