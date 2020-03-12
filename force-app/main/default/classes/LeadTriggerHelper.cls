/*****************************************************************************************************
*** Class Name               :  LeadTriggerHelper
*** Class Description        :  Class for handling the processing of leads.
*** Author                   :  Will Craig
*** Class Created Date       :  11/5/2019
*       Modified Date        :  01/Jan/2020
*       Modified By          :  Vinay K
******************************************************************************************************/

public class LeadTriggerHelper {
    
    /*************************************************************************************************************
*** Method Name             : assignLeadOwner
*** Method Description      : 1. Lead Assignment record where the State and Lead Interest matches what is 
listed in the lead
2. Once it finds the record, it should use the id of the user in the Lead
Owner field of that record and then go back to the Lead and update the 
owner of the Lead to be what was in the Lead Assignment record
3. If no match is found, assign lead to the GSS NA Unassigned Leads queue
***************************************************************************************************************/
    public static void assignLeadOwner(List < Lead > leadList) {
        //Start of CCRM-3180
        List < string > leadInterestList = new List < string > ();
        //End of CCRM-3180
        List < string > stateList = new List < string > ();
        ID leadRecTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('NA').getRecordTypeId();
        Id queueID = [Select Queue.Id, Queue.Name, Queue.Type from QueueSObject WHERE Queue.Type = 'Queue'
                      AND Queue.Name = 'GSS NA Unassigned Leads'
                     ].Queue.Id;
        Set < ID > currentRoleIds = (new Map < Id, UserRole > ([SELECT id, Name FROM UserRole
                                                                WHERE Name like '%NA%'
                                                                AND(NOT Name LIKE '%NA Sales Rep%')
                                                                AND(NOT Name LIKE '%APAC%') AND(NOT Name LIKE '%EMEA%')
                                                                 //Start of CCRM-3387
                                                                AND(NOT Name LIKE '%GPM NA%') 
                                                                 //End of CCRM-3387
                                                               ])).keySet();
        try {
            for (Lead ld: leadList) {
                if (ld.RecordTypeId == leadRecTypeId) {
                    //Start of CCRM-3477
                    if (currentRoleIds.contains(UserInfo.getUserRoleId())) {
                        ld.ownerId = queueID;
                    }
                    if (ld.ownerId == queueID) {
                        //End of CCRM-3477

                        leadInterestList.add(ld.Lead_Interest__c);
                        stateList.add(ld.StateCode);
                    }
                }
            }
            if (!leadInterestList.isEmpty() && !stateList.isEmpty()) {
                //Start of CCRM-3180
                List < Lead_Assignment__c > laList = [SELECT Id, OwnerId, Lead_Interest__c, Lead_Owner__c, State__c FROM Lead_Assignment__c
                                                      WHERE Lead_Interest__c IN: leadInterestList AND State__c IN: stateList
                                                     ];
               system.debug('enter');
                //End of CCRM-3180
                for (Lead ld: leadList) {
                    if (ld.OwnerId == queueID && ld.RecordTypeId == leadRecTypeId) {
                        for (Lead_Assignment__c la: laList) {
                            
                            if (ld.Lead_Interest__c == la.Lead_Interest__c && ld.StateCode == la.State__c) {
                                   system.debug('enter'); 
                                ld.OwnerId = la.Lead_Owner__c;
                                break;
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            String inputFromMethodParameters = CaptureInputFromApexMethod.captureAndReturnInput(string.valueOf('List<Lead>'), string.valueOf(leadList), null, null, null, null, null, null, null, null);
            CatchAndPublishExceptionEvent.getExceptionDetails(e, UserInfo.getUserId(), null, null, inputFromMethodParameters);
        }
    }
    /*************************************************************************************************************
*** Method Name             : convertedDateUpdation
*** Method Description      : After Lead is converted to Account the Converted Date will be update to today date 
***************************************************************************************************************/
    public static void convertedDateUpdation(List < Lead > leadList) {
        List < Account > accList = new List < Account > ();
        Set < ID > leadIdSet = new Set < ID > ();
        
        for (Lead lead: leadList) {
            if (lead.IsConverted) {
                leadIdSet.add(lead.ConvertedAccountId);
            }
            List < Account > newAccList = [SELECT ID, Name, Converted_Date__c FROM Account WHERE Account.Id =: leadIdSet];
            for (Account acc: newAccList) {
                if ((acc.Converted_Date__c == null)) {
                    acc.Converted_Date__c = system.today();
                    accList.add(acc);
                }
            }
            //Start of CCRM-3149
            If(accList.Size() > 0) {
                update accList;
                //End of CCRM-3149
            }
            
        }
    }
}