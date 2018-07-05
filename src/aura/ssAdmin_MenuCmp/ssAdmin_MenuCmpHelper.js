({
    MenuCmpRenderEventfire : function(component, event) {
        var appEvent = $A.get("e.c:ssAdmin_MenuCmpRenderEvent");
        appEvent.setParams({ 
            "MenuSelectedVal" : component.get('v.selectedValue')
        });
        appEvent.fire(); 
        console.log('After fire');
        event.preventDefault();
    },
    
})