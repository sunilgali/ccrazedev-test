global class SSAccountService {

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
    
    global Static SSAccountResultModel createAccount(String accountName, String cartId, 
                              String transactionType, String userLocale,
                              String userCurrency, SSContactModel contactModel, SSAddressModel billTo, string opportunityStage, string sfdcProduct) {
    
        SSAccountResultModel accountResult = new SSAccountResultModel();
                
                              system.debug('contactModel'+contactModel);
                              
                              system.debug('cartId'+cartId);
                              
                              
                               
       string strAccountId;  
       string strContactId;                  
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
                strAccountId = existingAccount.Id; 
                //accountResult.accountId = duplicateAccountId;
                //accountResult.setErrorMessage('Duplicate Account found.');
                //accountResult.setStatus(false);
                //return accountResult;
            }
        }
        catch (Exception ex) {}
                               
        try{   
            Contact contactInfo = [SELECT Account.id,id,Account.Name FROM Contact WHERE Email = :contactModel.email];       
            if (contactInfo != null) {
                //duplicate Contact exists
                String duplicateAccountId = contactInfo.Account.Id;
                strContactId = contactInfo.Id;
               // String duplicateContactId = contactInfo.Id;
               // accountResult.accountId = duplicateAccountId;
               // accountResult.accountName = contactInfo.Account.Name;
              //  accountResult.contactId = duplicateContactId;
               // accountResult.setErrorMessage('Duplicate Contact found.');
               // accountResult.setStatus(false);
                //return accountResult;
            }
        }
        catch (Exception ex) {}
                                          
  /*  if ((!transactionType.equalsIgnoreCase('try')) && (!transactionType.equalsIgnoreCase('trial'))) {
            accountResult.vatNumber = cart.vatNumber;
            accountResult.taxExempt = cart.taxExemptFlag;
        }*/
       SSAccountModel accountModel = new SSAccountModel();  
       if(strAccountId == null)
       { 
               
           accountModel =SSAccountHelper.createAccount(accountName, userLocale,userCurrency,billTo);
           accountResult.accountId = accountModel.accountId;
           accountResult.accountName = accountModel.accountName;   
           strAccountId = accountModel.accountId;                 
       }
                                  
       SSContactModel contactResult = new SSContactModel();                      
       
       system.debug('contactModel'+contactModel);
       
       if(strContactId == null)
       {                    
          contactResult = SSContactHelper.createContact(strAccountId, userLocale,userCurrency,contactModel,billTo); 
          accountResult.contactId = contactResult.contactId;
          strContactId = contactResult.contactId;
       }
        //if ((transactionType.equalsIgnoreCase('try')) || (transactionType.equalsIgnoreCase('trail'))) {       
        
        system.debug('>>>>>'+opportunityStage);                    
        SSOpportunityModel oppResult = new SSOpportunityModel();
        //oppResult = SSOpportunityHelper.createOpportunity(accountResult.accountId,accountName,opportunityStage,sfdcProduct);
        oppResult = SSOpportunityHelper.createOpportunity(strAccountId,accountName,opportunityStage,sfdcProduct);
        
         system.debug('>>>>>'+oppResult.opportunityId);  
         
         
        accountResult.opportunityId = oppResult.opportunityId;    
        //}    
       
        //System.debug('TetrisAccountManager: update Account and Contact info on Cart');                                  
        boolean bCartUpdate = SSCartHelper.updateAccountAndLead( cartId, strAccountId,  strContactId, accountResult.opportunityId, transactionType, '', '');                                  
        accountResult.contactId = strContactId;
        accountResult.accountId = strAccountId;
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
        system.debug('accountIdupdateAccount'+accountId);
        system.debug('cartId'+cartId);
        
        SSAccountResultModel accountResult = new SSAccountResultModel();
       //validate user locale and currency                           
        //SSContext SSContext = new SSContext(userLocale, userCurrency);        
        //SSContext.validateSupportedLocales();
        
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
            system.debug('contactInfo.Account.Id'+contactInfo.Account.Id);
            
            system.debug('Account.Id'+accountId);
            
                //duplicate Contact exists
                String duplicateAccountId = contactInfo.Account.Id;
                String duplicateContactId = contactInfo.Id;
                if(accountId != null){
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
        }
        catch (Exception ex) {}       
     
    if ((!transactionType.equalsIgnoreCase('try')) && (!transactionType.equalsIgnoreCase('trial'))) {   
    transactionType = 'Prospecting';
        }
        else
        transactionType = 'Closed-Won';
                                  
       SSAccountHelper.updateAccount(accountId, account.accountName,userCurrency, userLocale, billTo);
        accountResult.accountId = accountId;
        accountResult.accountName = account.accountName;
       SSContactModel conModel = new SSContactModel();                          
        if (contactModel.contactId == null) {
           conModel = SSContactHelper.createContact(accountId, userLocale,userCurrency,contactModel,billTo); 
            accountResult.contactId = conModel.contactId;                              
        }
        else {
         
         system.debug('SSAccountService'+contactModel);
         system.debug('SSAccountService'+accountId);
         system.debug('SSAccountService'+userLocale);
         system.debug('SSAccountService'+userCurrency);
        
            conModel = SSContactHelper.updateContact(accountId, contactModel, userLocale, userCurrency, billTo); 
            accountResult.contactId = conModel.contactId;                                                                    
        }
         
         SSOpportunityModel oppModel = new SSOpportunityModel();    
         oppModel = SSOpportunityHelper.createOpportunity(accountId,account.accountName,transactionType,'');
         accountResult.opportunityId = oppModel.opportunityId;
        
                                  
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
    
    
    global Static SSAccountModel getCustomerInfo() {
        
        SSAccountModel accountModel = new SSAccountModel();
         
        try
        {
         
         system.debug('UserInfo.getUserType() '+UserInfo.getUserType());
         system.debug('UserInfo.getuserid() '+UserInfo.getuserid());
         if(UserInfo.getUserType() == 'Guest')
         { 
            return accountModel;
         }
         
         List<User> accId = [select contactid, contact.accountid from user where id = : UserInfo.getuserid()];
         //List<User> accId = [select contactid, contact.accountid from user where id = '0051N000006B52lQAC'];
         if(!accId.IsEmpty())
         {
                 
                 if(accId[0].contact.accountId != null)
                 {
                     System.debug('Contact Account'+accId[0].contact.accountId);
                     System.debug('Contact Account.contactId '+accId[0].contactId);
                      
                      List<Contact> lstConAcc = [Select Id,MailingAddress,AccountId,Account.Name,FirstName , LastName , email , phone from Contact where Id =: 
                      accId[0].contactId Limit 1] ;
                        System.debug(lstConAcc.size());
                      for(Contact cont : lstConAcc) {
                        System.debug('Inside for loop...');
                       Address addr = cont.MailingAddress;
                       System.debug('Inside for loop...and addr = '+addr);
                       accountModel.accountName = cont.Account.Name;
                       accountModel.accountId = cont.AccountId;
                       accountModel.Phone = cont.Phone;
                       
                       SSContactModel objCon = new SSContactModel();
                       
                       objCon.firstName = cont.FirstName;
                       objCon.LastName = cont.LastName;
                       objCon.ContactId = cont.Id;
                       objCon.email = cont.email;
                       objCon.phone = cont.phone;
                       
                       SSAddressModel cAddr = new SSAddressModel();
                       cAddr.streetAddress = addr.Street;
                       cAddr.State = addr.State;
                       cAddr.Country = addr.Country;
                       cAddr.PostalCode = addr.PostalCode;
                       cAddr.City = addr.City;
                       objCon.address = cAddr;
                        
                       accountModel.billingContact = objCon;
                        System.debug('AAAccountService accountModel.billingContact '+accountModel.billingContact);
                  } 
                } 
             } 
             
             system.debug('UserInfo accountModel'+accountModel);
                 
        }
         catch (Exception ex) {}
        return accountModel;
    }
    
    global Static String getCustomerId() {
        String accountId = '';
        try{
             system.debug('UserInfo.getUserType() '+UserInfo.getUserType());
             system.debug('UserInfo.getuserid() '+UserInfo.getuserid());
             if(UserInfo.getUserType() == 'Guest'){ 
                return accountId;
             }
             List<User> accIds = [select contact.accountid from user where id = : UserInfo.getuserid()];
             if(!accIds.IsEmpty()){
                 if(accIds[0].contact.accountId != null){
                     System.debug('Contact Account'+accIds[0].contact.accountId);
                     System.debug('Contact Account.contactId '+accIds[0].contactId);
                     accountId = accIds[0].contact.accountId;
                  } 

             } 
             
        }catch (Exception ex) {
            
        }
        return accountId;
    }
 

}