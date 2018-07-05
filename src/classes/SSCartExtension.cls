global with sharing class SSCartExtension extends ccrz.ccLogicCartAddTo {
    
        
    public virtual override Map<String, Object> process(Map<String, Object> inputData) {
        System.debug('#################################################################');
        System.debug('CCCartExtension: process: ' + inputData);
        
        
        List<Object> incomingLineData = (List<Object>) inputData.get(ccrz.ccApiCart.LINE_DATA);
        System.debug('CCCartExtension: incomingLineData: ' + incomingLineData);
        
        for(Object lineData : incomingLineData)
        {
        //Map<String, Object> castlineData = (Map<String, Object>) lineData;
        //System.debug('CCCartExtension: castlineData: ' + (object)castlineData.get('attrListA2C'));
        
        System.debug('CCCartExtension: lineData: ' + lineData);
        
        }
        
        
        String couponCode = (String)inputData.get(ccrz.ccApiCart.COUPON_CODE);
        System.debug('CCCartExtension: process: ' + couponCode);
        
        String attributeList = (String)inputData.get(ccrz.ccApiCart.LINE_DATA_ATTRIBUTE_LIST);
        System.debug('CCCartExtension: process: ' + attributeList);
        
        
        object lineData = inputData.get(ccrz.ccApiCart.LINE_DATA);
        System.debug('CCCartExtension: LineData: is ... ' + lineData);
        
        Map<String, Object> res = new Map<String, Object> {ccrz.ccApi.SUCCESS => false};
        //res.put(ccrz.ccApi.SUCCESS, true);
        System.debug('CCCartExtension: process: return true');
        
        res = super.process(inputData);
        System.debug('CCCartExtension: process: return true');
        
        System.debug('CCCartExtension: process: result is .... ' +  res);
        String encryptedCartId = (String)res.get(ccrz.ccApiCart.CART_ENCID);
        System.debug('CCCartExtension: process: encryptedCartId ' +  encryptedCartId);
        
        System.debug('User Info '+Userinfo.getUserType());
        
         
        SSCartHelper.updatePriceOnCartItemsByPriceType(encryptedCartId);
        
        
       
        //System.Debug('STORE FRONT >>>>>> '+SSCartHelper.getDefaultStorefront());
        
        
        
    return res;
    }

}