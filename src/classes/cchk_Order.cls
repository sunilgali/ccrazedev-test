global with sharing class cchk_Order extends ccrz.cc_hk_Order
{ 
    
    global override Map<String, Object> place(Map<String, Object> inputData)
    { 
        system.debug('>>>>>cc_hk_Order'+inputData);
        
        String currentStep = (String) inputData.get(ccrz.cc_hk_Order.PARAM_PLACE_STEP);
        
        system.debug('>>>>>cc_hk_Order'+currentStep);
        
        if (ccrz.cc_hk_Order.STEP_END.equals(currentStep))
         { 
            ccrz__E_Order__c currentOrder =
                (ccrz__E_Order__c)inputData.get(ccrz.cc_hk_Order.PARAM_ORDER);

        }
        return inputData;
    }

    
}