/**************************************************************************************************
*** Class Name             : OpportunitylineItemTriggerHelper
*** Class Description      : This Helper class is invoked from the trigger when trigger events are
                             fired.
*** Author                 : Sujana M
*** Class Created Date     : 10/9/2019
*            Modified Date : 12/24/2019
*            Modified By   : Sujana M
*            
**************************************************************************************************/
public class OpportunityLineItemTriggerHandler {
    /************************************************************************************************
*** Method Name             : ensureUnitPriceNotChanged
*** Method Description      : This method is to fire error when unit price of opportunity lineitem has been changed by 
Users apart from system administrator and user with sales operations admin custom permission.
**************************************************************************************************/
    public static void ensureUnitPriceNotChanged(list<OpportunityLineItem> olis, Map<Id, OpportunityLineItem> oldOLIs) {
        Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()];
        //Start of CCRM-3284
        if (!Test.isRunningTest() && (FeatureManagement.checkPermission(system.Label.SalesOpsAdmin)||FeatureManagement.checkPermission(system.Label.GSS_Sales_NA) || ProfileName.Name==system.Label.System_Administrator)) return;
        //End of CCRM-3284
        set<Id> lookatOLI = new set<Id>();
        for (OpportunityLineItem oli : olis) {
            if ((oldOLIs == null || oli.UnitPrice != oldOLIs.get(oli.Id).UnitPrice)) {
                lookAtOLI.add(oli.Id);
            }
        }
        if (!lookAtOLI.isEmpty()) {
            map<Id, OpportunityLineItem> oliMap = new map<Id, OpportunityLineItem>(olis);
            for (OpportunityLineItem oli : [select Id, UnitPrice, PricebookEntry.UnitPrice from OpportunityLineItem where PricebookEntry.UnitPrice > 0 and Id in :lookAtOLI]) {
                if (oli.UnitPrice != oli.PricebookEntry.UnitPrice) {
                    oliMap.get(oli.Id).addError('You cannot update the price of a Product which has a price already listed');
                }
            }
        }
    }
}