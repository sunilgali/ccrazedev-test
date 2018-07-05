({
	onScriptsLoaded : function(component, event, helper) {
		console.log('Scripts loaded');
	},
    
    doInit : function(component, event, helper) {
        //var pDynamic = component.get("v.isParentDynamicKit");
        var product = component.get("v.product");
        //if(pDynamic == true){
            component.set("v.tieredPrice" , product.price[0]);
        //}
	},
    
    updateTierSelect : function(component , event , helper){
        //helper.updateTeirSelect(component , event , helper);
        var termId = event.getParam("termId");
        var termType = event.getParam("termType");
        alert(termId);
        alert(termType);
        component.set("v.termId" , termId);   
        component.set("v.termType" , termType);   
        var product = component.get("v.product");
        
        /*var tieredPrice;
        product.price.forEach(sProd =>{
            sProd.tierPriceList.forEach(tier =>{
                    tier.selected = false;
            		tier.qunatity = 0;
                });
            if(sProd.subscriptionInstallmentUOM == termId){
                termType = sProd;
            }
        });
        component.find("quantity").set("v.value" , "");
        //component.set("v.tieredPrice" , tieredPrice);
        //helper.updateTierPrice(component, event , helper);
        var event = component.getEvent("ssTermPrice");
        event.fire();*/
    },
    
    updateTierPrice : function(component , event , helper){
        //helper.updateTierPrice(component , event , helper);
        //var quantity = parseInt(component.find("quantity").get("v.value"));
        var tierId = component.find("tierSelect").get("v.value");
        var product = component.get("v.product");
        var termId = component.get("v.termId");
        product.price.forEach(sProd =>{
            if(sProd.subscriptionInstallmentUOM == termId){
            	sProd.tierPriceList.forEach(tier =>{
                    if(tier.tierDescription == tierId){
                        tier.selected = true;
            			tier.quantity = quantity;
                    }
                    else{
                        tier.selected = false;
                    }
                });
            }
        });
        //component.set("v.product" , product);
     
        var event = component.getEvent("ssTermPrice");
        event.fire();
    },
    
    updatePrice : function(component , event , helper){
        alert("inside----------");
        var product = component.get("v.product");
        var productPrice = 0.0;
        if(product.productType == "Dynamic Kit"){
            var cBoxes = component.find("dynamicCheckbox");
            if(cBoxes){
                [].concat(cBoxes).forEach(cmp => {
                        if(cmp.get("v.checked")){
                            var innerPrice = parseFloat(cmp.get("v.value"));
                            if(innerPrice){
                                productPrice += innerPrice;
                            }
                         }});
            }
        }
        else if(product.isTierPriced){
            //tieredPrice
            var sVal = component.find("productTermSelect").get("v.value");
            var term = sVal.substring(sVal.indexOf("@")+1);
            var tieredPrice;
            product.price.forEach(sProd =>{
                if(sProd.subscriptionInstallmentUOM == term){
                	tieredPrice = sProd;
            	}
            });
            component.set("v.tieredPrice" , tieredPrice);
        }
        else{
            var sVal = component.find("productTermSelect").get("v.value");
            productPrice = component.find("productTermSelect").get("v.value").substring(0 , sVal.indexOf("@"));
        }
        //if(!product.isTierPriced){
            component.set("v.productPrice" , productPrice);
            var event = component.getEvent("ssTermPrice");
            //event.setParams({"termPrice" : component.get("v.productPrice")});
            event.fire();
        //}
    }
})