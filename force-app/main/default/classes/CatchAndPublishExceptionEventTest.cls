@istest
public class CatchAndPublishExceptionEventTest {
      public static Testmethod void testexeception(){
       Contact acc1 =new Contact();
       acc1.LastName='test';
          //acc1.Company_Region__c ='APAC';
          acc1.CurrencyIsoCode ='USD';
         // acc1.Covetrus_Customer_Number__c ='123456';
       //acc1.Test_Valid__c=true;
       insert acc1;
        Profile pro = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       
      
          User usr = new User(Alias = 'test', Email='reassignmenttrigger@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='assignment', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US',ProfileId = pro.Id,TimeZoneSidKey='America/Los_Angeles', UserName='reassignment@testorg.com',isActive=true);
       
        insert usr;
        String userID=usr.Id;    
        
       List<contact> rec= new List<contact>();
      rec.add(acc1);
       system.debug('rec'+rec);
          
       try{    
           account acc =new account();
           INSERT ACC;
       }catch(exception e){
       CatchAndPublishExceptionEvent.getExceptionDetails(e, 'userID', rec, acc1 ,null);
      
       }
    }
    
    
}