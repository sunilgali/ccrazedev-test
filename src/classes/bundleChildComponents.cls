global class bundleChildComponents
{
    @AuraEnabled
    global String childProductType;
    @AuraEnabled
    global String childProductSKU;
    
    @AuraEnabled
    global Decimal quantity;
    @AuraEnabled
    global List<SSCartItemTierModel> tier;
    @AuraEnabled
    global List<String> lineDataAttributes;
    
}