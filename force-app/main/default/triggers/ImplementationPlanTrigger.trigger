/*****************************************************************************************************************
*** Class Name               :  ImplementationPlanTrigger
*** Class Description        :  

*** Author                   :  Rahim Shariff
*** Class Created Date       :  29/10/2019
*       Modified Date        :
*       Modified By          :
******************************************************************************************************************/
trigger ImplementationPlanTrigger on Implementation_Plan__c (before insert, after insert) {
    if (trigger.isBefore && trigger.isInsert) {
        ImplementationPlanTriggerHandler.setDefaults(trigger.new);
    } else if (trigger.isAfter && trigger.isInsert) {
        ImplementationPlanTriggerHandler.copyFilesFromTemplate(trigger.new);
        ImplementationPlanTriggerHandler.spawnTasks(trigger.new);
    }
}