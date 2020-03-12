/*****************************************************************************************************************
*** Class Name               :  CaseTriggerHelper
*** Class Description        :  This CaseTriggerHelper is invoked by CaseTrigger when the Case record is Created.This class
                                is Assign the case Owner to "Boomi Support Queue" when case origin is 'Boomi'.                 
*** Author                   :  Hanumanth
*** Class Created Date       :  10/11/2019
*       Modified Date        :  1/23/2020
*       Modified By          :  Santosh Kumar P
******************************************************************************************************************/
public class CaseTriggerHelper {
    Private static string firstThreeDigitsQueueId = '00G';
 	Private static string firstThreeDigitsUserId = '005';
/***************************************************************************************************************
*** Method Name             : assignCaseToBoomiQueue
*** Method Description      : This method Assign the case Owner to "Boomi Support Queue" when case origin is 'Boomi'
							  by setting case assignment rule to truu.
*** JIRA Number				: CCRM-1518
********************************************************************************************************************/
    public static void assignCaseToBoomiQueue(Set<Id> caseIdSet){
        List<Case> caseList = new List<Case>(); 
        for(Case boomiCase : [SELECT Id,origin FROM Case WHERE Id in :caseIdSet AND origin =:System.Label.CaseOrigin]){ 
            Database.DMLOptions dmlOption = new Database.DMLOptions();
            dmlOption.assignmentRuleHeader.useDefaultRule = true;
            boomiCase.setOptions(dmlOption);
            caseList.add(boomiCase);            
        }
        if(caseList.size()>0){
            Upsert caseList;
        }
    }
    /***************************************************************************************************************
*** Method Name             : changeStatusForNewRecord
*** Method Description      : This method updates the status to 'In Progress' when the case is created manually
							  (by User) with the status as 'New'.
*** JIRA Number				: CCRM-3073
********************************************************************************************************************/
    public static void changeStatusForNewRecord(List<Case> newcaseList){
        List<Case> caseList = new List<Case>();
        for(Case cs : newcaseList){
            // Start of CCRM-3488 
            if(cs.Notify_User__c == false && string.valueOf(cs.OwnerId).startsWith(firstThreeDigitsUserId) &&
                cs.Status == Label.CaseStatusNew && cs.Comments==NULL){
                // End of CCRM-3488
                cs.Status = Label.CaseStatusInProgress;
            }
        }
    }
    /***************************************************************************************************************
*** Method Name             : updateStatusAndNotifyUser
*** Method Description      : This method updates the status to 'In Progress' when the case owner is changed from
							  Queue to User and also updates the Notify User field to 'false' when the prior value
							  is 'true' and case owner is User and case status not equals to 'Closed'.
*** JIRA Number				: CCRM-3073
********************************************************************************************************************/
    public static void updateStatusAndNotifyUser(Map<id,Case> oldCaseRecMap, List<Case> newCaseRecList){
        for(Case newCaseRec : newCaseRecList){
            if(newCaseRec.Notify_User__c == false && oldCaseRecMap.get(newCaseRec.id).OwnerId != newCaseRec.OwnerId &&
               string.valueOf(oldCaseRecMap.get(newCaseRec.id).OwnerId).startsWith(firstThreeDigitsQueueId) &&
               string.valueOf(newCaseRec.OwnerId).startsWith(firstThreeDigitsUserId)){
               newCaseRec.Status = Label.CaseStatusInProgress; 
            }
            if(newCaseRec.Notify_User__c == true && string.valueOf(newCaseRec.OwnerId).startsWith(firstThreeDigitsUserId) &&
               newCaseRec.Status != Label.CaseStatusClosed){
               newCaseRec.Status = Label.CaseStatusInProgress;
               newCaseRec.Notify_User__c = false;
            }
        }
    }
}