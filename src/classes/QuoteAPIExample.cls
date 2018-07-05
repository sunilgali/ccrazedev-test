/** 
 * Created by Joshua Feingold on 6/15/16. 
 * 
 * This is a series of examples showing how to use the SteelBrick CPQ Quote API. 
 */ 
@isTest 
private class QuoteAPIExample { 
 
    private class QuoteModel { 
        public SBQQ__Quote__c record; 
        public QuoteLineModel[] lineItems; 
        public QuoteLineGroupModel[] lineItemGroups; 
 
        public Integer nextKey; 
        public Boolean applyAdditionalDiscountLast; 
        public Boolean applyPartnerDiscountFirst; 
        public Boolean channelDiscountsOffList; 
        public Decimal customerTotal; 
        public Decimal netTotal; 
        public Decimal netNonSegmentTotal; 
    } 
 
    private class QuoteLineModel { 
        public SBQQ__QuoteLine__c record; 
 
        public Boolean amountDiscountProrated; 
        public Integer parentGroupKey; 
        public Integer parentItemKey; 
        public Integer key; 
        public Boolean upliftable; 
        public String configurationType; 
        public String configurationEvent; 
        public Boolean reconfigurationDisabled; 
        public Boolean descriptionLocked; 
        public Boolean productQuantityEditable; 
        public Decimal productQuantityScale; 
        public String dimensionType; 
        public Boolean productHasDimensions; 
        public Decimal targetCustomerAmount; 
        public Decimal targetCustomerTotal; 
    } 
 
    private class QuoteLineGroupModel { 
        public SBQQ__QuoteLineGroup__c record; 
 
        public Decimal netNonSegmentTotal; 
        public Integer key; 
    } 
 
    private class ProductModel { 
        public Product2 record; 
        public String currencyCode; 
    } 
 
