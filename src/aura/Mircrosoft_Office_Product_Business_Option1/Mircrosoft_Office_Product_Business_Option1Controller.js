({
    handleBuy365Business : function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "https://ccrazedev-developer-edition.na78.force.com/Microsoft/s/add-product-to-cart?productSKU=MSFT365B&storefront=Microsoft&quantity=1&transactionType=Buy" 
        }).fire();
    },
    handleTry365Business: function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "https://ccrazedev-developer-edition.na78.force.com/Microsoft/s/add-product-to-cart?productSKU=MSFT365BTRIAL&storefront=Microsoft&quantity=1&transactionType=trial" 
        }).fire();
    },
    
})