({
    getClasses : function(component, event, TaxJson)
    {
        var action = component.get("c.getTaxConfig");
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               var result = response.getReturnValue();
                               var opts=[];  
                               if (state === "SUCCESS") 
                               {
                                   for(var i=0;i< result.length;i++){
                                       opts.push({'class':result[i].Name , 'label': result[i].Name, 'value': result[i].Name});
                                   }
                                   
                                   component.set('v.options',opts);
                               }
                               else if (state === "ERROR") {
                                   var errors=response.getError();
                                   console.log("There is a error in saving Home applicants current address:"+errors[0].message);
                               }
                           });
        $A.enqueueAction(action);
    }
})