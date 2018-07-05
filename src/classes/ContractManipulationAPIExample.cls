/** 
 * Created by jfeingold on 6/15/16. 
 */ 
@isTest 
private class ContractManipulationAPIExample { 
 
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
 
    private static Account customer; 
    private static Opportunity opp; 
    private static SBQQ__Quote__c quote; 
    private static List<Product2> sampleProducts; 
    private static List<PricebookEntry> entries; 
    private static List<SBQQ__ProductOption__c> prodOptions; 
    private static List<SBQQ__QuoteLine__c> lines; 
    private static Contract c1; 
    private static SBQQ__Subscription__c sub; 
    private static Asset a0; 
    private static Asset a1; 
    private static Asset a2; 
    private static Asset a3; 
 
    private static void setUpContract() { 
        customer = new Account(Name='Customer'); 
        insert customer; 
 
        opp = new Opportunity(AccountId = customer.Id, Name = 'Test', CloseDate = System.today().addMonths(12), StageName = 'Test', Pricebook2Id = Test.getStandardPricebookId()); 
        insert opp; 
 
        quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c = opp.Id, SBQQ__StartDate__c = System.today(), SBQQ__SubscriptionTerm__c = 12); 
        insert quote; 
 
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
        prodOptions.add(new SBQQ__ProductOption__c(SBQQ__Number__c = 20, SBQQ__ConfiguredSKU__c = sampleProducts[1].Id, SBQQ__OptionalSKU__c = sampleProducts[0].Id)); 
        prodOptions.add(new SBQQ__ProductOption__c(SBQQ__Number__c = 30, SBQQ__ConfiguredSKU__c = sampleProducts[2].Id, SBQQ__OptionalSKU__c = sampleProducts[0].Id)); 
        prodOptions.add(new SBQQ__ProductOption__c(SBQQ__Number__c = 40, SBQQ__ConfiguredSKU__c = sampleProducts[3].Id, SBQQ__OptionalSKU__c = sampleProducts[0].Id)); 
        insert prodOptions; 
 
        lines = new List<SBQQ__QuoteLine__c>(); 
        // Bundle 
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = sampleProducts[0].Id, SBQQ__Quantity__c = 1, SBQQ__NetPrice__c = 100)); 
        // Subscription child 
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = sampleProducts[1].Id, SBQQ__Quantity__c = 1, SBQQ__SubscriptionPricing__c = 'Percent Of Total', SBQQ__StartDate__c = System.today(), SBQQ__EndDate__c = System.today().addMonths(12).addDays(-1), SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__ListPrice__c = 200, SBQQ__NetPrice__c = 200)); 
        // Asset children 
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = sampleProducts[2].Id, SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 200, SBQQ__NetPrice__c = 200)); 
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = sampleProducts[3].Id, SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 200, SBQQ__NetPrice__c = 200)); 
        // Standalone 
        lines.add(new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = sampleProducts[4].Id, SBQQ__Quantity__c = 1, SBQQ__ListPrice__c = 200, SBQQ__NetPrice__c = 200)); 
        insert lines; 
 
        lines[0].SBQQ__Bundle__c = true; 
        lines[1].SBQQ__RequiredBy__c = lines[0].Id; 
        lines[2].SBQQ__RequiredBy__c = lines[0].Id; 
        lines[3].SBQQ__RequiredBy__c = lines[0].Id; 
        update lines; 
 
        //c1 = new Contract(AccountId = customer.Id, StartDate = System.today(), ContractTerm = 12, Opportunity__c = opp.Id, SBQQ__PreserveBundleStructureUponRenewals__c = true); 
        //insert c1; 
 
        //sub = new Subscription__c(SBQQ__Contract__c = c1.Id, SBQQ__Product__c = sampleProducts[1].Id, SBQQ__CustomerPrice__c = 100, SBQQ__Quantity__c = 1, SBQQ__QuoteLine__c = lines[1].Id); 
        //insert sub; 
 
        a0 = new Asset(Name='Asset 1',AccountId=customer.Id,Product2Id=sampleProducts[0].Id,Price=100,Quantity=1, SBQQ__QuoteLine__c=lines[0].Id); 
        a1 = new Asset(Name='Asset 2',AccountId=customer.Id,Product2Id=sampleProducts[2].Id,Price=100,Quantity=1, SBQQ__QuoteLine__c=lines[2].Id); 
        a2 = new Asset(Name='Asset 3',AccountId=customer.Id,Product2Id=sampleProducts[3].Id,Price=100,Quantity=1, SBQQ__QuoteLine__c=lines[3].Id); 
        a3 = new Asset(Name='Asset 4',AccountId=customer.Id,Product2Id=sampleProducts[4].Id,Price=100,Quantity=1, SBQQ__QuoteLine__c=lines[4].Id); 
        insert new Asset[]{a0, a1, a2, a3}; 
 
        a1.SBQQ__RequiredById__c = a0.Id; 
        a2.SBQQ__RequiredById__c = a0.Id; 
        update new Asset[]{a1, a2}; 
 
        sub.SBQQ__RequiredById__c = a0.Id; 
        update sub; 
    } 
 
    testMethod static void amendmentExample() { 
        setUpContract(); 
 
        String cid = (String)c1.Id; 
        Test.startTest(); 
        String qmodelJson = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', cid, null); 
        QuoteModel qmodel = (QuoteModel)JSON.deserialize(qmodelJson, QuoteModel.class); 
        Test.stopTest(); 
 
        System.assert(qmodel != null, 'Should have loaded something'); 
        System.assertEquals(4, qmodel.lineItems.size()); 
        System.assert(qmodel.lineItems[0].parentItemKey == null); 
        System.assertEquals(qmodel.lineItems[1].parentItemKey, qmodel.lineItems[2].parentItemKey); 
        System.assertEquals(qmodel.lineItems[2].parentItemKey, qmodel.lineItems[3].parentItemKey); 
    } 
 
    private class RenewalContext { 
        public Id masterContractId; 
        public Contract[] renewedContracts; 
    } 
 
    testMethod static void renewalExample() { 
        setUpContract(); 
 
        RenewalContext context = new RenewalContext(); 
        context.masterContractId = null; 
        context.renewedContracts = new Contract[]{c1}; 
 
        String cid = (String)c1.Id; 
        Test.startTest(); 
        String qmodelJson = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractRenewer', cid, JSON.serialize(context)); 
        QuoteModel[] qmodels = (QuoteModel[])JSON.deserialize(qmodelJson, QuoteModel[].class); 
        Test.stopTest(); 
 
        System.assert(qmodels != null, 'Should have loaded something'); 
        System.assertEquals('Renewal', qmodels[0].record.SBQQ__Type__c); 
        System.assertNotEquals(opp.Id, qmodels[0].record.SBQQ__Opportunity2__c); 
        System.assertEquals(4, qmodels[0].lineItems.size()); 
        System.assert(qmodels[0].lineItems[0].parentItemKey == null); 
        System.assertEquals(qmodels[0].lineItems[1].parentItemKey, qmodels[0].lineItems[2].parentItemKey); 
        System.assertEquals(qmodels[0].lineItems[2].parentItemKey, qmodels[0].lineItems[3].parentItemKey); 
    } 
}