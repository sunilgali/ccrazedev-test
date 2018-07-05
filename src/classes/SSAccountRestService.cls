@RestResource(urlMapping='/SSAccountRestService')
global class SSAccountRestService {

 /*
     * @description Method that invokes creation of account,contact,opportunity and lead in salesforce
     * @param       name                Account Name
     * @param       cartId              Encrypted ID for the CartT
     * @param       transactionType     Indicates "Try", "Buy", "Convert" flows
     * @param       userLocale          UserLocale like en_GB
     * @param       userCurrency        UserCurrency 
     * @param       contactModel        Custom Model class with the Contact Related info
     * @param       billTo              Custom Model class with the Address Related info
     * @return      Returns the data populated in a Custom Model class with the Account info
     */ 
    @HttpPost  
    global Static SSAccountResultModel createAccount(String accountName, String cartId, 
                              String transactionType, String userLocale,
                              String userCurrency, SSContactModel contactModel, SSAddressModel billTo, string opportunityStage, string sfdcProduct) {
    
        SSAccountResultModel accountResult = new SSAccountResultModel();
                
                              system.debug('contactModel'+contactModel);
                           
       //validate user locale and currency
       SSContext ssContext = new SSContext(userLocale, userCurrency);
       SSContext.validateSupportedLocales();
                                  
       //validate Cart ID
       SSCartModel cart = SSCartHelper.getCart(cartId);                          
                                  
        //check if an account or contact already exists
        //duplicate account check removed until there is a change in flow to handle non tetris accounts to signin
        try {
            Account existingAccount = [SELECT id, name FROM Account WHERE Name=:accountName LIMIT 1];       
            if (existingAccount != null) {
                //duplicate account exists
                String duplicateAccountId = existingAccount.Id; 
                accountResult.accountId = duplicateAccountId;
                accountResult.setErrorMessage('Duplicate Account found.');
                accountResult.setStatus(false);
                return accountResult;
            }
        }
        catch (Exception ex) {}
                               
        try{   
            Contact contactInfo = [SELECT Account.id,id,Account.Name FROM Contact WHERE Email = :contactModel.email];       
            if (contactInfo != null) {
                //duplicate Contact exists
                String duplicateAccountId = contactInfo.Account.Id;
                String duplicateContactId = contactInfo.Id;
                accountResult.accountId = duplicateAccountId;
                accountResult.accountName = contactInfo.Account.Name;
              //  accountResult.contactId = duplicateContactId;
                accountResult.setErrorMessage('Duplicate Contact found.');
                accountResult.setStatus(false);
                return accountResult;
            }
        }
        catch (Exception ex) {}
                                          
  /*  if ((!transactionType.equalsIgnoreCase('try')) && (!transactionType.equalsIgnoreCase('trial'))) {
            accountResult.vatNumber = cart.vatNumber;
            accountResult.taxExempt = cart.taxExemptFlag;
        }*/
       SSAccountModel accountModel = new SSAccountModel();         
       accountModel =SSAccountHelper.createAccount(accountName, userLocale,userCurrency,billTo);
       accountResult.accountId = accountModel.accountId;
       accountResult.accountName = accountModel.accountName;                           
                                  
       SSContactModel contactResult = new SSContactModel();                      
       
         system.debug('contactModel'+contactModel);
                           
       contactResult = SSContactHelper.createContact(accountModel.accountId, userLocale,userCurrency,contactModel,billTo); 
       accountResult.contactId = contactResult.contactId;
       
        if ((transactionType.equalsIgnoreCase('try')) || (transactionType.equalsIgnoreCase('trail'))) {       
        
        system.debug('>>>>>'+opportunityStage);                    
        SSOpportunityModel oppResult = new SSOpportunityModel();
        oppResult = SSOpportunityHelper.createOpportunity(accountResult.accountId,accountName,opportunityStage,sfdcProduct);
        
         system.debug('>>>>>'+oppResult.opportunityId);  
         
         
        accountResult.opportunityId = oppResult.opportunityId;    
        }    
       
        //System.debug('TetrisAccountManager: update Account and Contact info on Cart');                                  
        boolean bCartUpdate = SSCartHelper.updateAccountAndLead( cartId,  accountResult.accountId,  accountResult.contactId, accountResult.opportunityId, transactionType, '', '');                                  
        accountResult.setStatus(true);                          
        return accountResult;
    }   
    
     /*
     * @description Method that invokes updation of account,contact,opportunity and lead in salesforce
     * @param       accountId            Salesforce Account Id
     * @param       cartId               Encrypted ID for the Cart
     * @param       transactionType      Indicates "Try", "Buy", "Convert" flows
     * @param       userLocale           UserLocale like en_GB
     * @param       userCurrency         UserCurrency 
     * @param       contactModel         Custom Model class with the Contact Related info
     * @param       billTo               Custom Model class with the Address Related info
     * @return      Returns the data populated in a Custom Model class with the Account info
     */
    global Static SSAccountResultModel updateAccount(String accountId, String cartId,SSAccountModel account,
                              String transactionType, String userLocale,
                              String userCurrency, SSContactModel contactModel, SSAddressModel billTo) {
                              
                              system.debug('contactModel'+contactModel);
    
        SSAccountResultModel accountResult = new SSAccountResultModel();
       //validate user locale and currency                           
        SSContext SSContext = new SSContext(userLocale, userCurrency);        
        SSContext.validateSupportedLocales();
        
        //validate Cart ID
        SSCartModel cart = SSCartHelper.getCart(cartId);                        
        
       //check if an account or contact already exists
        try {
            Account existingAccount = [SELECT id, name FROM Account WHERE Id=:accountId LIMIT 1];       
            if (existingAccount == null) {
                accountResult.setErrorMessage('Invalid Account ID found.');
                accountResult.setStatus(false);
                return accountResult;
            }
        }
        catch (Exception ex) {}

        try{   
            //Check if a Contact exists with a given EMail and tied to a different address
            Contact contactInfo = [SELECT Account.id,id,Account.Name FROM Contact WHERE Email = :contactModel.email];       
            if (contactInfo != null) {
                //duplicate Contact exists
                String duplicateAccountId = contactInfo.Account.Id;
                String duplicateContactId = contactInfo.Id;
                if (!duplicateAccountId.equalsIgnoreCase(accountId)) {                    
                    accountResult.accountId = duplicateAccountId;
                    accountResult.contactId = duplicateContactId;
                    accountResult.accountName = contactInfo.Account.Name;
                    accountResult.setErrorMessage('Duplicate Contact found and is associated with a different Account.');
                    accountResult.setStatus(false);
                    return accountResult;
                }
                    
            }
        }
        catch (Exception ex) {}       
     
    /*if ((!transactionType.equalsIgnoreCase('try')) && (!transactionType.equalsIgnoreCase('trial'))) {   
        }*/
                                  
       SSAccountHelper.updateAccount(accountId, account.accountName,userCurrency, userLocale, billTo);
        accountResult.accountId = accountId;
        accountResult.accountName = account.accountName;
       SSContactModel conModel = new SSContactModel();                          
        if (contactModel.contactId == null) {
           conModel = SSContactHelper.createContact(accountId, userLocale,userCurrency,contactModel,billTo); 
            accountResult.contactId = conModel.contactId;                              
        }
        else {
            conModel = SSContactHelper.updateContact(accountId, contactModel, userLocale, userCurrency, billTo); 
            accountResult.contactId = conModel.contactId;                                                                    
        }
        /*  Do we need to update Opportunity stage here
         SSOpportunityModel oppModel = new SSOpportunityModel();    
         oppModel = updateOpportunity(opportunityId,accountId,account.accountName,opportunityStage,sfdcProduct);
         accountResult.opportunityId = oppModel.opportunityId;
        */ 
                                  
        boolean bCartUpdate = SSCartHelper.updateAccountAndLead( cartId, accountResult.accountId,  accountResult.contactId, '', transactionType, '', '');                                  
                        
        accountResult.setStatus(true);                          
        return accountResult;
    }   
    
     global Static SSAccountResultModel getAccount(String accountId) {
         SSAccountResultModel accountModel = new SSAccountResultModel();
        try{
         Account account =  [SELECT Id, Name FROM Account WHERE Id =: accountId LIMIT 1];
       
        accountModel.accountId = account.Id;
        accountModel.accountName = account.Name;
       // accountModel.billingContact.firstName = account.firstName;         
        }
         catch (Exception ex) {}
        return accountModel;
    }

}