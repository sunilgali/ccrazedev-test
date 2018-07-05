({
    doInit : function(component, event, helper) {
        component.set('v.configType','Product Detail');
        helper.getStorefront(component, event);
    },
    handleChangePD1 : function(component, event, helper) {
        var selected = event.getSource().get("v.value");
        component.set('v.PD1',selected);
    },
    handleChangePD2 : function(component, event, helper) {
        var selected = event.getSource().get("v.value");
        component.set('v.PD2',selected);
    },
    handleChangePD3 : function(component, event, helper) {
        var selected = event.getSource().get("v.value");
        component.set('v.PD3',selected);
    },
    handleChangePD4 : function(component, event, helper) {
        var selected = event.getSource().get("v.value");
        component.set('v.PD4',selected);
    },
    onChangeStorefront : function(component, event, helper) {
        console.log(component.get('v.storefrontName'));
        helper.getProductDetail(component, event);
    },
    onclickSavebutton : function(component, event, helper) {
        helper.saveProductConfig(component, event);
    }
})