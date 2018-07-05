({
	handleBuy365BusinessEssentials : function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "https://ccrazedev-developer-edition.na78.force.com/Microsoft/s/add-product-to-cart?productSKU=MSFTPRJTE&storefront=Microsoft&quantity=1&transactionType=Buy&isTier=true" 
        }).fire();
        
		
	}
})