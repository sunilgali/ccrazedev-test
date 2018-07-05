global class SSCartDAO implements ICartDAO{

    public interface ICartDAO{
        ccrz__E_Cart__c getCartById(String cartId);
        ccrz__E_Cart__c getCartByParentCartId(String parentCartId);
        List<ccrz__E_Cart__c> getCartsByIds(List<String> cartIds);
        ccrz__E_Cart__c getCartByEncryptedId(String cartId);
        List<ccrz__E_Cart__c> getCartsByEncryptedIds(List<String> cartIds);
        ccrz__E_Cart__c updateCartWithTaxAmount(ccrz__E_Cart__c cart, Decimal taxAmount);
        List<ccrz__E_Cart__c> updateCarts( List<ccrz__E_Cart__c> carts);

    }   

    public ccrz__E_Cart__c getCartById(String cartId){
        return [SELECT Id, Transaction_Type__c, ccrz__TotalAmount__c, Parent_Cart__c,
            ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, ccrz__CartStatus__c,
                ccrz__TotalQuantity__c, ccrz__Contact__c, ccrz__Account__c, 
                ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, ccrz__BuyerEmail__c, ccrz__BuyerCompanyName__c,
                Name, ccrz__EncryptedId__c
                    FROM ccrz__E_Cart__c 
                        WHERE Id =: cartId LIMIT 1];
    }

    public ccrz__E_Cart__c getCartByParentCartId(String parentCartId){
        return [SELECT Id, ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, ccrz__BuyerEmail__c, ccrz__BuyerCompanyName__c FROM ccrz__E_Cart__c WHERE Parent_Cart__c =: parentCartId LIMIT 1];
    }

    public List<ccrz__E_Cart__c> getCartsByIds(List<String> cartIds){
        return [SELECT Id, Transaction_Type__c, ccrz__TotalAmount__c, ccrz__CartStatus__c,
            ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, ccrz__Contact__c, ccrz__Account__c, 
            ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, ccrz__BuyerEmail__c, ccrz__BuyerCompanyName__c,
            Name, ccrz__EncryptedId__c, Parent_Cart__c
                    FROM ccrz__E_Cart__c
                        WHERE Id IN : cartIds];
    }

    public ccrz__E_Cart__c getCartByEncryptedId(String encryptedId){
        return [SELECT Id, Transaction_Type__c,  ccrz__TotalAmount__c, ccrz__CartStatus__c,
            ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, ccrz__TotalQuantity__c, ccrz__Contact__c, ccrz__Account__c, 
            ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, ccrz__BuyerEmail__c, ccrz__BuyerCompanyName__c,
            Name, ccrz__EncryptedId__c, Parent_Cart__c
                    FROM ccrz__E_Cart__c
                        WHERE ccrz__EncryptedId__c =: encryptedId LIMIT 1];
    }

    public List<ccrz__E_Cart__c> getCartsByEncryptedIds(List<String> encryptedIds){
        return [SELECT Id, Transaction_Type__c,  ccrz__TotalAmount__c, ccrz__CartStatus__c,
            ccrz__SubtotalAmount__c, ccrz__TaxAmount__c, ccrz__TotalQuantity__c, ccrz__Contact__c, ccrz__Account__c, 
            ccrz__BuyerFirstName__c, ccrz__BuyerLastName__c, ccrz__BuyerEmail__c, ccrz__BuyerCompanyName__c,
            Name, ccrz__EncryptedId__c, Parent_Cart__c
                    FROM ccrz__E_Cart__c 
                        WHERE ccrz__EncryptedId__c IN : encryptedIds];
    }

    public List<ccrz__E_Cart__c> updateCarts( List<ccrz__E_Cart__c> carts){
        update carts;
        return carts;
    }

    public ccrz__E_Cart__c updateCartWithTaxAmount(ccrz__E_Cart__c cart, Decimal taxAmount){
        update cart;
        return cart; 
    }
}