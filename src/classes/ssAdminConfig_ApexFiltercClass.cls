public class ssAdminConfig_ApexFiltercClass {
@AuraEnabled
    public static list<Apexclass> getTaxConfig(){
       list<Apexclass> values=[select name from Apexclass];
        return values;
    }
}