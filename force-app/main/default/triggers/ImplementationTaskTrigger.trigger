/*****************************************************************************************************************
*** Class Name               :  ImplementationTaskTrigger
*** Class Description        :  

*** Author                   :  Vinay k
*** Class Created Date       :  20/11/2019
*       Modified Date        :
*       Modified By          :
******************************************************************************************************************/
trigger ImplementationTaskTrigger on Implementation_Task__c (before insert, before update, after insert, after update, after delete, after undelete) {
    if (trigger.isBefore && trigger.isInsert) {
        ImplementationTaskTriggerHandler.setDefaults(trigger.new);
    } else if (trigger.isBefore && trigger.isUpdate) {
        ImplementationTaskTriggerHandler.setDefaults(trigger.new, trigger.oldMap);
        ImplementationTaskTriggerHandler.markCompletedDate(trigger.new, trigger.oldMap);
    } if (trigger.isAfter && trigger.isInsert) {
        ImplementationTaskTriggerHandler.copyFilesFromTemplate(trigger.new);
        ImplementationTaskTriggerHandler.updatePlanDetails(trigger.new);
    } else if (trigger.isAfter && trigger.isUpdate) {
        ImplementationTaskTriggerHandler.updatePlanDetails(trigger.new, trigger.oldMap);
    } else if (trigger.isAfter && trigger.isDelete) {
        ImplementationTaskTriggerHandler.updatePlanDetails(trigger.old);
    } else if (trigger.isAfter && trigger.isUndelete) {
        ImplementationTaskTriggerHandler.updatePlanDetails(trigger.new);
    }
}