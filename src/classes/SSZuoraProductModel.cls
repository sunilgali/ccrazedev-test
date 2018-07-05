global class SSZuoraProductModel {

   /* global class zuoraProduct {
        String Description {get; set;}
        Date EffectiveEndDate {get; set;}
        Date EffectiveStartDate {get; set;}
        String Name {get; set;}
        String SKU {get; set;}
}

    global class zuoraProductRatePlan {
   String Description {get; set;}
   Date EffectiveEndDate {get; set;} 
   Date EffectiveStartDate {get; set;}
   String Name {get; set;}
   String SKU {get; set;}     
   String PromotionType {get; set;}
    
}
    
    global class zuoraProductRatePlanCharge {
     
  String AccountingCode {get; set;}
  String DefaultFromCustomer {get; set;}
  String BillingPeriod {get; set;}
  String ChargeModel {get; set;}
  String ChargeType {get; set;}
  String DeferredRevenueAccount{get; set;}
  String Name {get; set;} 
   String ProductRatePlanId {get; set;} 
   String RecognizedRevenueAccount {get; set;} 
   String TriggerEvent {get; set;} 
   String UOM {get; set;} 
   Boolean UseDiscountSpecificAccountingCode{get; set;}      
 /*  ProductRatePlanChargeTierData": {
    "ProductRatePlanChargeTier": [
      {
        "Active": true,
        "Currency": "USD",
        "Price": 10
      }
    ]
  },
 
    }*/

    global class ProductRatePlanChargeTier{
     //   Boolean Active {get; set;}
      //  String Currency {get; set;} //giving reserved error
     //   Decimal Price {get; set;}
      List<Map<String, Object>> ProductRatePlanChargeTier {get;set;} 
      // Map<String, Object> ProductRatePlanChargeTier {get;set;}
    }
        
   global Static Map<String,Object> zuoraProduct(String sku,String name, String description, Date effectiveStartDate, Date effectiveEndDate ) { 
     Map<String,Object> zuoraProductRequestBody = new   Map<String,Object>();
       zuoraProductRequestBody.put('SKU',sku);
         zuoraProductRequestBody.put('Description',description); 
          zuoraProductRequestBody.put('EffectiveEndDate',effectiveEndDate);
          zuoraProductRequestBody.put('EffectiveStartDate',effectiveStartDate);
          zuoraProductRequestBody.put('Name',name);
       return zuoraProductRequestBody;     
   }
  
    
    global Static Map<String,Object> zuoraProductRatePlan(String productId,String name, String description, Date effectiveEndDate, Date effectiveStartDate, String promotionType, String billingFrequency ) { 
     Map<String,Object> zuoraProductRatePlanBody = new   Map<String,Object>();
       zuoraProductRatePlanBody.put('ProductId',productId);
         zuoraProductRatePlanBody.put('Description',description); 
          zuoraProductRatePlanBody.put('EffectiveEndDate',effectiveEndDate);
          zuoraProductRatePlanBody.put('EffectiveStartDate',effectiveStartDate);
        zuoraProductRatePlanBody.put('PromotionType__c',promotionType);
          zuoraProductRatePlanBody.put('BillingFrequency__c',billingFrequency);
          zuoraProductRatePlanBody.put('Name',name);
       return zuoraProductRatePlanBody;     
   }
    
    
      global Static Map<String,Object> zuoraProductRatePlanCharge(String productRatePlanId,String accountingCode,String billCycleType, String billingPeriod, String chargeModel, String chargeType,
                                                                 String deferredRevenueAccount, String Name, String RecognizedRevenueAccount, String tiggerEvent, Boolean useDiscountSpecificAccountingCode,
                                                                  Decimal price ) { 
     Map<String,Object> zuoraProductRatePlanChargeBody = new   Map<String,Object>();
      Map<String,Object> chargeMap = new   Map<String,Object>(); 
          Map<String,Object> chargeMap2 = new   Map<String,Object>();
       String productrateplancharge;                                                               
      ProductRatePlanChargeTier productRatePlan = new ProductRatePlanChargeTier();  
         List< ProductRatePlanChargeTier> lst  = new List<ProductRatePlanChargeTier>(); 
                                                                      
             List<Map<String, Object>>  newlst = new List<Map<String, Object>>();                                                                     
     //  productRatePlanCharge.ProductRatePlanChargeTier chargeTier = new productRatePlanCharge.ProductRatePlanChargeTier(); 
      // List< productRatePlan.ProductRatePlanChargeTier>chargeTierLst = new List< productRatePlan.ProductRatePlanChargeTier>();                                                               
       zuoraProductRatePlanChargeBody.put('ProductRatePlanId',productRatePlanId);
         zuoraProductRatePlanChargeBody.put('AccountingCode',AccountingCode); 
          zuoraProductRatePlanChargeBody.put('BillCycleType',billCycleType);
          zuoraProductRatePlanChargeBody.put('BillingPeriod',billingPeriod);
          zuoraProductRatePlanChargeBody.put('ChargeModel',chargeModel);
          zuoraProductRatePlanChargeBody.put('ChargeType',chargeType);
        zuoraProductRatePlanChargeBody.put('DeferredRevenueAccount',DeferredRevenueAccount);
           zuoraProductRatePlanChargeBody.put('Name',Name);
           zuoraProductRatePlanChargeBody.put('RecognizedRevenueAccount',RecognizedRevenueAccount );
           zuoraProductRatePlanChargeBody.put('TriggerEvent',tiggerEvent );
           zuoraProductRatePlanChargeBody.put('UseDiscountSpecificAccountingCode',UseDiscountSpecificAccountingCode );
           zuoraProductRatePlanChargeBody.put('ListPriceBase','Per Billing Period');                                                           
         //  zuoraProductRatePlanChargeBody.put('DiscountPercentage',0.0 ); 
         //  zuoraProductRatePlanChargeBody.put('DiscountAmount',0.0 ); 
                                                                      
          // chargeMap.put('Active',true) ;
           chargeMap.put('Currency','USD') ; 
           chargeMap.put('Price',price);
            newlst.add(chargeMap);                                                          
            productRatePlan.ProductRatePlanChargeTier = newlst;
         //   lst.add(productRatePlan);  
                                                                      
           chargeMap2.put('ProductRatePlanChargeTier',productRatePlan.ProductRatePlanChargeTier);  
         //   zuoraProductRatePlanChargeBody.put('ProductRatePlanChargeTierData',productRatePlan);                                                           
         //
             zuoraProductRatePlanChargeBody.put('ProductRatePlanChargeTierData',chargeMap2); 
          //   zuoraProductRatePlanChargeBody.put('ProductRatePlanChargeTierData',lst); 
          
       //  productrateplancharge = '{ "ProductRatePlanChargeTier": [{ "Active": true, "Currency": "USD","Price":'+ price+' } ] }';
       //  zuoraProductRatePlanChargeBody.put('ProductRatePlanChargeTierData',productrateplancharge);
                                                            
                                                                      
                                                                      
       return zuoraProductRatePlanChargeBody;     
   }
    
    
      global Static Map<String,Object> zuoraProductRatePlanDiscountCharge(String productRatePlanId,String Name, String billCycleType, String billingPeriod, String BillingPeriodAlignment,String tiggerEvent,String chargeModel, String ApplyDiscountTo,
                                                                 String ChargeType, String discountLevel, Integer UpToPeriods,Decimal Discount ) { 
     Map<String,Object> zuoraProductRatePlanChargeBody = new   Map<String,Object>();
      Map<String,Object> chargeMap = new   Map<String,Object>(); 
          Map<String,Object> chargeMap2 = new   Map<String,Object>();                                                                 
      ProductRatePlanChargeTier productRatePlan = new ProductRatePlanChargeTier();  
         List< ProductRatePlanChargeTier> lst  = new List<ProductRatePlanChargeTier>();
      List<Map<String, Object>>  newlst = new List<Map<String, Object>>();  
     //  productRatePlanCharge.ProductRatePlanChargeTier chargeTier = new productRatePlanCharge.ProductRatePlanChargeTier(); 
      // List< productRatePlan.ProductRatePlanChargeTier>chargeTierLst = new List< productRatePlan.ProductRatePlanChargeTier>();                                                               
       zuoraProductRatePlanChargeBody.put('ProductRatePlanId',productRatePlanId);
          zuoraProductRatePlanChargeBody.put('BillCycleType',billCycleType);
          zuoraProductRatePlanChargeBody.put('BillingPeriod',billingPeriod);
          zuoraProductRatePlanChargeBody.put('ChargeModel',chargeModel);
          zuoraProductRatePlanChargeBody.put('ChargeType',chargeType);
      //  zuoraProductRatePlanChargeBody.put('BillingPeriodAlignment',BillingPeriodAlignment);
           zuoraProductRatePlanChargeBody.put('Name',Name);
          zuoraProductRatePlanChargeBody.put('ApplyDiscountTo',ApplyDiscountTo);
           zuoraProductRatePlanChargeBody.put('TriggerEvent',tiggerEvent);
          zuoraProductRatePlanChargeBody.put('DiscountLevel',discountLevel);
            zuoraProductRatePlanChargeBody.put('UpToPeriods',UpToPeriods); 
           // zuoraProductRatePlanChargeBody.put('DiscountLevel','subscription');                                                        
         //  zuoraProductRatePlanChargeBody.put('DiscountPercentage',0.0 ); 
         //  zuoraProductRatePlanChargeBody.put('DiscountAmount',0.0 ); 
                                                                     If(chargeModel == 'Discount-Percentage') {                                                          
           chargeMap.put('DiscountPercentage',0.0);
         }else{
        chargeMap.put('DiscountAmount',0.0);
               }
           chargeMap.put('Currency','USD'); 
                 newlst.add(chargeMap);                                                          
            productRatePlan.ProductRatePlanChargeTier = newlst;
         //   lst.add(productRatePlan);  
                                                                      
           chargeMap2.put('ProductRatePlanChargeTier',productRatePlan.ProductRatePlanChargeTier);  
         //   zuoraProductRatePlanChargeBody.put('ProductRatePlanChargeTierData',productRatePlan);                                                           
         //
             zuoraProductRatePlanChargeBody.put('ProductRatePlanChargeTierData',chargeMap2);                                                            
       //     productRatePlan.ProductRatePlanChargeTier = chargeMap;
       //     lst.add(productRatePlan);  
                                                                      
       //     chargeMap2.put('ProductRatePlanChargeTier',lst);                                                                                               
       //    zuoraProductRatePlanChargeBody.put('ProductRatePlanChargeTierData',productRatePlan);                                                                
       return zuoraProductRatePlanChargeBody;     
   }
    
        
   }
  
  
// String price, String currencyCode, Boolean active,