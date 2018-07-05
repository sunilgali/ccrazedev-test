global with sharing class SSInvoiceHookExtension extends ccrz.cc_hk_Invoice
{ 
    global override Map<String,Object> onOrder(Map<String,Object> inputData)
    { 
        
        
        Map<String, Object> inputDataForInv = new Map<String,Object>();
        
        
        inputDataForInv.put(ccrz.cc_hk_Invoice.PARAM_CART,(object)inputData.get('cart'));
        inputDataForInv.put(ccrz.cc_hk_Invoice.PARAM_ENC_CART_ID,(object)inputData.get('encCartId'));
        inputDataForInv.put(ccrz.cc_hk_Invoice.PARAM_CART_ITEMS,(object)inputData.get('cartItems'));
        inputDataForInv.put(ccrz.cc_hk_Invoice.PARAM_ORDER,(object)inputData.get('order'));
        inputDataForInv.put(ccrz.cc_hk_Invoice.PARAM_ORDER_ITEMS,(object)inputData.get('orderItems'));
        inputDataForInv.put(ccrz.cc_hk_Invoice.PARAM_ORDER_ITEM_TIERS,(object)inputData.get('orderItemTiers'));
        inputDataForInv.put(ccrz.cc_hk_Invoice.PARAM_ORDER_CHILD_ITEMS,(object)inputData.get('orderChildItems'));
        inputDataForInv.put(ccrz.cc_hk_Invoice.PARAM_ORDER_TERMS,(object)inputData.get('orderTerms'));
        inputDataForInv.put(ccrz.cc_hk_Invoice.PARAM_ORDER_W_STATUS,(object)inputData.get('orderWStatus'));
        
        System.debug('cchk_Invoice: process: result is .... ' +  inputDataForInv);
        
        Map<String, Object> res = new Map<String, Object> {ccrz.ccApi.SUCCESS => false};
        
        res = super.onOrder(inputDataForInv);
        
        System.debug('cchk_Invoice: process: result is .... ' +  res);
        

        return inputData;
    }
}