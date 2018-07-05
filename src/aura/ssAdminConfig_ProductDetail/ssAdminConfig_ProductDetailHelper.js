({
    getStorefront : function(component, event) {
        var action = component.get("c.getStorefront");
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               var result = response.getReturnValue();
                               var opts=[]; 
                               if (state === "SUCCESS") 
                               {
                                   console.log('result : '+result);
                                   for(var i=0;i< result.length;i++){
                                       console.log(result[i]);
                                       opts.push({"class": "optionClass", label: result[i], value: result[i]});
                                   }
                                   component.set('v.Strorefronts',opts);
                                   
                               }
                               else if (state === "ERROR") {
                                   var errors=response.getError();
                                   console.log("There is a error in getting Storefront:"+errors[0].message);
                               }
                           });
        $A.enqueueAction(action);
    },
    getProductDetail : function(component, event) {
        
        var action = component.get("c.getProductConfig");
        action.setParams({ 
            storeFront    : component.get('v.storefrontName'),
            configId      : component.get('v.configId'),
            ComponentType : component.get('v.configType')
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               var result = response.getReturnValue();
                               console.log('state :'+state);
                               if (state === "SUCCESS") 
                               {
                                   if(result.new == 'new'){
                                       component.set('v.ProductConfigJson','{"ProductDetail":{"Display thumbnails next to product name”:”No”,"Display short product description”:”No”,"Display add-on products”:”No”,"Display maintenance options”:”No”}}');
                                   }
                                   else
                                   {
                                       component.set('v.configId',result.Id);
                                       var ProductConfigJson=result.Component_Config_JSON__c;
                                       component.set('v.ProductConfigJson',ProductConfigJson);
                                       this.populateConfig(component, event,ProductConfigJson);
                                   }
                               }
                               else if (state === "ERROR") {
                                   var errors=response.getError();
                                   console.log("There is a error in getting getTaxConfig:"+errors[0].message);
                               }
                           });
        $A.enqueueAction(action);
    },
    populateConfig : function(component, event, ProductConfigJson) {
        
        ProductConfigJson=JSON.parse(ProductConfigJson);
        ProductConfigJson=ProductConfigJson.ProductDetail;
        component.set('v.PD1',ProductConfigJson['Display thumbnails next to product name']);
        component.set('v.PD2',ProductConfigJson['Display short product description']);
        component.set('v.PD3',ProductConfigJson['Display add-on products']);
        component.set('v.PD4',ProductConfigJson['Display maintenance options']);
    },
    saveProductConfig : function(component, event) {
        var ProductConfigJson=component.get('v.ProductConfigJson');
        
        
        if(ProductConfigJson['Display thumbnails next to product name'] != '' ||
           ProductConfigJson['Display short product description'] != '' ||
           ProductConfigJson['Display add-on products'] != '' ||
           ProductConfigJson['Display maintenance options'] != ''){
            component.set("v.errorMessage", 'Please prove values for all the Configurations');
        }
        else{
        console.log(component.get('v.storefrontName'));
        console.log(component.get('v.ProductConfigJson'));
        console.log(component.get('v.configId'));
        console.log(component.get('v.configType'));
        /*
        var action = component.get("c.upsertProductConfig");
        action.setParams({ 
            storeFront    : component.get('v.storefrontName'),
            TaxJson       : TaxJson,
            configId      : component.get('v.configId'),
            ComponentType : component.get('v.configType')
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               var result = response.getReturnValue()
                               if (state === "SUCCESS") 
                               {
                                   if(result==true) {
                                       component.set('v.Banner',true);
                                       window.setTimeout(
                                           $A.getCallback(function() {
                                               $A.get('e.force:refreshView').fire();
                                           }), 1500
                                       );
                                   }
                               }
                               else if (state === "ERROR") {
                                   var errors=response.getError();
                                   console.log("There is a error in saving Config:"+errors[0].message);
                               }
                           });
        $A.enqueueAction(action);*/
        }
    }
})