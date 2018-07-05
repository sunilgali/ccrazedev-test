({
    onInit : function(component, event, helper) { 
        helper.getComponentConfig(component, event);
        
    },
    onClickIcon: function(component, event, helper) {
        helper.toggleModalWindow(component, event);
    },
    onClickClose: function(component, event, helper) {
        helper.toggleModalWindow(component, event);
    },
    onClickSave: function(component, event, helper) {
        helper.saveConfig(component, event);       
        helper.toggleModalWindow(component, event);        
    }
})