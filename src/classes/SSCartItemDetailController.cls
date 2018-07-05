global class SSCartItemDetailController {
    
    @AuraEnabled
    global static SSProductModel getProductDetails(String productSKU){
        return SSProductService.getProduct(productSKU, null);
    }

}