/****************************************************************************************************************************
*** Class Name          	 :  CaseTriggerHelperTest 
*** Author                   :  Hanumanth Reddy K
*** Class Created Date     	 :	10/11/2019
*		Modified Date        :	1/6/2020
*		Modified By          :  Nagajuna G
******************************************************************************************************************************/
@isTest
public class CaseTriggerHelperTest {
    
    static testMethod Void caseCreationTest(){
        List<Case> caseList = new List<Case>();
        Case caseRecord =new Case();
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Boomi Support Case').getRecordTypeId();
        caseRecord.RecordTypeId =caseRecTypeId;
        caseRecord.status ='New';
        caseRecord.Origin = 'Boomi';
        caseRecord.Notify_User__c = false;
        caseList.add(caseRecord);
        insert caseList;
    }
    public static testMethod void caseUpdationtest(){
        case caseRec = new case();
        caseRec.Notify_User__c = false;
        caseRec.Customer_Name__c = 'test';
        caseRec.Customer_Email__c = 'test@gmail.com';
        caseRec.Status = 'New';
        insert caseRec;
        caserec.Notify_User__c = true;
        update caseRec;
    }
}