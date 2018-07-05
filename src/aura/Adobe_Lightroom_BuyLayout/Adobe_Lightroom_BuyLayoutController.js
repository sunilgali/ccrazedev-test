({
    handleClick : function(component, event, helper) {
        component.set('v.flag',true);
        helper.toggleModalWindow(component, event);
    },
    onClickClose: function(component, event, helper) {
        helper.toggleModalWindow(component, event);   
    },
    onClickSave: function(component, event, helper) {      
        helper.toggleModalWindow(component, event);     
    },
    
})