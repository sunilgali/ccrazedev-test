({
    doInit: function(component, event, helper) {
        
    },
    onScriptsLoaded : function(component, event, helper) {
        console.log('Scripts Loaded');  
    },
    OnClickProvisioning : function(component, event, helper) {
        console.log('OnClickProvisioning');
        component.set('v.selectedValue','Provisioning');
        helper.MenuCmpRenderEventfire(component, event);
    },
    OnClickTax : function(component, event, helper) {
        component.set('v.selectedValue','Tax');
        helper.MenuCmpRenderEventfire(component, event);
    },
    OnClickBilling : function(component, event, helper) {
        component.set('v.selectedValue','Billing');
        helper.MenuCmpRenderEventfire(component, event);
    },
    OnClickNotifications: function(component, event, helper) {
        component.set('v.selectedValue','Notifications');
        helper.MenuCmpRenderEventfire(component, event);
    },
    OnClickConfirmation: function(component, event, helper) {
        component.set('v.selectedValue','Confirmation');
        helper.MenuCmpRenderEventfire(component, event);
    },
    OnClickCartSummary: function(component, event, helper) {
        component.set('v.selectedValue','CartSummary');
        helper.MenuCmpRenderEventfire(component, event);
    },
    OnClickCartListing: function(component, event, helper) {
        component.set('v.selectedValue','CartListing');
        helper.MenuCmpRenderEventfire(component, event);
    },
    OnClickProductDetail: function(component, event, helper) {
        component.set('v.selectedValue','ProductDetail');
        helper.MenuCmpRenderEventfire(component, event);
    },
    OnClickSubscription: function(component, event, helper) {
        component.set('v.selectedValue','Subscription');
        helper.MenuCmpRenderEventfire(component, event);
    },
    OnClickBuyTry: function(component, event, helper) {
        component.set('v.selectedValue','BuyTry');
        helper.MenuCmpRenderEventfire(component, event);
    },
   onStorefrontSelected : function(component, event,helper) {
        var storefrontName=event.getParam("Storefrontname");
        console.log('storefrontName : '+storefrontName);
        if(storefrontName!=''){
            component.set('v.storefrontName',storefrontName);
        }
    },
    
})