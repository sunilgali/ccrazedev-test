global class SSCartItemDAO implements ICartItemDAO{

    public interface ICartItemDAO{
        ccrz__E_CartItem__c getCartItemById(String cartId);
        List<ccrz__E_CartItem__c> getCartItemsByCartId(String cartId);
        List<ccrz__E_CartItem__c> getCartItemsByEncryptedCartId(String cartId);
        List<ccrz__E_CartItem__c> updateCartItems(List<ccrz__E_CartItem__c> cartItems);
    }

    public ccrz__E_CartItem__c getCartItemById(String cartId){
        return [SELECT Id, Name, ccrz__ItemTotal__c, ccrz__PercentDiscount__c,ccrz__E_CartItem__c.ccrz__ParentProduct__c, Coupon_Message__c, Billing_Product_Rate_Plan_ID__c,
                    ccrz__Product__r.ccrz__EndDate__c,  Provisioning_Product_ID__c, ccrz__Product__c,
                    ccrz__Price__c, ccrz__Product__r.Name, ccrz__ParentCartItem__c,
                    ccrz__Product__r.ccrz__SKU__c, ccrz__Product__r.ccrz__StartDate__c, ccrz__Product__r.Is_Trial_Product__c
                    , ccrz__Product__r.Trial_Period_in_Days__c, ccrz__Quantity__c
                    FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.Id =: cartId];
    }

    public List<ccrz__E_CartItem__c> getCartItemsByCartId(String cartId){
        return [SELECT Id, Name, ccrz__ItemTotal__c, ccrz__PercentDiscount__c, Billing_Product_Rate_Plan_ID__c,ccrz__E_CartItem__c.ccrz__ParentProduct__c,
                    ccrz__Price__c, ccrz__Product__r.Name, ccrz__Product__r.ccrz__StartDate__c, Coupon_Message__c,
                    ccrz__Product__r.ccrz__EndDate__c, Provisioning_Product_ID__c,  ccrz__Product__c,
                        ccrz__Product__r.ccrz__SKU__c, ccrz__ParentCartItem__c, ccrz__Product__r.Is_Trial_Product__c
                       , ccrz__Product__r.Trial_Period_in_Days__c, ccrz__Quantity__c
                        FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.Id =: cartId];
    }

    public List<ccrz__E_CartItem__c> getCartItemsByEncryptedCartId(String cartId){
        return [SELECT Id, Name, ccrz__ItemTotal__c, ccrz__PercentDiscount__c, Billing_Product_Rate_Plan_ID__c,ccrz__E_CartItem__c.ccrz__ParentProduct__c,
                    ccrz__Price__c, ccrz__Product__r.Name,   ccrz__Product__c, Coupon_Message__c,
                    ccrz__Product__r.ccrz__EndDate__c, ccrz__Product__r.ccrz__StartDate__c, Provisioning_Product_ID__c,
                        ccrz__Product__r.ccrz__SKU__c, ccrz__ParentCartItem__c, ccrz__Product__r.Is_Trial_Product__c, ccrz__Category__r.Name,
                       ccrz__Product__r.Trial_Period_in_Days__c, ccrz__Quantity__c
                        FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.ccrz__EncryptedId__c =: cartId];
    }

    public List<ccrz__E_CartItem__c> updateCartItems(List<ccrz__E_CartItem__c> cartItems){
        update cartItems;
        return cartItems;
    }
}