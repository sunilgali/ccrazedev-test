global class SSAddonProductController {
    
    @AuraEnabled
    global static List<SSProductModel> getAddonProducts(String productSKU){
        return SSProductHelper.getRelatedProducts(productSKU, 'Add-On');
    }

    @AuraEnabled
    global static List<SSProductModel> getMaintenance(String productSKU){
        return SSProductHelper.getRelatedProducts(productSKU, 'Maintenance');
    }
}