global class SSCustomMetadataTypeDAO {
    
    global static Map<String , String> getCountries(){
        Country_State_Config__mdt[] csConfigs = [SELECT MasterLabel, QualifiedApiName, Country_Code__c , Country_Name__c 
                                                 FROM Country_State_Config__mdt];
        Map<String, String> countries = new Map<String , String>();
        for(Country_State_Config__mdt csConfig : csConfigs){
            if(!countries.containsKey(csConfig.Country_Code__c)){
                countries.put(csConfig.Country_Code__c , csConfig.Country_Name__c);
            }
        }
		return countries;
    }
    
    global static Map<String , String> getStates(String countryCode){
        Country_State_Config__mdt[] csConfigs = [SELECT MasterLabel, QualifiedApiName, State_Code__c , State_Name__c  
                             FROM Country_State_Config__mdt where Country_Code__c =:countryCode order by QualifiedApiName];
        Map<String, String> states = new Map<String , String>();
        System.debug(countryCode + csConfigs);
        for(Country_State_Config__mdt csConfig : csConfigs){
            if(!states.containsKey(csConfig.State_Code__c)){
                states.put(csConfig.State_Code__c , csConfig.State_Name__c);
            }
        }
        return states;
    }
    
    global static String getLightningHostURL(){ 
        Callout_Configuration__mdt[] cConfig = [SELECT Source_URL__c 
                               FROM Callout_Configuration__mdt where QualifiedApiName = : Label.SSCybersourceSilentPost];
        return cConfig[0].Source_URL__c;
	}
    
    global static Callout_Configuration__mdt getSilentPostConfig(){ 
        Callout_Configuration__mdt[] cConfigs = [SELECT MasterLabel, QualifiedApiName, Access_Key__c , Authorization__c , 
                   Client_Secret__c , Client_Secret_1__c , Endpoint_URL__c, Profile_Id__c , Recipient_Page__c ,
                   Source_URL__c , Target_URL__c , Payment_Method__c FROM Callout_Configuration__mdt 
                                                where QualifiedApiName = : Label.SSCybersourceSilentPost];
        return cConfigs[0];
	}
    
    global static Callout_Configuration__mdt getCybersourceSOAPConfig(){
        Callout_Configuration__mdt[] cConfigs = [SELECT MasterLabel, QualifiedApiName, Endpoint_URL__c, Username__c,
                   Client_Secret__c , Client_Secret_1__c, HTTP_Method__c , Profile_Id__c 
                                    FROM Callout_Configuration__mdt where QualifiedApiName = : Label.SSCybersourceSOAP];
        return cConfigs[0];
    }
    
    global static String getCountryCurrency(String countryCode){
        Country_State_Config__mdt[] csConfigs = [SELECT Country_Currency__c FROM Country_State_Config__mdt 
                                                 where Country_Code__c =:countryCode LIMIT 1];
        return csConfigs[0].Country_Currency__c;
    }


}