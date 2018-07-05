public class ssAdminConfig_BaseComponentcontoller {
   @AuraEnabled
    public static List<String> getStorefront(){
        List<String> Strorefront=SSCartService.getallStorefronts();
        return Strorefront;
    }
}