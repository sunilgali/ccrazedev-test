({
    onStorefrontSelected : function(component, event, helper) {
        var appEvent = $A.get("e.c:ssAdminConfig_StorefrontValEvent");
        appEvent.setParams({ 
            "Storefrontname" : component.get('v.storefrontName')
        });
        appEvent.fire(); 
    },
    doInit: function(component, event, helper) {
        helper.getStorefront(component, event);
    }
})