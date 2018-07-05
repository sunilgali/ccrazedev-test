({
    handleClickTry : function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "https://ccrazedev-developer-edition.na78.force.com/Spica/s/add-product-to-cart?productSKU=SPICATRIAL&storefront=Spica&quantity=1&transactionType=trial" 
        }).fire();
    },
    handleClickBuy: function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "https://ccrazedev-developer-edition.na78.force.com/Spica/s/add-product-to-cart?productSKU=SPICACC&storefront=Spica&quantity=1&transactionType=Buy" 
        }).fire();
    },
})