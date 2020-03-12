@isTest
private class ccv_DataInterfaceGSS_TEST {

    @testSetup
    private static void testData () {
        Keystore__c keys = new Keystore__c();
        keys.name = '11111121';
        insert keys;
        string recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Covetrus Account').getRecordTypeId();
      
        Account acc = new Account();
        acc.RecordTypeId = recordtypeId;
        acc.name = 'Test123';
        acc.ShippingCity = 'Washington';
        acc.ShippingCountry = 'United States';
        acc.ShippingPostalCode = '303098';
        acc.ShippingState = 'washington';
        acc.Associated_Line_of_Businesses__c ='APAC';
        acc.ShippingStreet = '360 - 66555 ST. ALBERT TRAIL';
        acc.phone = '76386186';
        acc.BillingCity = 'Washington';
        acc.BillingCountry = 'United States';
        acc.Billingpostalcode = '303098';
        acc.BillingState = 'California';
        acc.BillingStreet = '360 - 66555 ST. ALBERT TRAIL';
        acc.CurrencyIsoCode = 'USD';
        acc.Company_Region__c = 'NA';
        acc.Covetrus_Customer_Number__c = 'C123567';
        
        insert acc;
         
        Map < String, String > asstRecMap = new Map < String, String > ();
        Asset_Record_Types__c asstRecType = new Asset_Record_Types__c();
        asstRecType.Name = 'Hardware';
        asstRecType.Product_Category__c = 'Hardware';
        asstRecType.Asset_Record_Type__c = 'Hardware';
        Insert asstRecType;
        
        asstRecMap.put(asstRecType.Name, asstRecType.Asset_Record_Type__c);
        
        List < Account > AccountList = new List < Account > ();
        
        contact con1 = new contact();
        con1.lastname = 'Test';
        con1.AccountId = acc.id;
        insert con1;
        
        
        Pricebook2 pbk2 = new Pricebook2(Name = 'GSS AU', IsActive = True, CurrencyIsoCode = 'AUD');
        insert pbk2;
        
        List < Line_of_Business__c > LOBList = new List < Line_of_Business__c > ();
        Line_of_Business__c lob1 = new Line_of_Business__c();
        lob1.Name = 'Test';
        lob1.Line_of_Business__c = 'GSS';
        lob1.Region__c = 'NA';
        
        insert lob1;
        
        Implementation_Plan_Template__c impPlanTempRec = new Implementation_Plan_Template__c(Name = 'Test', Line_of_Business__c = lob1.id);
        insert impPlanTempRec;
        
        List < Product2 > ProductList = new List < Product2 > ();
        Product2 prodct = new Product2();
        prodct.Name = 'TestProduct';
        prodct.IsActive = True;
        prodct.Region__c = 'APAC';
        prodct.Line_of_Business__c = 'GSS';
        prodct.Family = 'Hardware';
        prodct.CurrencyIsoCode = 'AUD';
        prodct.ProductCode = 'RXTest';
        prodct.Do_Not_Create_Asset__c = False;
        prodct.Implementation_Plan_Template__c = impPlanTempRec.id;
        insert prodct;
        
        List < PriceBookEntry > PriceBookEntryLists = new List < PriceBookEntry > ();
        PriceBookEntry pbeStandardd = new PriceBookEntry(UnitPrice = 1.5, UseStandardPrice = false, IsActive = true, Product2ID = prodct.ID, PriceBook2ID = System.Test.getStandardPricebookID());
        pbeStandardd.CurrencyIsoCode = 'AUD';
        PriceBookEntryLists.add(pbeStandardd);
        //insert pbeStandard;
        
        PriceBookEntry pbeCustoms = new PriceBookEntry(UnitPrice = 1.5, UseStandardPrice = false, IsActive = true, Product2ID = prodct.ID, PriceBook2ID = pbk2.ID);
        pbeCustoms.CurrencyIsoCode = 'AUD';
        PriceBookEntryLists.add(pbeCustoms);
        
        insert PriceBookEntryLists;
        
        User users = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@gmail.com',
            Username = 'puser000@gmail.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert users;
        VIOpportunity__c viOppty = new VIOpportunity__c();
        viOppty.SetupOwnerId = users.id;
        insert viOppty;
        
        
        List < Opportunity > OpportunityLists = new List < Opportunity > ();
        Opportunity oppty = new Opportunity();
        oppty.AccountID = acc.ID;
        oppty.CurrencyIsoCode = 'AUD';
        oppty.Name = 'Covertus Opportunity';
        oppty.Pricebook2ID = pbk2.ID;
        oppty.Line_of_Business__c = lob1.ID;
        oppty.CloseDate = system.today();
        oppty.StageName = 'Qualification';
        oppty.LeadSource = 'Sales';
        oppty.Lead_Sub_Source__c = 'Inbound';
        oppty.Type = 'New Customer';
        oppty.Amount = 10;
        oppty.Number_of_Vets__c = 2;
        oppty.Current_PIMS__c = 'Test';
        oppty.Number_of_Faxes_Week__c = 5;
        oppty.Competitive_ProvIDer__c = 'Test';
        oppty.Number_of_Client_E_mails__c = 4;
        oppty.Timeline_for_Decision__c = system.today();
        oppty.Demo_Completed_Date__c = system.today();
        oppty.Date_Paperwork_Sent__c = system.today();
        oppty.Date_Paperwork_Received__c = system.today();
        oppty.Decision_Maker_Present__c = True;
        oppty.Decision_Maker_Agreement__c = True;
        oppty.Surgical_Caseload_Revenue_Contribution__c = 'Less than 25%';
        oppty.OwnerId = viOppty.SetupOwnerId;
        OpportunityLists.add(oppty);
        
        insert OpportunityLists;
        
        
        List < Opportunitylineitem > OpportunitylineitemLists = new List < Opportunitylineitem > ();
        Opportunitylineitem oppLineItems = new Opportunitylineitem();
        oppLineItems.Description = 'test';
        oppLineItems.OpportunityID = OpportunityLists[0].ID;
        oppLineItems.Product2ID = prodct.ID;
        oppLineItems.PricebookEntryID = pbeCustoms.ID;
        oppLineItems.Quantity = 2;
        oppLineItems.UnitPrice = 1.5;
        OpportunitylineitemLists.add(oppLineItems);
        insert OpportunitylineitemLists;
        
        Quote qte = new Quote();
        qte.name = 'Test Quote';
        qte.OpportunityId = oppty.Id;
        //qt.AccountId =acc.Id;
        qte.ContactId = con1.id;
        qte.BillingCity = 'Atlanta';
        qte.BillingStreet = 'Test 1123';
        qte.BillingPostalCode = '30309';
        qte.ShippingCity = 'Atlanta';
        qte.ShippingStreet = 'Test 1123';
        qte.Status = 'Accepted';
        qte.Description = 'Test Descriptioon';
        qte.Pricebook2Id = pbk2.ID;
        qte.BillingName = 'Test';
        insert qte;
        
        QuoteLineItem qutLineItems = new QuoteLineItem();
        qutLineItems.Description = 'Test description';
        qutLineItems.PricebookEntryId = pbeCustoms.ID;
        qutLineItems.Product2Id = prodct.ID;
        qutLineItems.Quantity = 2;
        qutLineItems.UnitPrice = 1.5;
        qutLineItems.LineNumber__c = 2;
        qutLineItems.NestedLineNumber__c = '1T2T';
        qutLineItems.RecordId__c = 'TEST';
        
        qutLineItems.QuoteId = qte.id;
        
        insert qutLineItems;
        
        oppty.SyncedQuoteId =qte.id;
        update oppty;
        oppty.StageName = 'Closed Won';
        update oppty;
        acc.Associated_Line_of_Businesses__c=oppty.Line_of_Business__r.name;
        update acc;

        // Create Default Account so LOB trigger works
        Account defaultAccount = new Account ();
        defaultAccount.Name =  'Default Account';
        defaultAccount.ShippingCity = 'California';
        defaultAccount.ShippingCountry = 'United States';
        defaultAccount.ShippingPostalCode = '30309';
        defaultAccount.ShippingState = 'California';
        defaultAccount.Associated_Line_of_Businesses__c ='';
        defaultAccount.ShippingStreet = '360 - 665 ST. ALBERT TRAIL';
        defaultAccount.phone = '32652537';
        defaultAccount.BillingCity = 'California';
        defaultAccount.BillingCountry = 'United States';
        defaultAccount.Billingpostalcode = '30309';
        defaultAccount.BillingState = 'California';
        defaultAccount.BillingStreet = '360 - 665 ST. ALBERT TRAIL';
        defaultAccount.CurrencyIsoCode = 'USD';
        defaultAccount.Company_Region__c = 'NA';
        insert defaultAccount;

        // create lobs
        Line_Of_Business_Account__c lob = new Line_Of_Business_Account__c ();
        lob.Account__c = acc.id;
        lob.Name = acc.Name;
        lob.Legacy_ERP_Source_Id__c = 'test';
        lob.Legacy_ERP_Source__c = 'test';
        insert lob;

        // create tasks
        List<Task> tasks = new List<Task>();
        tasks.add(new Task(whatId = acc.id, Subject = 'Test Subject 1', ActivityDate = date.today()));

        insert tasks;

        // create events
        List<Event> Events = new List<Event>();
        Events.add(new Event(whatId = acc.id, Subject = 'Test Subject 1', StartDateTime = datetime.now(), EndDateTime = datetime.now()));

        insert events;
 
    }

    @isTest
    private static void full_TEST() {

        // warm up the converter
        ccv_DataInterfaceGSS converter = new ccv_DataInterfaceGSS ();

        // fetch accounts
        List < Account > accounts = [ SELECT Id, Covetrus_Customer_Number__c FROM Account ];

        string jsonString = converter.create(accounts[0].Covetrus_Customer_Number__c);
        ccv_SharedCustomerJSON jsonOutput = (ccv_SharedCustomerJSON) JSON.deserialize ( jsonString, ccv_SharedCustomerJSON.class );

        // Assert that the objects are created, and that the count of records created corresponds with the count found in the jsonoutput.

        System.debug(jsonOutput);
        System.assertEquals(accounts[0].Covetrus_Customer_Number__c, jsonOutput.practices[0].covetrusCustomerNumber);
        System.assertEquals(1, jsonOutput.practices.size());
        System.assertEquals(0, jsonOutput.practices[0].salesrepresentatives.size());
        System.assertEquals(1, jsonOutput.practices[0].opportunities.size());
        System.assertEquals(1, jsonOutput.practices[0].contacts.size());
        System.assertEquals(2, jsonOutput.practices[0].activities.size());

    }

}