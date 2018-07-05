({
    getTaxConfig : function(component, event) 
    {
        var action = component.get("c.getTaxConfig");
        action.setParams({ 
            storeFront : component.get('v.storefrontName'),
            configId    : component.get('v.configId')
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               var result = response.getReturnValue();
                               console.log('Tax: result : '+JSON.stringify(result));
                               if (state === "SUCCESS") 
                               {
                                   if(result.new == 'new'){
                                       component.set('v.TaxJson','{"taxprovider":{"Active":"","Avalara":{"username":"","password":"","serviceURL":"","companycode":""},"custom":{"classname":""},"None":""}}');
                                       this.clearValues(component, event);
                                   }
                                   else
                                   {
                                       component.set('v.configId',result.Id);
                                       var TaxJson=result.Storefront_Config_JSON__c;
                                       component.set('v.TaxJson',TaxJson);
                                       this.populateConfig(component, event,TaxJson);
                                   }
                               }
                               else if (state === "ERROR") {
                                   var errors=response.getError();
                                   console.log("There is a error in getting getTaxConfig:"+errors[0].message);
                               }
                           });
        $A.enqueueAction(action);
    },   
    
    clearValues: function(component, event){
        
        /* Clear Avalara Values*/
        var Avalara=component.find('Avalara');
        Avalara.set('v.checked',false); 
        component.set('v.TaxSelecValue','');
        component.set('v.Username','');
        component.set('v.Password','');
        component.set('v.ServiceURL','');
        component.set('v.CompanyCode','');
        
        /*Clear Custom Values*/
        var Custom=component.find('Custom');
        Custom.set('v.checked',false);  
        component.set('v.ClassName','');
        
        /*clear None Value*/
        
        var None=component.find('None');
        None.set('v.checked',false);
        
        
    },
    
    populateConfig : function(component, event,TaxJson)
    {
        TaxJson=JSON.parse(TaxJson);
        TaxJson=TaxJson.taxprovider;
        var active=TaxJson.Active;
        if(active == 'Avalara')
        {
            var AvalaraConfig=TaxJson.Avalara;
            var Avalara=component.find('Avalara');
            Avalara.set('v.checked',true); 
            component.set('v.TaxSelecValue','Avalara');
            component.set('v.Username',AvalaraConfig.username);
            component.set('v.Password',AvalaraConfig.password);
            component.set('v.ServiceURL',AvalaraConfig.serviceURL);
            component.set('v.CompanyCode',AvalaraConfig.companycode);
            component.set('v.ClassName','');
            
        }
        else if(active == 'Custom'){
            var CustomConfig=TaxJson.custom;
            component.set('v.TaxSelecValue','Custom');
            var Custom=component.find('Custom');
            Custom.set('v.checked',true);  
            component.set('v.ClassName',CustomConfig.classname);
            component.set('v.Username','');
            component.set('v.Password','');
            component.set('v.ServiceURL','');
            component.set('v.CompanyCode','');
        }
            else
            {
                component.set('v.TaxSelecValue','None');
                var None=component.find('None');
                None.set('v.checked',true);
                component.set('v.Username','');
                component.set('v.Password','');
                component.set('v.ServiceURL','');
                component.set('v.CompanyCode','');
                component.set('v.ClassName','');
                
                
            } 
        
    },
    saveTaxConfig : function(component, event)
    {
        var TaxJson=component.get('v.TaxJson');
        var Username=component.get('v.Username');
        var Password=component.get('v.Password');
        var ServiceURL=component.get('v.ServiceURL');
        var CompanyCode=component.get('v.CompanyCode');
        var ClassName=component.get('v.ClassName');
        var TaxSelecValue=component.get('v.TaxSelecValue');
        
        
        TaxJson=JSON.parse(TaxJson);
        var TaxJsonn=TaxJson.taxprovider;
        var flag=false;
        
        if(TaxSelecValue == 'Avalara')
        {
            var allValid = this.isComponentValid(component.find("Username"))
            && this.isComponentValid(component.find("Password"))
            && this.isComponentValid(component.find("ServiceURL"))  
            && this.isComponentValid(component.find("CompanyCode"))
            if(allValid){
                flag=true;
                TaxJsonn.Active='Avalara'; 
                var TaxJson2=TaxJsonn.Avalara;
                TaxJson2.username = Username;
                TaxJson2.password = Password;
                TaxJson2.serviceURL = ServiceURL;
                TaxJson2.companycode = CompanyCode;
                TaxJsonn.Avalara=TaxJson2;
                
                /* clearing  custom class Values */ 
                var TaxJson3=TaxJsonn.custom;
                TaxJson3.classname = '';
                TaxJsonn.custom = TaxJson3; 
                
                /* clearing None Values */ 
                TaxJsonn.None='';
            } 
            
        }
        else if(TaxSelecValue== 'Custom')
        {
            if( ClassName == '')
            {
                component.set('v.errorMessage','Please Select a valid Class Name');
            }
            else  
            {       
                flag=true;
                TaxJsonn.Active='Custom'; 
                var TaxJson2=TaxJsonn.custom;
                TaxJson2.classname = ClassName;
                TaxJsonn.custom = TaxJson2; 
                
                /* clearing  Avalara Values */ 
                var TaxJson3=TaxJsonn.Avalara;
                TaxJson3.username = '';
                TaxJson3.password = '';
                TaxJson3.serviceURL = '';
                TaxJson3.companycode = '';
                TaxJsonn.Avalara=TaxJson3;
                
                /* clearing None Values */ 
                TaxJsonn.None='';
            }
            
        }
            else
            {
                flag=true;
                TaxJsonn.Active='None';
                TaxJsonn.None='True';
                
                /* clearing  Avalara Values */ 
                
                var TaxJson3=TaxJsonn.Avalara;
                TaxJson3.username = '';
                TaxJson3.password = '';
                TaxJson3.serviceURL = '';
                TaxJson3.companycode = '';
                TaxJsonn.Avalara=TaxJson3;
                
                /* clearing  custom class Values */ 
                var TaxJson2=TaxJsonn.custom;
                TaxJson2.classname = '';
                TaxJsonn.custom = TaxJson2; 
                
            }
        TaxJson.taxprovider=TaxJsonn;
        TaxJson=JSON.stringify(TaxJson);
        console.log('flag :'+flag)
        if(flag == true){
            this.save(component, event,TaxJson);
        }
        
    },
    save : function(component, event, TaxJson){
        var action = component.get("c.saveTaxConfig");
        action.setParams({ 
            storeFront : component.get('v.storefrontName'),
            TaxJson    : TaxJson,
            configId   : component.get('v.configId')
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               var result = response.getReturnValue()
                               if (state === "SUCCESS") 
                               {
                                   if(result==true) {
                                       component.set('v.Banner',true);
                                       
                                       window.setTimeout(
                                           $A.getCallback(function() {
                                               $A.get('e.force:refreshView').fire();
                                           }), 1500
                                       );
                                   }
                               }
                               else if (state === "ERROR") {
                                   var errors=response.getError();
                                   console.log("There is a error in saving Config:"+errors[0].message);
                               }
                           });
        $A.enqueueAction(action);
    },
    isComponentValid : function(cmp){
        cmp.showHelpMessageIfInvalid();
        return cmp.get('v.validity').valid; 
    },
    
})