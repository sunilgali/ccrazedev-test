global class SSContactDAO implements IContactDAO{

    public interface IContactDAO{
        Contact getContactById(String id);
        List<Contact> updateContacts(List<Contact> contacts);
        List<Contact> insertContacts(List<Contact> contacts);
        List<Contact> getContactsByAccountId(String accountId);
    }

    public Contact getContactById(String id){
        return [SELECT Id, FirstName, LastName, Email, 
                    MailingStreet, MailingCity, MailingState, MailingPostalCode,
                    Account.Name, Account.Id, Account.BillingStreet FROM Contact WHERE Id =: id];
    }

    public List<Contact> getContactsByAccountId(String accountId){
        return [SELECT Id, FirstName, LastName, Email, 
                    MailingStreet, MailingCity, MailingState, MailingPostalCode,
                    Account.Name, Account.Id, Account.BillingStreet FROM Contact WHERE AccountId =: accountId];
    }

    public List<Contact> updateContacts(List<Contact> contacts){
        update contacts;
        return contacts;
    }

    public List<Contact> insertContacts(List<Contact> contacts){
        insert contacts;
        return contacts;
    }
}