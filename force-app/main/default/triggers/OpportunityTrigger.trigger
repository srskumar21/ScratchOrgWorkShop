/**************************************************************************************************
*** Trigger Name             : OpportunityTrigger
*** Trigger Description      : Trigger will call the OpportunityTriggerHelper which in turn will 
                               update the Opportunity's price book based on Opportunity 
                               CurrencyIsoCode, Account Billing Country and Line of Business of LOB
*** Author                   : Sreenath Dhanireddy 
*** Trigger Created Date     : 29/07/2019
*       Modified Date        :9/2/2020
*       Modified By          :Hanumanth
*       Ticket Number        :CCRM-3788
**************************************************************************************************/

trigger OpportunityTrigger on Opportunity (before insert, before update, after Update) {
    
    if(trigger.isBefore) {
        if(trigger.isInsert){
            OpportunityTriggerHelper.updateOpportunityPriceBook(trigger.new); 
            OpportunityTriggerHelper.updateOpportunityOwner(trigger.new);
        }
        If(trigger.isUpdate){
            OpportunityTriggerHelper.updateOpportunityPriceBook(trigger.new);
              //Start of CCRM-3788
            OpportunityTriggerHelper.checkQuoteStatus(Trigger.new);
              //End of CCRM-3788
        }
    }
    
    if(trigger.isAfter){
        if(trigger.isUpdate){
            OpportunityTriggerHelper.assetCreationOppClosedWon(trigger.new, trigger.oldMap);
        }   
    }
}