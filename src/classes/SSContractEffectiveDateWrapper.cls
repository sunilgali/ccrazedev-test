public class SSContractEffectiveDateWrapper {
    
    String actualTimeZone;
    String actualDate;
    String actualBillingCycleDay;
    String convertedTimeZone;
    String convertedContractEffectiveDate;
    String convertedBillingCycleDay;
    
    public SSContractEffectiveDateWrapper() {
        this(0);
    }
        
    public SSContractEffectiveDateWrapper(Integer numberOfDays) {
        
        Datetime dateInCurrentZone = Datetime.now().addDays(numberOfDays);
        String contractEffectiveDate = dateInCurrentZone.date().format();
        String billingCycleDay = String.valueof(dateInCurrentZone.date().day());
        
        this.actualDate = dateInCurrentZone.date().format();
        this.actualTimeZone = UserInfo.getTimeZone().getDisplayName();
        this.actualBillingCycleDay = billingCycleDay;
        
        //Converting to EST
        // Get the New York time zone
        Timezone tz = Timezone.getTimeZone('America/New_York');
        this.convertedTimeZone = tz.getDisplayName();
        //Getting convertedContractEffectiveDate based on timezone
        System.debug('Number of days being passed :' + numberOfDays);
        ccrz.ccLog.log(LoggingLevel.DEBUG,'SAGE','Number of days being passed : : ' + numberOfDays);
        ccrz.ccLog.log(LoggingLevel.DEBUG,'SAGE','DateTime.now : : ' + Datetime.now());
        ccrz.ccLog.log(LoggingLevel.DEBUG,'SAGE','DateTime.now after adding number of days : : ' + Datetime.now().addDays(numberOfDays));
        ccrz.ccLog.log(LoggingLevel.DEBUG,'SAGE','DateTime.now after adding number of days and formatting : : ' + Datetime.now().addDays(numberOfDays).format('yyyy-MM-dd', tz.toString()));
        
        this.convertedContractEffectiveDate = Datetime.now().addDays(numberOfDays).format('yyyy-MM-dd', tz.toString());        
        //converting convertedContractEffectiveDate to simple Date object which provides .day() functionality to get the day of month on specified date regardles of local timezone.
        this.convertedBillingCycleDay = convertedContractEffectiveDate.split('\\-')[2];
    }
    
    public String getConvertedTimeZone(){
        return this.convertedTimeZone;
    }
    
    public String getConvertedContractEffectiveDate(){
        return this.convertedContractEffectiveDate;
    }
    
    public String getconvertedBillingCycleDay(){
        return this.convertedBillingCycleDay;
    }
    
    public String getActualTimeZone(){
        return this.actualTimeZone;
    }
    
    public String getActualDate(){
        return this.actualDate;
    }
    
    public String getActualBillingCycleDay(){
        return getDayToOrdinalMap().get(this.actualBillingCycleDay);
    }
    
    public Map<String,String> getDayToOrdinalMap(){
        Map<String,String> dayToOrdinalMap = new Map<String,String>();
        dayToOrdinalMap.put('1','1st');
        dayToOrdinalMap.put('2','2nd');
        dayToOrdinalMap.put('3','3rd');
        dayToOrdinalMap.put('4','4th');
        dayToOrdinalMap.put('5','5th');
        dayToOrdinalMap.put('6','6th');
        dayToOrdinalMap.put('7','7th');
        dayToOrdinalMap.put('8','8th');
        dayToOrdinalMap.put('9','9th');
        dayToOrdinalMap.put('01','1st');
        dayToOrdinalMap.put('02','2nd');
        dayToOrdinalMap.put('03','3rd');
        dayToOrdinalMap.put('04','4th');
        dayToOrdinalMap.put('05','5th');
        dayToOrdinalMap.put('06','6th');
        dayToOrdinalMap.put('07','7th');
        dayToOrdinalMap.put('08','8th');
        dayToOrdinalMap.put('09','9th');
        dayToOrdinalMap.put('10','10th');
        dayToOrdinalMap.put('11','11th');
        dayToOrdinalMap.put('12','12th');
        dayToOrdinalMap.put('13','13th');
        dayToOrdinalMap.put('14','14th');
        dayToOrdinalMap.put('15','15th');
        dayToOrdinalMap.put('16','16th');
        dayToOrdinalMap.put('17','17th');
        dayToOrdinalMap.put('18','18th');
        dayToOrdinalMap.put('19','19th');
        dayToOrdinalMap.put('20','20th');
        dayToOrdinalMap.put('21','21st');
        dayToOrdinalMap.put('22','22nd');
        dayToOrdinalMap.put('23','23rd');
        dayToOrdinalMap.put('24','24th');
        dayToOrdinalMap.put('25','25th');
        dayToOrdinalMap.put('26','26th');
        dayToOrdinalMap.put('27','27th');
        dayToOrdinalMap.put('28','28th');
        dayToOrdinalMap.put('29','29th');
        dayToOrdinalMap.put('30','30th');
        dayToOrdinalMap.put('31','31st');
        
        return dayToOrdinalMap;
    }
    public String getConvertedBillingCycleDayWithOrdinalSuffix(){
        return getDayToOrdinalMap().get(this.convertedBillingCycleDay);
    }
    
    
    public void setConvertedTimeZone(String convertedTimeZone){
        this.convertedTimeZone = convertedTimeZone;
    }
    
    public void setConvertedContractEffectiveDate(String convertedContractEffectiveDate){
        this.convertedContractEffectiveDate = convertedContractEffectiveDate;
    }
    
    public void setconvertedBillingCycleDay(String convertedBillingCycleDay){
        this.convertedBillingCycleDay = convertedBillingCycleDay;
    }
    
    
    //Setters for actuals   
    public void setActualTimeZone(String actualTimeZone){
        this.actualTimeZone = actualTimeZone;
    }
    
    public void setActualDate(String actualDate){
        this.actualDate = actualDate;
    }
    
    public void setActualBillingCycleDay(String actualBillingCycleDay){
        this.actualBillingCycleDay = actualBillingCycleDay;
    }
    
    public String toJsonString(){
        return JSON.serialize(this);
    }
    
}