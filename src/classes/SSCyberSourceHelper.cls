global class SSCyberSourceHelper {
    
    global static Map<String , String> callCybersourceSOAP(Map<String , String> iMap){
        
        Callout_Configuration__mdt cConfig = SSCustomMetadataTypeDAO.getCybersourceSOAPConfig();
        
        iMap.put('userName' , cConfig.Username__c);
        iMap.put('password' , cConfig.Client_Secret__c + cConfig.Client_Secret_1__c);
        iMap.put('endPointURL' , cConfig.Endpoint_URL__c);
        iMap.put('method' , cConfig.HTTP_Method__c);
        iMap.put('merchantId' , cConfig.Profile_Id__c);
        iMap.put('mRefernceCode' , EncodingUtil.convertToHex(Crypto.generateAesKey(128)));
        String xmlStr = CCSoapToolKitAPI.getCCSoapXMLBody(iMap);
        //System.debug('the xmlStr = '+xmlStr);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(iMap.get('endPointURL'));
        req.setMethod(iMap.get('method'));
        req.setbody(xmlStr);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //System.debug('ccResp = '+ccResp);
        String strMessage = res.getBody();
        //System.debug('after res.getBody = '+strMessage);
        
        DOM.Document doc=new DOM.Document();
        doc.load(strMessage);
        DOM.XmlNode rootNode=doc.getRootElement();
        Map<String, String> sMap = new Map<String, String>();
        parseXML(rootNode , sMap);
        return sMap;
        
    }
    
    private static void parseXML(DOM.XMLNode node , Map<String , String> sMap) {
        //System.debug('node.getNodeType() = '+node.getNodeType());
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(sMap.get(node.getName()) == null){
        		//system.debug('node.getName() = '+node.getName());
            	//System.debug('node.getText() = '+node.getText());
                sMap.put(node.getName() , node.getText());
            }
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            parseXML(child , sMap);
        }
    }
}