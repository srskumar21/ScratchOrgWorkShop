/***********************************************************************************************************
*** Class Name             :  AccountTrigger
*** Class Description      :  This trigger is invoked before Account record is updated by AccountTeamMember.  
*** Author                 :  Nagarjuna
*** Class Created Date     :  9/10/2019
*       Modified Date      :  01/28/2019
*       Modified By        :  Vinay
************************************************************************************************************/
trigger AccountTrigger on Account (before update,before insert,after update,after delete){
    Map<ID,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();                         
    if(Trigger.isBefore){
        if(Trigger.isInsert){                         
            AccountTriggerHelper.populateCovetrusCustomerAccountNumber(trigger.new);            
        }
        if(Trigger.isUpdate){  
            list<Account> accountList = new list<Account>();
            Account oldAccount;
            Map<Id,Account> accMap =new Map<Id,Account>();
            AccountTriggerHelper.validateFieldsForAccTeamUsers(trigger.newmap, trigger.oldmap);
            for(Account acc : trigger.new ){
                 oldAccount = trigger.oldMap.get(acc.Id);
                 accountList.add(acc);
            
                 if((acc.Associated_Line_of_Businesses__c != oldAccount.Associated_Line_of_Businesses__c)||(String.isBlank(acc.Associated_Line_of_Businesses__c))){
                    accMap.put(acc.id,acc);
                }
            }
            if(accMap.Size() > 0){
                AccountTriggerHelper.populateAssociatedLineOfBusiness(accMap,Trigger.oldmap);
            }
            if(AccountList.size()>0){
            	AccountTriggerHelper.populateCovetrusCustomerAccountNumber(accountList);  
            }
        }
    }
    if(Trigger.IsAfter){
        if(Trigger.isUpdate){
            Set<Id> setIds = new Set<Id>();
            for(Account acntRec : trigger.new){
                Account oldAccount = trigger.oldMap.get(acntRec.Id);
                if(rt_Map.get(acntRec.recordTypeID).getName().containsIgnoreCase('Covetrus Account') && 
                   rt_Map.get(oldAccount.recordTypeID).getName().containsIgnoreCase('Prospect')) {
                    setIds.add(acntRec.id);                   
                }
                
            }
            If(setIds.size()>0){
                AccountTriggerHelper.createOrderandOrderlines(setIds); }   
        }
        if(Trigger.isdelete){
            Set<Id> acntDelIds = new Set<Id>();
            Set<Id> covetrusAcntId = new Set<Id>();
       		ID recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Covetrus Account').getRecordTypeId();
            for(Account acntDelete :trigger.old){
                acntDelIds.add(acntDelete.MasterRecordId);
            }
            for(Account acnts :[Select id,RecordtypeId from Account Where ID=:acntDelIds]){
                if(acnts.RecordtypeId == recordTypeId)
                covetrusAcntId.add(acnts.id);
                
            }
             AccountTriggerHelper.createOrderandOrderlines(covetrusAcntId);  
        }      
    } 
    
}