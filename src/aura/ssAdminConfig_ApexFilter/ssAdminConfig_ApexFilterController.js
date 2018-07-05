({
    doInit : function(component, event, helper) {
        helper.getClasses(component, event);
    },
    handleChange : function(component, event, helper) {
        var selected = event.getSource().get("v.value");
        component.set('v.ClassName',selected);
    }
})