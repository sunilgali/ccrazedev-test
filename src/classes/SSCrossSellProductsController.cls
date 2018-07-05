global class SSCrossSellProductsController {
    
    @AuraEnabled
    global static List<SSProductModel> getCrossSellProducts(String productSKU){
        return SSProductHelper.getRelatedProducts(productSKU, 'CrossSell');
    }
}