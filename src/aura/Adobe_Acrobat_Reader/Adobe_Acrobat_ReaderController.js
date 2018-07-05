({
    handleBuyClick : function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "https://ccrazedev-developer-edition.na78.force.com/Adobe/s/add-product-to-cart?productSKU=ADOILL&storefront=Adobe&quantity=1&transactionType=Buy&isBundle=true" 
        }).fire();
    },
    handleTryClick : function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "https://ccrazedev-developer-edition.na78.force.com/Adobe/s/add-product-to-cart?productSKU=ADOILL&storefront=Adobe&quantity=1&transactionType=Buy&isBundle=true" 
        }).fire();
    },
})