global class SSCSRecipientController {
    
    public SSCSRecipientController(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        cybersourceResponse = JSON.serialize(params);
        System.debug('cybersourceResponse = '+cybersourceResponse);
        lghost =  SSCustomMetadataTypeDAO.getLightningHostURL();
    }
    
    global String cybersourceResponse{get;set;}
    global String lgHost{get;set;}


}