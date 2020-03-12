/****************************************************************************************************************************
*** Class Name          	 :  AccountTriggerHelperTest 
*** Author                   :  Nagarjuna
*** Class Created Date     	 :	9/10/2019
*		Modified Date        :	
*		Modified By          : 
******************************************************************************************************************************/
@isTest
public class AccountTriggerHelperTest {
    public static testMethod void updateAccountByAccTeamMemb(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        user testUser = new user();
        testUser.LastName = 'LIVESTON';
        testUser.FirstName='JASON';
        testUser.Alias = 'jliv';
        testUser.Email = 'jason.liveston@asdf.com';
        testUser.Username = 'bhanuprakash67238@gmail.com';
        testUser.ProfileId = profileId.id;
        testUser.TimeZoneSidKey = 'GMT';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LocaleSidKey = 'en_US';
        insert testUser;
        
        ID loginUserId = UserInfo.getUserId();
        user loginUser = [select id,name from user where Id =: loginUserId];
        Map<Id,Account> oldAccountMap = new Map<Id,Account>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        
        Keystore__c key = new Keystore__c();
        key.name = '111111';
        insert key;
        
        List<Account> accList = new List<Account>();
        Account covetAcc= TestDataFactory.testData();
        accList.add(covetAcc);
        List<AccountTeamMember> accTeamMembList = new List<AccountTeamMember>();
        AccountTeamMember accTeamMemb = new AccountTeamMember();
        accTeamMemb.AccountId = covetAcc.id;
        accTeamMemb.UserId = loginUserId;
        accTeamMemb.AccountAccessLevel = 'Read';
        accTeamMemb.CaseAccessLevel = 'Read';
        accTeamMemb.OpportunityAccessLevel = 'Read';
        insert accTeamMemb;
        accTeamMembList.add(accTeamMemb);
        accountMap.put(covetAcc.Id, covetAcc);
        
        covetAcc.ProVet_Pricing_Type__c = 'test';
        system.runAs(testUser){
            update covetAcc;
        }
        AccountTriggerHelper.validateFieldsForAccTeamUsers(accountMap, accountMap);
        AccountTriggerHelper.populateCovetrusCustomerAccountNumber(accList);
    }
    
    public static testmethod void orderCreationonTest(){
        TestDataFactory.testData1();        
    }  
    Static testmethod void mergeAccounts(){
         Account acc = new Account();
        acc.name ='Test';
        acc.ShippingCity ='California';
        acc.ShippingCountry ='United States';
        acc.ShippingPostalCode='30309';
        acc.ShippingState ='California';
        acc.ShippingStreet ='360 - 665 ST. ALBERT TRAIL';
        acc.phone ='32652537';
        acc.BillingCity ='California';
        acc.BillingCountry ='United States';
        acc.Billingpostalcode ='30309';
        acc.BillingState ='California';
        acc.BillingStreet='360 - 665 ST. ALBERT TRAIL';
       // acc.ShippingCountryCode ='US';
       // acc.BillingCountryCode ='US';
       // acc.BillingStateCode ='CA';
       // acc.shippingstatecode ='CA';
        acc.CurrencyIsoCode ='USD';
        acc.Company_Region__c ='NA';
        //acc.Converted_Date__c = system.today();
        acc.Covetrus_Customer_Number__c ='C12356';
        
        insert acc;
        List<Account> accList =new List<Account>();
        ID recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();

         Account acc1 = new Account();
        acc1.name ='Test';
        acc1.recordtypeid =recordTypeId;
        acc1.phone ='32652537';
        accList.add(acc1);
        insert accList;
        Database.MergeResult[] results = Database.merge(acc, accList, false);
    }
}