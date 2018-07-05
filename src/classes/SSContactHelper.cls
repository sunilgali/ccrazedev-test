global class SSContactHelper {
    
/*
     * @description Method to create contact in salesforce
     * @param       accountId           Salesforce Account Id
     * @param       firstName           FirstName of the Contact
     * @param       billTo              Custom Model class with the Address Related info
     * @return      Returns a newly created Salesfoce Contact Id
     */
    global Static SSContactModel createContact(String accountId, String userLocale,String userCurrency,SSContactModel contactInfo, SSAddressModel address) {
     //  createContact(contactModel.firstName, contactModel.lastName,userLocale,userCurrency,contactModel.email,billTo); 
        Contact contact = new Contact(); 
        SSContactModel contactModel = new SSContactModel();
                           
        try{
                   
            
           /* Locale__c contactLocaleObj = fetchCountryLocale(userLochttps://ccrazedev-dev-ed.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#ale);
            if(contactLocaleObj!=null)
            {
                contactInfo.Locale__c = contactLocaleObj.Id;
            }*/
            contact.AccountId = accountId;
            contact.FirstName = contactInfo.firstName;
            contact.LastName =  contactInfo.lastName;
        
            if ((address != null)) {
                contact.MailingCity = address.city;
                contact.MailingCountry  = address.country;
                contact.MailingPostalCode = address.postalCode;
                contact.MailingState= address.state;
                contact.MailingStreet = address.streetAddress;            
                }   
            // Added email in the method signature
            contact.Email = contactInfo.email;
           contact.Phone = contactInfo.phone;
  
           insert contact;
            
           contactModel.firstName = contact.FirstName;
           contactModel.lastName = contact.LastName; 
           contactModel.email = contact.Email;
           contactModel.phone = contact.Phone;
           contactModel.contactId = contact.Id;
           
           system.debug('>>>>'+contactModel);
           SSAddressModel ssaddress = new SSAddressModel(); 
           ssaddress.city = contact.MailingCity;
          ssaddress.state = contact.MailingState; 
          ssaddress.country = contact.MailingCountry; 
          ssaddress.streetAddress = contact.MailingStreet; 
          ssaddress.postalCode = contact.MailingPostalCode;  
           
           contactModel.address = ssaddress;
           return contactModel;                    
        }
        catch(Exception ex)
        {
            System.debug('SSContactHelper: createContact: exception ' + ex.getMessage());
            throw new SSAccountException(SSAccountException.EXCEPTION_CREATE_CONTACT);
        }     
       
    } 
    
     /*
     * @description Method to update a contact in salesforce
     * @param       accountId           Salesforce AccountId
     * @param       contactInfo             Custom Model class with the Contact Related info
     * @param       billTo              Custom Model class with the Address Related info
     * @return      Returns updated ContactModel.
     */
    global Static SSContactModel updateContact(String accountId, SScontactModel contactInfo, String userLocale, String userCurrency,SSAddressModel address) {
        SSContactModel contactModel = new SSContactModel();
        try{        
        
         system.debug('SSContactHelper'+address);
         system.debug('SSContactHelper'+accountId);
         system.debug('SSContactHelper'+userLocale);
         system.debug('SSContactHelper'+userCurrency);
         
         system.debug('SSContactHelper'+contactInfo);
        
        
        
            Contact contact = [SELECT Id FROM Contact WHERE Id =: contactInfo.contactId];
           contact.AccountId = accountId;
            if (!String.isBlank(contactInfo.firstName)) {
                contact.FirstName = contactInfo.firstName;            
            }
            if (!String.isBlank(contactInfo.lastName)) {
                contact.LastName = contactInfo.lastName;            
            }
            if (address != null) {
                contact.MailingCity = address.city;
                contact.MailingCountry  = address.country;
                contact.MailingPostalCode = address.postalCode;
                contact.MailingState= address.state;
                contact.MailingStreet = address.streetAddress;            
            }
            if (!String.isBlank(contactInfo.email)) {
                contact.Email = contactInfo.email;
            }
           if (!String.isBlank(contactInfo.phone)) {
                contact.Phone = contactInfo.phone;
            }
            update contact;
           // Put a SOQL query to retrive below details
           contactModel.firstName = contact.FirstName;
           contactModel.lastName = contact.LastName; 
           contactModel.email = contact.Email;
           contactModel.phone = contact.Phone;
           contactModel.contactId = contact.Id;
           
           system.debug('SSContactHelper'+address);
           
           if (address != null){
               if(contactModel.address == null){
                   contactModel.address = new SSAddressModel();
               }
               contactModel.address.city = contact.MailingCity;
               contactModel.address.state = contact.MailingState; 
               contactModel.address.country = contact.MailingCountry; 
               contactModel.address.streetAddress = contact.MailingStreet; 
               contactModel.address.postalCode = contact.MailingPostalCode;  
           }
           return contactModel;           
                    
        }
        catch(Exception ex)
        {
            System.debug('SSAccountHelper: updateContact: exception ' + ex.getMessage());
            throw new SSAccountException(SSAccountException.EXCEPTION_UPDATE_CONTACT);
        }
    }  

 /*
     * @description Method to fetch Contact Info by ContactId
     * @param       contactId           Salesforce Contact Id
     * @return      Returns the data populated in a Custom Model class with the Contact info.
     */
    global Static SSContactModel getContact(String contactId) {
        SSContactModel contactModel = new SSContactModel();
        SSAddressModel addressModel = new SSAddressModel();
        try{        
            Contact contact = [SELECT Id, FirstName, LastName,MailingCity,MailingCountry,MailingPostalCode, MailingState, MailingStreet, Email, Phone FROM Contact WHERE Id =: contactId];
           
            contactModel.contactId = contact.Id;
            contactModel.firstName = contact.FirstName;
            contactModel.lastName = contact.LastName;
            contactModel.email = contact.Email;
            contactModel.phone = contact.Phone;
          /*  contactModel.address.streetAddress = contact.MailingStreet;
            contactModel.address.city = contact.MailingCity;
            contactModel.address.state = contact.MailingState;
            contactModel.address.country = contact.MailingCountry;
            contactModel.address.postalCode = contact.MailingPostalCode;*/
            addressModel.streetAddress = contact.MailingStreet;
            addressModel.city = contact.MailingCity;
            addressModel.state = contact.MailingState;
            addressModel.country = contact.MailingCountry;
            addressModel.postalCode = contact.MailingPostalCode;
            contactModel.address =addressModel;
            
            
        }
        catch(Exception ex){}
       return contactModel;
    }  
}