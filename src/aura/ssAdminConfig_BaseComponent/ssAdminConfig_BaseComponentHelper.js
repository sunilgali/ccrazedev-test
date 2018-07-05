({
	 getStorefront : function(component, event) {
        var action = component.get("c.getStorefront");
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               var result = response.getReturnValue();
                               var opts=[]; 
                               console.log('In getStorefront state :'+state);
                               if (state === "SUCCESS") 
                               {
                                   for(var i=0;i< result.length;i++){
                                       opts.push({"class": "optionClass", label: result[i], value: result[i]});
                                   }
                                   component.set('v.Strorefronts',opts);
                                   console.log('In getStorefront 1 :'+component.get('v.Strorefronts'));
                                   
                               }
                               else if (state === "ERROR") {
                                   var errors=response.getError();
                                   console.log("There is a error in getting Storefront:"+errors[0].message);
                               }
                           });
        $A.enqueueAction(action);
    }
})