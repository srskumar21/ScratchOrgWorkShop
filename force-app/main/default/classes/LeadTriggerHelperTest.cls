/**************************************************************************************************
*** Test Class Name             : LeadTriggerHelperTest
*** Author                 	    : Santosh Kumar
*** Trigger Created Date        : 29/07/2019
*		
**************************************************************************************************/
@IsTest
public class LeadTriggerHelperTest {
   
    @IsTest
    private static void convertedDateUpdationTest() {
        List<Account> accList = new List<Account>();
        Keystore__c key = new Keystore__c();
        key.name = '1234';
        insert key;
        ID recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Covetrus Account').getRecordTypeId();
        
        
        Account acc = new Account();
        acc.RecordTypeId =recordTypeId;
        acc.Name = 'Test AU'; // Default Account
        acc.BillingCountry = 'Australia';
        acc.BillingStreet = 'Richmond';
        acc.BillingCity = 'Banglore';
        acc.BillingState = 'QLD';
        acc.BillingPostalCode = '560016';
        acc.Company_Region__c = 'APAC';
        acc.Covetrus_Customer_Number__c = '1234';
        acc.Converted_Date__c = system.today();
        acc.Phone = '9182352449';
        acc.CurrencyIsoCode = 'AUD';
        acc.ShippingCountry = 'United States';
        acc.ShippingCity = 'Mumbai';
        acc.ShippingState = 'Alabama';
        acc.ShippingStreet = 'Santhi Nagar';
        acc.ShippingPostalCode = '560068';
        accList.add(acc);
        insert accList;
        //Account acc = TestDataFactory.testdata();
        
        Lead lead = new Lead();
        lead.Status = 'New';
        lead.LastName = 'Mark';
        //lead.Product_Category__c ='Client Communications';
        lead.Country = 'United States';
        //lead.CountryCode ='US';
        lead.Street = 'Tin factory';
        lead.City = 'Banglore';
        lead.PostalCode = '560067';
        lead.State ='California';
        // lead.StateCode ='CA';
        lead.Company = 'Coreflex';
        lead.Email = 'cfs@gmail.com';
        lead.Phone ='5567687';
        insert lead;
        acc.Converted_Date__c =System.today();
        update acc;
        lead.Status ='Converted';
        update lead;
        
        
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(lead.id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        
    }
  
    static testmethod void assignLeadOwnerTest(){
         User u ;
        Lead_Assignment__c leadAssgnment ;
         Lead leadRec ;
        User usr =[Select id from user where id =:Userinfo.getUserId()];
        system.runAs(usr){
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'NA Leader');
            insert r;
            
             u = new User();
            u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'GSS Sales - NA'].Id;
            U.UserRoleId = r.Id;
            u.LastName = 'last';
            u.Email = 'test1231@test.com';
            u.Username = 'test12342@test.com.' + System.currentTimeMillis();
            u.CompanyName = 'TEST';
            u.Title = 'title';
            u.Alias = 'alias';
            u.TimeZoneSidKey = 'America/Los_Angeles';
            u.EmailEncodingKey = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
            u.LocaleSidKey = 'en_US';
            Insert u;
        
       
         ID recordTypeIdNA = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('NA').getRecordTypeId();
        Id queueIDs = [Select Queue.Id, Queue.Name, Queue.Type from QueueSObject WHERE Queue.Type ='Queue' AND Queue.Name = 'GSS NA Unassigned Leads'].Queue.Id;
        leadAssgnment = new Lead_Assignment__c();
        leadAssgnment.Product_Category__c = 'Hardware';
        leadAssgnment.Lead_Interest__c = 'eVetPractice';
        leadAssgnment.State__c = 'AK';
        leadAssgnment.Lead_Owner__c =u.id;
        insert leadAssgnment; 
        
        leadRec = new Lead();
        leadRec.RecordTypeId=recordTypeIdNA;
        leadRec.Status = 'New';
        leadRec.LastName = 'Mark';
        leadRec.Country = 'United States';
        leadRec.CountryCode ='US';
        leadRec.Street = 'Tin factory';
        leadRec.City = 'Banglore';
        leadRec.PostalCode = '560067';
        leadRec.StateCode ='AK';
        leadRec.State ='Alaska';
        leadRec.Lead_Interest__c ='eVetPractice';
        leadRec.Company = 'Coreflex';
        leadRec.Email = 'cfs@gmail12378.com';
        leadRec.Phone ='5567687';
        leadRec.OwnerId =queueIDs;

        }
         system.runAs(u){ 
             leadRec.OwnerId =leadAssgnment.Lead_Owner__c;
             Insert leadRec; 
              	             
            }
    }
}