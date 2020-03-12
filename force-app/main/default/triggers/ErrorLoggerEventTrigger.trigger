/**************************************************************************************************
*** Trigger Name           : ErrorLoggerEventTrigger
*** Trigger Description    : whenever error logger event is published.The trigger  will fire and it will create record 
                              on error logger object
*** Author                 : Coreflex Solutions
*** Class Created Date     : 
*** Configurable Parameters:
*        End Point URL     :
*        Custom Labels Used:
*        Custom Object Used: 
*** Change Management      :
*        Change #          : 
*        Change Description:
*        Modified Date     :
*        Modified By       :
**************************************************************************************************/

trigger ErrorLoggerEventTrigger on Error_Logger_Event__e (after insert) {
    List<Error_Logger__c> errorLoggerList = new List<Error_Logger__c>();
    System.debug('Error_Logger_Event__e Trigger executing');
    for(Error_Logger_Event__e event : Trigger.New){
        
        Error_Logger__c errorLogger = new Error_Logger__c();
        if(event.Component_Name__c.contains('Trigger.')){
            errorLogger.Component_Type__c ='Apex Trigger';
        }else{
            errorLogger.Component_Type__c ='Apex Class';
        }
        errorLogger.Component_Name__c = event.Component_Name__c;
        errorLogger.Error_Message__c = event.Error_Message__c;
        errorLogger.Object_Name__c = event.Object_Name__c;
        errorLogger.TransactionDateTime__c = String.valueOf(event.TransactionDateTime__c);
        errorLogger.Brief_Description__c = event.Brief_Description__c;
        errorLogger.User_Id__c = event.User_Id__c;
        errorLogger.User_Name__c = event.User_Id__c;
        errorLogger.Input__c = event.Input__c;
        errorLogger.Status__c = 'Open';
        errorLoggerList.add(errorLogger);
    }
    insert errorLoggerList;
}