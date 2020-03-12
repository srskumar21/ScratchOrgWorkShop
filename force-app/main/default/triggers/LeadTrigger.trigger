/**************************************************************************************************
*** Trigger Name             : LeadTrigger
*** Trigger Description      : 
*** Author                   : Santosh Kumar
*** Trigger Created Date     : 29/07/2019
*       Modified Date        :
*       Modified By          :
**************************************************************************************************/
trigger LeadTrigger on Lead (before insert, before update, after insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            // Before Insert
            LeadTriggerHelper.assignLeadOwner(trigger.new);
        }
    }
    if(trigger.isAfter){
        if(trigger.isUpdate){
            //After Update
           LeadTriggerHelper.convertedDateUpdation(trigger.new);
        }       
    }
}