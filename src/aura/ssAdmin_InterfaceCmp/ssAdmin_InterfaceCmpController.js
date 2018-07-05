({
    doInit : function(component, event, helper) {
        console.log('in it handleMenuChangeEvent :'+component.get('v.MenuValue'));
    },
    handleMenuChangeEvent : function(component, event, helper) {
        component.set('v.MenuValue',event.getParam("MenuSelectedVal"));
        console.log('handleMenuChangeEvent :'+component.get('v.MenuValue'));
      component.set('v.storefrontName',event.getParam("storefrontName"));
       
    },
   onStorefrontSelected : function(component, event,helper) {
        var storefrontName=event.getParam("Storefrontname");
        console.log('storefrontName : '+storefrontName);
        if(storefrontName!=''){
            component.set('v.storefrontName',storefrontName);
        }
    },
})