    private static Account customer; 
    private static Opportunity opp; 
    private static SBQQ__Quote__c quoteRec; 
    private static List<Product2> sampleProducts; 
    private static List<PricebookEntry> entries; 
    private static List<SBQQ__ProductOption__c> prodOptions; 
    private static List<SBQQ__QuoteLine__c> lines; 
 
 
    private static void setUpQuote() { 
        customer = new Account(Name='Customer'); 
        insert customer; 
 
        opp = new Opportunity(AccountId = customer.Id, Name = 'Test', CloseDate = System.today().addMonths(12), StageName = 'Test', Pricebook2Id = Test.getStandardPricebookId()); 
        insert opp; 
 
        quoteRec = new SBQQ__Quote__c(SBQQ__Opportunity2__c = opp.Id, SBQQ__StartDate__c = System.today(), SBQQ__SubscriptionTerm__c = 12); 
        insert quoteRec; 
 
        sampleProducts = new List<Product2>{ 
                new Product2(Name = 'Bundle Parent', IsActive = true, SBQQ__AssetConversion__c = 'One per quote line'), 
                new Product2(Name = 'Subscription Child', IsActive = true, SBQQ__SubscriptionPricing__c = 'Percent Of Total', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable'), 
                new Product2(Name = 'Non-Subscription Child 1', IsActive = true, SBQQ__AssetConversion__c = 'One per quote line'), 
                new Product2(Name = 'Non-Subscription Child 2', IsActive = true, SBQQ__AssetConversion__c = 'One per quote line'), 
                new Product2(Name = 'Standalone', IsActive = true, SBQQ__AssetConversion__c = 'One per unit'), 
                new Product2(Name = 'Subscription Extra', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable') 
        }; 
        insert sampleProducts; 
 
        entries = new List<PricebookEntry>(); 
        entries.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = sampleProducts[0].Id, IsActive = true, UnitPrice = 100)); 
        entries.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = sampleProducts[1].Id, IsActive = true, UnitPrice = 200)); 
        entries.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = sampleProducts[2].Id, IsActive = true, UnitPrice = 100)); 
        entries.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = sampleProducts[3].Id, IsActive = true, UnitPrice = 100)); 
        entries.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = sampleProducts[4].Id, IsActive = true, UnitPrice = 100)); 
        entries.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = sampleProducts[5].Id, IsActive = true, UnitPrice = 100)); 
        insert entries; 
 
        prodOptions = new List<SBQQ__ProductOption__c>(); 
        // 3 bundle children 
        prodOptions.add(new SBQQ__ProductOption__c(SBQQ__Number__c = 20, SBQQ__ConfiguredSKU__c = sampleProducts[0].Id, SBQQ__Type__c = 'Component', SBQQ__OptionalSKU__c = sampleProducts[1].Id)); 
        prodOptions.add(new SBQQ__ProductOption__c(SBQQ__Number__c = 30, SBQQ__ConfiguredSKU__c = sampleProducts[0].Id, SBQQ__Type__c = 'Component', SBQQ__OptionalSKU__c = sampleProducts[2].Id)); 
        prodOptions.add(new SBQQ__ProductOption__c(SBQQ__Number__c = 40, SBQQ__ConfiguredSKU__c = sampleProducts[0].Id, SBQQ__Type__c = 'Component', SBQQ__OptionalSKU__c = sampleProducts[3].Id)); 
        insert prodOptions; 
 
        lines = new List<SBQQ__QuoteLine__c>(); 
        // Bundle 
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteRec.Id, SBQQ__Product__c = sampleProducts[0].Id, SBQQ__Quantity__c = 1, SBQQ__NetPrice__c = 100)); 
        // Subscription child 
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteRec.Id, SBQQ__Product__c = sampleProducts[1].Id, SBQQ__Quantity__c = 1, SBQQ__SubscriptionPricing__c = 'Percent Of Total', SBQQ__StartDate__c = System.today(), SBQQ__EndDate__c = System.today().addMonths(12).addDays(-1), SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__ListPrice__c = 200, SBQQ__NetPrice__c = 200)); 
        // Asset children 
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteRec.Id, SBQQ__Product__c = sampleProducts[2].Id, SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 200, SBQQ__NetPrice__c = 200)); 
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteRec.Id, SBQQ__Product__c = sampleProducts[3].Id, SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 200, SBQQ__NetPrice__c = 200)); 
        // Standalone 
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteRec.Id, SBQQ__Product__c = sampleProducts[4].Id, SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 200, SBQQ__NetPrice__c = 200)); 
        insert lines; 
 
        lines[0].SBQQ__Bundle__c = true; 
        lines[1].SBQQ__RequiredBy__c = lines[0].Id; 
        lines[2].SBQQ__RequiredBy__c = lines[0].Id; 
        lines[3].SBQQ__RequiredBy__c = lines[0].Id; 
        update lines; 
    } 
 
    testMethod static void loadQuoteByIdExample() { 
        setUpQuote(); 
        String qid = (String)quoteRec.Id; 
        Test.startTest(); 
        String qmodelJson = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', qid); 
        QuoteModel qmodel = (QuoteModel)JSON.deserialize(qmodelJson, QuoteModel.class); 
        Test.stopTest(); 
        System.assert(qmodel != null, 'Should have loaded something'); 
        System.assertEquals(quoteRec.Id, qmodel.record.get('Id'), 'Should have the same ID'); 
        System.assertEquals(5, qmodel.lineItems.size(), 'Should have 5 lines'); 
    } 
 
    private class ProductAddContext { 
        public Boolean ignoreCalculate; 
        public QuoteModel quote; 
        public ProductModel[] products; 
        public Integer groupKey; 
    } 
 
    private class ProductLoadContext { 
        public Id pricebookId; 
        public String currencyCode; 
    } 
 
    testMethod static void addQuoteLineExample() { 
        setUpQuote(); 
 
        ProductLoadContext plContext = new ProductLoadContext(); 
        plContext.pricebookId = Test.getStandardPricebookId(); 
 
        String newProductJson = SBQQ.ServiceRouter.load('SBQQ.ProductAPI.ProductLoader', sampleProducts[4].Id, JSON.serialize(plContext)); 
        ProductModel newProductModel = (ProductModel)JSON.deserialize(newProductJson, ProductModel.class); 
 
        String startingQuoteJson = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', quoteRec.Id); 
        QuoteModel startingQuoteModel = (QuoteModel)JSON.deserialize(startingQuoteJson, QuoteModel.class); 
 
        Decimal startingTotal = startingQuoteModel.netTotal; 
 
        ProductAddContext paContext = new ProductAddContext(); 
        paContext.quote = startingQuoteModel; 
        paContext.products = new List<ProductModel>{newProductModel}; 
        paContext.ignoreCalculate = false; 
 
        Test.startTest(); 
        String updatedQuoteJSON = SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteProductAdder', null, JSON.serialize(paContext)); 
        QuoteModel updatedQuoteModel = (QuoteModel)JSON.deserialize(updatedQuoteJSON, QuoteModel.class); 
        Test.stopTest(); 
 
        System.assertEquals(startingTotal + entries[4].UnitPrice, updatedQuoteModel.netTotal, 'New total should be increased by the unit price of the product we added'); 
    } 
 
    private class CalculatorContext { 
        public QuoteModel quote; 
    } 
 
    testMethod static void quoteCalculatorExample() { 
        setUpQuote(); 
 
        // STEP 1: LOAD THE QUOTE 
        String qid = (String)quoteRec.Id; 
        String startingQuoteJson = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', qid); 
        QuoteModel startingModel = (QuoteModel)JSON.deserialize(startingQuoteJson, QuoteModel.class); 
        Decimal startingTotal = startingModel.netTotal; 
 
        // STEP 2: CHANGE THE QUANTITIES TO INVALIDATE DATA 
        startingModel.lineItems[0].record.SBQQ__Quantity__c = 3; 
        startingModel.lineItems[1].record.SBQQ__Quantity__c = 3; 
        startingModel.lineItems[2].record.SBQQ__Quantity__c = 3; 
        startingModel.lineItems[3].record.SBQQ__Quantity__c = 3; 
        startingModel.lineItems[4].record.SBQQ__Quantity__c = 3; 
 
        // STEP 3: SET UP A CONTEXT 
        CalculatorContext context = new CalculatorContext(); 
        context.quote = startingModel; 
 
        // STEP 4: CALCULATE 
        Test.startTest(); 
        String resultJson = SBQQ.ServiceRouter.load('SBQQ.QuoteAPI.QuoteCalculator', null, JSON.serialize(context)); 
        QuoteModel resultModel = (QuoteModel)JSON.deserialize(resultJson, QuoteModel.class); 
        Test.stopTest(); 
 
        // STEP 5: TEST THAT TOTALS HAVE UPDATED 
        System.assert(resultModel != null); 
        System.assertEquals(startingTotal * 3, resultModel.netTotal, 'Since we multiplied all quantities by 3, the total should be multiplied by 3'); 
    } 
 
    testMethod static void quoteSaverExample() { 
        setUpQuote(); 
 
        // STEP 1: LOAD THE QUOTE 
        String qid = (String)quoteRec.Id; 
        String startingQuoteJson = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', qid); 
        QuoteModel startingModel = (QuoteModel)JSON.deserialize(startingQuoteJson, QuoteModel.class); 
        Decimal startingTotal = startingModel.netTotal; 
 
        // STEP 2: CHANGE THE QUANTITIES TO INVALIDATE DATA 
        startingModel.lineItems[0].record.SBQQ__Quantity__c = 3; 
        startingModel.lineItems[1].record.SBQQ__Quantity__c = 3; 
        startingModel.lineItems[2].record.SBQQ__Quantity__c = 3; 
        startingModel.lineItems[3].record.SBQQ__Quantity__c = 3; 
        startingModel.lineItems[4].record.SBQQ__Quantity__c = 3; 
 
        // STEP 3: SAVE 
        Test.startTest(); 
        String savedJson = SBQQ.ServiceRouter.save('SBQQ.QuoteAPI.QuoteSaver', JSON.serialize(startingModel)); 
        Test.stopTest(); 
 
        // STEP 4: REQUERY THE QUOTE 
        String updatedQuoteJson = SBQQ.ServiceRouter.read('SBQQ.QuoteAPI.QuoteReader', qid); 
        QuoteModel updatedQuoteModel = (QuoteModel)JSON.deserialize(updatedQuoteJson, QuoteModel.class); 
 
 
        // STEP 5: TEST THAT DATA PERSISTED 
        System.assertEquals(3, updatedQuoteModel.lineItems[0].record.SBQQ__Quantity__c); 
        System.assertEquals(3, updatedQuoteModel.lineItems[1].record.SBQQ__Quantity__c); 
        System.assertEquals(3, updatedQuoteModel.lineItems[2].record.SBQQ__Quantity__c); 
        System.assertEquals(3, updatedQuoteModel.lineItems[3].record.SBQQ__Quantity__c); 
        System.assertEquals(3, updatedQuoteModel.lineItems[4].record.SBQQ__Quantity__c); 
    } 
 
}