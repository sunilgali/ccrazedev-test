global class SSOpportunityHelper {
    
 global Static SSOpportunityModel createOpportunity(String accountId,String accountName, String opportunityStage, String sfdcProduct) {   
         SSOpportunityModel oppModel = new SSOpportunityModel();
        try{
        
            Opportunity opp = new Opportunity();
            opp.name = accountName;
            opp.AccountId = accountId;
            opp.Type = 'New Business';
            //Include Usercurrency in the signature?
            //opp.CurrencyIsoCode = userCurrency;
            //Do we need to add a new field SFDCProduct on opportunity(picklist or text)?
            opp.CloseDate = Date.today()+30;
            opp.StageName = opportunityStage;
           
            insert opp;
            
            system.debug('OPP HELPER'+opp.id);
            
            system.debug('OPP HELPER'+opp.Name);
            
            oppModel.opportunityId = opp.id;
            oppModel.opportunityName = opp.Name;
            oppModel.stageName = opp.StageName;
            return oppModel;
        }
        catch(Exception ex)
        {
            System.debug('SSOpportunityHelper: createOpportuntiy: exception ' + ex.getMessage());
            throw new SSAccountException(SSAccountException.EXCEPTION_CREATE_OPPORTUNITY);

        }
    } 
    
    /*
     * @description Method to fetch Contact Info by ContactId
     * @param       contactId           Salesforce Contact Id
     * @return      Returns the data populated in a Custom Model class with the Contact info.
     */
    global Static SSOpportunityModel getOpportunity(String opportunityId) {
        SSOpportunityModel opportunityModel = new SSOpportunityModel();
        try{        
            Opportunity opp = [SELECT Id, Name, AccountId,StageName FROM Opportunity WHERE Id =: opportunityId];
           
            opportunityModel.opportunityId = opp.Id;
            opportunityModel.opportunityName = opp.Name;
            opportunityModel.accountId = opp.AccountId;
           opportunityModel.stageName = opp.StageName;                 
        }
        catch(Exception ex) {}
       return opportunityModel;
    }  

     
     /*
     * @description Method to update a contact in salesforce
     * @param       accountId           Salesforce AccountId
     * @param       opportunityId       Salesforce opportunityId
     * @param       accountName         Salesforce accountName
     * @param       opportunityStage    Salesforce opportunityStage
     * @param       sfdcProduct         
     * @return      Returns updated OpportunityModel.
     */
     global Static SSOpportunityModel updateOpportunity(String opportunityId, String accountId,String accountName, String opportunityStage, String sfdcProduct) {
        SSOpportunityModel OpportunityModel = new SSOpportunityModel();
        try{        
            Opportunity opportunityInfo = [SELECT Id FROM Opportunity WHERE Id =: opportunityId];
           // contactInfo.AccountId = accountId;
            if (!String.isBlank(accountId)) {
                opportunityInfo.AccountId = accountId;            
            }
            if (!String.isBlank(accountName)) {
                opportunityInfo.name = accountName;            
            }
            opportunityInfo.StageName = opportunityStage;
          
            update opportunityInfo;
            
          opportunityModel.opportunityId = opportunityInfo.Id;
          opportunityModel.opportunityName = opportunityInfo.Name;
          opportunityModel.accountId = opportunityInfo.AccountId;
          opportunityModel.stageName = opportunityInfo.StageName;  
           
           return opportunityModel;           
                    
        }
        catch(Exception ex)
        {
            System.debug('SSAccountHelper: updateOpportunity: exception ' + ex.getMessage());
            throw new SSAccountException(SSAccountException.EXCEPTION_UPDATE_OPPORTUNITY);
        }
    }  

}