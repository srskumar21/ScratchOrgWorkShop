/**************************************************************************************************
*** Class Name             : ImplementationTaskTriggerHandler
*** Author                 	    : Sreenath Dhanireddy
*** Class Created Date        : 29/07/2019
*		
**************************************************************************************************/
public class ImplementationTaskTriggerHandler {
    public static void markCompletedDate(List<Implementation_Task__c> tasks, Map<Id, Implementation_Task__c> oldTasks) {
        for (Implementation_Task__c t : tasks) {
            if (t.Status__c == 'Complete' && t.Status__c != oldTasks.get(t.Id).Status__c) {
                t.Completed_Date__c = System.today();
            }
        }
    }
    public static void setDefaults(List<Implementation_Task__c> tasks) {
        setDefaults(tasks, null);
    }
    public static void setDefaults(List<Implementation_Task__c> tasks, Map<Id, Implementation_Task__c> oldMpa) {
        for (Implementation_Task__c t : tasks) {
            t.Unique_Sequence__c = '' + t.Implementation_Plan__c + '-' + t.Sequence__c;
        }
    }
    public static void updatePlanDetails(List<Implementation_Task__c> tasks) {
        updatePlanDetails(tasks, null);
    }
    public static void updatePlanDetails(List<Implementation_Task__c> tasks, Map<Id, Implementation_Task__c> oldMap) {
        set<Id> plansTouched = new set<Id>();
        for (Implementation_Task__c t : tasks) {
            if (oldMap == null || t.Implementation_Plan__c != oldMap.get(t.Id).Implementation_Plan__c || t.Status__c != oldMap.get(t.Id).Status__c) {
                if (oldMap != null) plansTouched.add(oldMap.get(t.Id).Implementation_Plan__c);
                plansTouched.add(t.Implementation_Plan__c);
            }
        }
        if (!plansTouched.isEmpty()) {
	        List<Implementation_Plan__c> plansToUpdate = new List<Implementation_Plan__c>();
            for (Implementation_Plan__c ip : [select Id, Completed_Tasks__c, Total_Tasks__c, Actual_Go_Live_Date__c, (select Id, Status__c, Revenue_Recognition__c from Implementation_Task__r) from Implementation_Plan__c where Id in :plansTouched]) {
                Integer totalTasks = ip.Implementation_Task__r.size();
                Integer completedTasks = 0;
                Date actualGoLiveDate = ip.Actual_Go_Live_Date__c;
                for (Implementation_Task__c it : ip.Implementation_Task__r) {
                    if (it.Status__c == 'Complete') {
                        completedTasks++;
                        if (it.Revenue_Recognition__c == 'Software Go-Live Date' && actualGoLiveDate == null) actualGoLiveDate = System.today();
                    }
                }
                if (ip.Total_Tasks__c != totalTasks || ip.Completed_Tasks__c != completedTasks || ip.Actual_Go_Live_Date__c != actualGoLiveDate) {
                    plansToUpdate.add(new Implementation_Plan__c(
                        Id = ip.id,
                        Total_Tasks__c = totalTasks,
                        Completed_Tasks__c = completedTasks,
                        Actual_Go_Live_Date__c = actualGoLiveDate
                    ));
                }
            }
            if (!plansToUpdate.isEmpty()) update plansToUpdate;
        }
    }
    public static void copyFilesFromTemplate(List<Implementation_Task__c> plans) {
        set<Id> templateIds = new set<Id>();
        for (Implementation_Task__c ip : plans) {
            if (ip.Implementation_Task_Template__c != null) {
                templateIds.add(ip.Implementation_Task_Template__c);
            }
        }
        if (!templateIds.isEmpty()) {
            list<ContentDocumentLink> newCdls = new list<ContentDocumentLink>();
            for (ContentDocumentLink cdl : [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId in :templateIds]){
                for (Implementation_Task__c ip : plans) {
                    if (ip.Implementation_Task_Template__c == cdl.LinkedEntityId) {
                        newCdls.add(new ContentDocumentLink(
                            LinkedEntityId = ip.Id,
                            ShareType = 'V',
                            ContentDocumentId = cdl.ContentDocumentId
                        ));
                    }
                }
            }
            if (!newCdls.isEmpty()) insert newCdls;
        }
    }
}