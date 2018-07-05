({
    doInit : function(component, event, helper) {
        console.log('Component clicked :');
   		var amount=component.get('v.Amount');
        var action = component.get("c.paypalRedirect");
        console.log('amount :'+amount +"and cart id = "+component.get('v.cartId')+' and subcription id = '+component.get('v.subscriptionItemId'));
        action.setParams({
            "amount": amount,
            "cartId":component.get('v.cartId'),
            "subscriptionItemId":component.get('v.subscriptionItemId')
        });
        action.setCallback(this, function(response){
            console.log('state '+response.getState());
            console.log('Value' +response.getReturnValue());
            if(response.getState()==='SUCCESS'){
                component.set('v.url',response.getReturnValue());
                console.log('url :'+component.get('v.url'));
                window.location.href=component.get('v.url');
            }
        }); 
        
        $A.enqueueAction(action); 
        
        
    }
})