({
    doInit : function(component, event, helper) {
        component.set('v.configType','Tax');
        // helper.getStorefront(component, event);
        if(component.get('v.storefrontName') !=''){
            helper.getTaxConfig(component, event);
        }
        
    },
    onclickSavebutton : function(component, event, helper) {
        helper.saveTaxConfig(component, event);
    },
    onGroup : function(component, event, helper) {
        var selected = event.getSource().get("v.value");
        component.set('v.TaxSelecValue',selected);
        console.log('selected :'+selected);
        if(selected == 'Avalara'){
            component.set('v.ClassName','');
        }
        else if(selected == 'Custom'){
            component.set('v.Username','');
            component.set('v.Password','');
            component.set('v.ServiceURL','');
            component.set('v.CompanyCode',''); 
        }  
            else if(selected == 'None'){
                component.set('v.Username','');
                component.set('v.Password','');
                component.set('v.ServiceURL','');
                component.set('v.CompanyCode',''); 
                component.set('v.ClassName','');
            }
    },
    onStorefrontSelected : function(component, event,helper) 
    {
        var storefrontName=event.getParam("Storefrontname");
        console.log('Tax: storefrontName :'+storefrontName);
        if(storefrontName != '')
        {
            component.set('v.storefrontName',storefrontName);
            helper.getTaxConfig(component, event);
        }
    },
    
})