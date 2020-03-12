/**************************************************************************************************
*** Trigger Name           :  LineOfBusinessAccountTrigger
*** Class Description      :  This trigger is invoked before Line Of Business Account record is 
							  inserted, updated or deleted.  
*** Author                 :  Sivakrishna
*** Class Created Date     :  8/7/2019
*		Modified Date      :  9/20/2019
*		Modified By        :  Nagarjuna
**************************************************************************************************/
trigger LineOfBusinessAccountTrigger on Line_Of_Business_Account__c (before insert, before update, before delete, after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        Account acc = [SELECT id FROM Account WHERE Name='Default Account'];
        for(Line_Of_Business_Account__c lobAccRecord: trigger.new){
            if(lobAccRecord.Account__c == null){
                lobAccRecord.Account__c=acc.id; 
            }
        }
        LineOfBusinessAccountTriggerHelper.insertAccountTeamForLOBAccount(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
       LineOfBusinessAccountTriggerHelper.updateAccTeamForLOBAccount(Trigger.oldMap,Trigger.newMap);
    }
    if(Trigger.isDelete && Trigger.isBefore){
        LineOfBusinessAccountTriggerHelper.deleteAccTeamMemb(Trigger.old);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        LineOfBusinessAccountTriggerHelper.doAfterUpdate(trigger.new, trigger.oldMap);
    }
}