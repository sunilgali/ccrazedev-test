global class CSSAccountHelper {
    
    global Static CSSAccountModel createAccount(String accountName, String userLocale, String userCurrency, CSSAddressModel billTo) {   
                              
        Account accountInfo = new Account();
        CSSAccountModel accountModel = new CSSAccountModel();
        try{        
            accountInfo.Name = accountName;
             //Using a single address Line
                accountInfo.BillingStreet = billTo.streetAddress;
                accountInfo.BillingCity = billTo.city;
                accountInfo.BillingState = billTo.state;
                accountInfo.BillingPostalCode = billTo.postalCode;
    
                accountInfo.ShippingStreet = billTo.streetAddress;            
                accountInfo.ShippingCity = billTo.city;
                accountInfo.ShippingState = billTo.state;
                accountInfo.ShippingPostalCode = billTo.postalCode;
                           
            if (billTo != null) {
                accountInfo.BillingCountry = billTo.country;
                accountInfo.ShippingCountry = billTo.country;                
            }
                
            accountInfo.CurrencyIsoCode = userCurrency;
            Locale__c accountLocaleObj = fetchCountryLocale(userLocale);
            if(accountLocaleObj!=null) {
                accountInfo.Locale__c = accountLocaleObj.Id;
            }
            
            //accountInfo.Phone= contact.phone;
      
            insert accountInfo;
            
          accountModel.accountId = accountInfo.Id;
          accountModel.accountName = accountInfo.Name;
          return accountModel;
        }
        catch(Exception ex)
        {
            System.debug('SSAccountHelper: createAccount: exception ' + ex.getMessage());
            throw new CSSAccountException(CSSAccountException.EXCEPTION_CREATE_ACCOUNT);
        }
        
    }
    
    /*
     * @description Method to fetch an account by accountId
     * @param		accountId		salesforce Account Id.
     * @return		Returns the data populated in a Custom Model class with the Account info
     */
    global Static CSSAccountModel getAccount(String accountId) {
         CSSAccountModel accountModel = new CSSAccountModel();
        try{
         Account account =  [SELECT Id, Name, (SELECT Id,firstName, lastName, email, phone, MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode FROM Contacts where AccountId =: accountId) FROM Account WHERE Id =: accountId LIMIT 1];
       
        accountModel.accountId = account.Id;
        accountModel.accountName = account.Name;
     
       // accountModel.billingContact.firstName = account.firstName;         
        }
         catch (Exception ex) {}
        return accountModel;
    } 
    
     /*
     * @description Method to update an account in salesforce
     * @param		accountId			salesforce Account Id
     * @param		name				Account Name
     * @param       userLocale          UserLocale like en_GB
     * @param       userCurrency        UserCurrency 
     * @param       contact             Custom Model class with the Contact Related info
     * @param       billTo              Custom Model class with the Address Related info
     * @return		Returns the data populated in a Custom Model class with the Account info
     */
    global Static CSSAccountModel updateAccount(String accountId, String accountName, String userCurrency, String userLocale, CSSAddressModel billTo) {
                                     
        Account accountInfo = [SELECT id FROM Account WHERE Id=:accountId LIMIT 1]; 
        CSSAccountModel accountModel = new CSSAccountModel();                          
        try{    
            
            Locale__c accountLocaleObj = fetchCountryLocale(userLocale);
            if(accountLocaleObj!=null) {
                accountInfo.Locale__c = accountLocaleObj.Id;   
            }
            
            if (!String.isBlank(accountName)) {
                accountInfo.Name = accountName;            
            }
                      
            if (billTo != null) {
           
                accountInfo.BillingStreet = billTo.streetAddress;
                accountInfo.BillingCity = billTo.city;
                accountInfo.BillingState = billTo.state;
                accountInfo.BillingCountry = billTo.country;
                accountInfo.BillingPostalCode = billTo.postalCode;
    
               
                accountInfo.ShippingStreet = billTo.streetAddress;            
                accountInfo.ShippingCity = billTo.city;
                accountInfo.ShippingState = billTo.state;
                accountInfo.ShippingCountry = billTo.country;
                accountInfo.ShippingPostalCode = billTo.postalCode;
            }

            if (!String.isBlank(userCurrency)) {
                accountInfo.CurrencyIsoCode = userCurrency;
            }
                
            update accountInfo;
           accountModel.accountId = accountInfo.Id;
           accountModel.accountName = accountInfo.Name;
           return accountModel; 
        }
        catch(Exception ex)
        {
            System.debug('SSAccountHelper: updateAccount: exception ' + ex.getMessage());
            throw new CSSAccountException(CSSAccountException.EXCEPTION_UPDATE_ACCOUNT);
        }
                                    
    }
    
     global Static Locale__c fetchCountryLocale(String strCountryLocale){
        Locale__c localeObject = null;
        List<Locale__c> lstLocale =  [Select id,Name from Locale__c where name=:strCountryLocale];
       
        if(lstLocale!=null && lstLocale.size()>0)
        {
            localeObject = lstLocale[0];
        }
        return localeObject;
    }
    
}