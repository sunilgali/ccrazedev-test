public class adctestclass
{
       
       
       public static Decimal getADCPricing(List<String> lstAttr,string PriceListItemId)
       {
          
            system.debug('lstAttr' +lstAttr);
            
            system.debug('PriceListItemId' +PriceListItemId);
            
            Decimal finalattrprc = 0;
            
            List<ccrz__E_PriceListItem__c> lstPriceLstItem= [Select id, ccrz__AttributePricing__c from ccrz__E_PriceListItem__c 
                                                      where Id =: PriceListItemId];
            
            Map<string,string> mapchildparent = new Map<string,string>();
            
            List<string> lstallattr = new List<String>();
            
            system.debug('>>>>>'+ lstPriceLstItem[0].ccrz__AttributePricing__c);
            
            Map<String, Object> mapAttrJSON = (Map<String, Object>)JSON.deserializeUntyped(lstPriceLstItem[0].ccrz__AttributePricing__c);
            
            system.debug(' mapAttrJSON '+ mapAttrJSON);
            
            List<ccrz__E_Attribute__c> lstAttrDetails = [Select Id,ccrz__AttributeID__c,ccrz__ParentAttribute__c,
                                                  ccrz__ParentAttribute__r.ccrz__AttributeID__c from 
                                                  ccrz__E_Attribute__c where 
                                                  ccrz__AttributeID__c In : lstAttr];//SFID of Attribute
                                             
            
            for(ccrz__E_Attribute__c obj : lstAttrDetails)
            {
                mapchildparent.put(obj.ccrz__AttributeID__c,
                obj.ccrz__ParentAttribute__r.ccrz__AttributeID__c +'^'+obj.ccrz__AttributeID__c);
                
                lstallattr.add(obj.ccrz__ParentAttribute__r.ccrz__AttributeID__c +'^'+obj.ccrz__AttributeID__c);
                
            }
            
            system.debug('mapchildparent '+mapchildparent);
            
             
            Map<String,Object>  mapProdAttr0 =(Map<String,Object>)mapAttrJSON.get('aL');
            system.debug(' mapProdAttr0 '+ mapProdAttr0);
            
            
            system.debug('lstallattr.get(0) '+lstallattr.get(0));
            
            system.debug('mapProdAttr0 '+mapProdAttr0);
               
              Map<String,Object>  mapAttrPrice0 =(Map<String,Object>)mapProdAttr0.get(mapchildparent.get(lstAttr.get(0)));
              system.debug(' mapAttrPrice0 '+ mapAttrPrice0);
              
              //Primary Attribute
              finalattrprc = !mapAttrPrice0.containsKey('aL')?(Decimal)mapAttrPrice0.get('pr'):0;
               
                if(mapAttrPrice0.containsKey('aL'))
                {
                      Map<String,Object>  mapProdAttr1 =(Map<String,Object>)mapAttrPrice0.get('aL');
                      system.debug(' mapProdAttr1 '+ mapProdAttr1);
                      
                      Map<String,Object>  mapAttrPrice1 =(Map<String,Object>)mapProdAttr1.get(mapchildparent.get(lstAttr.get(1)));
                      system.debug(' mapAttrPrice1 '+ mapAttrPrice1);
                      
                      //Secondary Attribute
                      finalattrprc = !mapAttrPrice1.containsKey('aL')?(Decimal)mapAttrPrice1.get('pr'):0;
                      
                        if(mapAttrPrice1.containsKey('aL'))
                        {
                              Map<String,Object>  mapProdAttr2 =(Map<String,Object>)mapAttrPrice1.get('aL');
                              system.debug(' mapProdAttr2 '+ mapProdAttr2);
                              
                              Map<String,Object>  mapAttrPrice2 =(Map<String,Object>)mapProdAttr2.get(mapchildparent.get(lstAttr.get(2)));
                              system.debug(' mapAttrPrice2 '+ mapAttrPrice2);
                              
                              //Tertiary Attribute
                              finalattrprc = !mapAttrPrice2.containsKey('aL')?(Decimal)mapAttrPrice2.get('pr'):0;
                            
                        }
                
                }
                    
            return finalattrprc ;
       
         }
       
}