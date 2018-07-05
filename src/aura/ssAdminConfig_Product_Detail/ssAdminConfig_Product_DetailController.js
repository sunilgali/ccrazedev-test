({
	onStorefrontSelected : function(component, event, helper) {
        var storefrontName=event.getParam("Storefrontname");
        console.log('storefrontName : '+storefrontName);
        if(storefrontName!=''){
            component.set('v.storefrontName',storefrontName);
        }
    },
    onScriptsLoaded : function(component, event, helper) {
    }
})