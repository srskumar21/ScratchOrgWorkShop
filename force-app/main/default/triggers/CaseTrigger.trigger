/*****************************************************************************************************************
*** Class Name               :  CaseTrigger
*** Class Description        :  This Trigger invokes CaseTriggerHelper when the Case record is Created/Updated
*** Author                   :  Hanumanth
*** Class Created Date       :  10/11/2019
*       Modified Date        :  1/6/2020
*       Modified By          :  Nagarjuna G
******************************************************************************************************************/
trigger CaseTrigger on Case (after insert, before insert, before update) {
    Set<Id> caseIdSet =new Set<Id>();
    if(trigger.isAfter && trigger.isInsert){
        for(Case caseId :trigger.new){
            caseIdSet.add(caseId.Id);
        }
        CaseTriggerHelper.assignCaseToBoomiQueue(caseIdSet);
    }
    if(trigger.isBefore){
        if(trigger.isInsert){
           CaseTriggerHelper.changeStatusForNewRecord(trigger.new); 
        }
        if(trigger.isUpdate){
            CaseTriggerHelper.updateStatusAndNotifyUser(trigger.oldMap, trigger.new);
        }
    }
}