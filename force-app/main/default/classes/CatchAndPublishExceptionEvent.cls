/**************************************************************************************************
*** Class Name             : CatchAndPublishExceptionEvent
*** Class Description      : Whenever exception is raised in org. we publish the error logger event
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

public class CatchAndPublishExceptionEvent {
    
        
    /**************************************************************************************************
*** Method Name             : getExceptionDetails
*** Method Description      : This method creates a event by using  the details provided
**********************************************************************************************************/
    
    public static void getExceptionDetails(Exception e, String userID, List<SObject> listOfRecords, sObject singleRecord, String inputFromMethodParameters){
        Schema.SObjectType sobjectType;
        string objectName = '';
        string briefDescription = '';
        string userDefinedInput = '';
        if(e.getTypeName().contains('System.DmlException')){
            Integer numErrors = e.getNumDml();
            for(Integer i=0;i<numErrors;i++) {
                briefDescription = briefDescription + ' ' + e.getDmlMessage(i);
            }   
        }else{
            briefDescription = e.getMessage();
        }
        
        if(inputFromMethodParameters != null){
            userDefinedInput = inputFromMethodParameters;
        }else if(listOfRecords != null){
            userDefinedInput = String.valueOf(listOfRecords);
        }else if(singleRecord != null){
            userDefinedInput = String.valueOf(singleRecord);
        }
        
        if(singleRecord != null){
            objectName =String.valueOf(singleRecord.getSObjectType());
        }
        if(listOfRecords !=null){
            objectName = String.valueOf(listOfRecords.getSObjectType());
        }
        
        Error_Logger_Event__e errorEvent = new Error_Logger_Event__e(Component_Name__c=e.getStackTraceString(),
                                                                     User_ID__c = userID,
                                                                     Object_Name__c =objectName,
                                                                     Error_Message__c = String.valueOf(e),
                                                                     Brief_Description__c = briefDescription,
                                                                     TransactionDateTime__c = system.now(),
                                                                     Input__c = userDefinedInput
                                                                    );
        
        Database.SaveResult eventResult = EventBus.publish(errorEvent);
        if (eventResult.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : eventResult.getErrors()) {
                System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
            }
        }
    }
}