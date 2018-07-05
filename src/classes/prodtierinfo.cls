public class prodtierinfo
{    
  
public class Tiers {
        public Integer q;
        public Integer p;
    }
    
public static void pricing()
{

    
List< ccrz__E_PriceListItem__c> lstPriceLstItem = [Select id,ccrz__Price__c,ccrz__PricingTiers__c from ccrz__E_PriceListItem__c where id = 'a101N00000IPfyW'];

List<SSTierPriceModel> pricingTierList = new List<SSTierPriceModel>();


string strPricingTierJSON = lstPriceLstItem[0].ccrz__PricingTiers__c;

system.debug(' Product Tier JSON '+ strPricingTierJSON);

//Map<String, Object> mapProdTier = (Map<String, Object>)JSON.deserializeUntyped(strPricingTierJSON);

//system.debug(' mapProdTier '+ mapProdTier);

//List<Object>  lstPTier=(List<Object>)mapProdTier.get('tiers');

//system.debug(' lstPTier '+ lstPTier);
JSONParser parser = JSON.createParser(strPricingTierJSON);
 List<pricingInfoclass> lorders=new List<pricingInfoclass>();
system.debug(' parser '+ parser);

while (parser.nextToken() != null) 
            {

                if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                {
                    pricingInfoclass TiersResp = (pricingInfoclass)parser.readValueAs(pricingInfoclass.class);  
                    
                    lorders.add(TiersResp);
                   
                     
                }
            }
            
            system.debug('>>>>.'+lorders);
           
            
       }
       
       }