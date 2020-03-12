/**************************************************************************************************
*** Trigger Name             : OpportunityLineItemTrigger
*** Trigger Description      : Trigger will call the OpportunityLineItemTriggerHandler which will allow to
update the OpportunityLineItem Unit price for system administrator and user with sales operations admin 
custom permission and throws error for others users when they tried to change unit price of opportunitylineitem.
*** Author                   : Sujana M
*** Trigger Created Date     : 10/9/2019
*       Modified Date        :
*       Modified By          :
**************************************************************************************************/
trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after update) {
    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        OpportunityLineItemTriggerHandler.ensureUnitPriceNotChanged(trigger.new, trigger.isInsert ? null : trigger.oldMap);
    }
}