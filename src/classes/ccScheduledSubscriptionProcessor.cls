global with sharing class ccScheduledSubscriptionProcessor implements Schedulable{
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new cc_batch_SubscriptionProcessor('Microsoft',null,true));
    }
}