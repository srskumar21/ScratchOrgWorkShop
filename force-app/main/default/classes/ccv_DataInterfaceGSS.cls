// Class to handle operations related to converting native sObject data to JSON
// GSS Version

global class ccv_DataInterfaceGSS implements ccv_DataInterface {

    private string covetrusCustomerKey;
    
    // primary method to take a covetrus customer key and return in JSON structure
    global string create ( String covetrusCustomerKey ) {

        this.covetrusCustomerKey = covetrusCustomerKey;

        ccv_SharedCustomerJSON jsonData = new ccv_SharedCustomerJSON ();
        string jsonString;

        // check for empty key
        if ( String.isBlank ( this.covetrusCustomerKey )) {
            throw new ccv_ResponseException ( ccv_ResponseException.ErrorType.FATAL, 'Covetrus Customer Key is empty', null );
        }

        // fetch actual data
        //try {
            // Pull Accounts and necessary attributes.
            
            // create practice map indexed by account
            Map < ID, ccv_Practice > practiceAcctMap = buildPracticeMap ();

            // create opp map indexed by account
            Map < ID, List < ccv_Opportunity >> oppAcctMap = buildOpportunityMap ();

            // create salesRep map indexed by account
            Map < ID, List < ccv_SalesRepresentative >> salesRepAcctMap = buildSalesRepresentativeMap ();

            // create contact map indexed by account
            Map < ID, List < ccv_Contact >> contactAcctMap = buildContactMap ();

            // create task map indexed by account
            Map < ID, List < ccv_Activity >> taskAcctMap = buildTaskMap ();

            // create event map indexed by account
            Map < ID, List < ccv_Activity >> eventAcctMap = buildEventMap ();

            // create account summaries map indexed by account
            Map < ID, List < ccv_AccountSummary >> acctSumAcctMap = buildAccountSummaryMap ();

            // Loop through practices and add child elements based on account ID
            jsonData.practices = new List < ccv_Practice > ();
            jsonData.dataControl = new ccv_DataControl ();

            for ( ID accountId : practiceAcctMap.keySet ()) {
                // initialize all child arrays
                practiceAcctMap.get ( accountId ).opportunities         = new List < ccv_Opportunity            > ();
                practiceAcctMap.get ( accountId ).contacts              = new List < ccv_Contact                > ();
                practiceAcctMap.get ( accountId ).salesRepresentatives  = new List < ccv_SalesRepresentative    > ();
                practiceAcctMap.get ( accountId ).activities            = new List < ccv_Activity               > ();
                practiceAcctMap.get ( accountId ).accountSummaries      = new List < ccv_AccountSummary         > ();

                // set array values
                if ( oppAcctMap.containsKey ( accountId )) {
                    practiceAcctMap.get ( accountId ).opportunities.addAll ( oppAcctMap.get ( accountId ));
                }
                if ( contactAcctMap.containsKey ( accountId )) {
                    practiceAcctMap.get ( accountId ).contacts.addAll ( contactAcctMap.get ( accountId ));
                }
                if ( salesRepAcctMap.containsKey ( accountId )) {
                    practiceAcctMap.get ( accountId ).salesRepresentatives.addAll ( salesRepAcctMap.get ( accountId ));
                }
                if ( taskAcctMap.containsKey ( accountId )) {
                    practiceAcctMap.get ( accountId ).activities.addAll ( taskAcctMap.get ( accountId ));
                }
                if ( eventAcctMap.containsKey ( accountId )) {
                    practiceAcctMap.get ( accountId ).activities.addAll ( eventAcctMap.get ( accountId ));
                }
                if ( acctSumAcctMap.containsKey ( accountId )) {
                    practiceAcctMap.get ( accountId ).accountSummaries.addAll ( acctSumAcctMap.get ( accountId ));
                }
                
                // add the practice element to return 
                jsonData.practices.add ( practiceAcctMap.get ( accountId ));
                ccv_Practice practice = new ccv_Practice();
            }
            // convert to string
            jsonString = JSON.serialize ( jsonData );
        //} catch ( Exception e ) {
            // handle errors
        //    throw new ccv_ResponseException ( ccv_ResponseException.ErrorType.FATAL, 'Error in query for key: ' + covetrusCustomerKey + ' data: ' + e.getMessage (), e );
        //}
        
        return jsonString;
    }

    private Map < ID, ccv_Practice > buildPracticeMap () {

        // create the account map indexed by account.id
        Map < ID, ccv_Practice > pracAcctMap = new Map < ID, ccv_Practice > ();

        // fetch accounts and the fields necessary to build ccv_Practice
        List< Line_Of_Business_Account__c > accounts = new List < Line_Of_Business_Account__c > ([
                                                    SELECT id,
                                                    Name,
                                                    Account__c,
                                                    Account__r.Covetrus_Customer_Number__c,	
                                                    Billing_Address_Line_1__c,
                                                    Billing_Address_Line_2__c,
                                                    Billing_City__c,
                                                    Billing_State__c,
                                                    Billing_Postal_Code__c,
                                                    Billing_Country__c,
                                                    Number_of_Vets__c,
                                                    Phone__c,
                                                    Website__c
                                                    FROM Line_Of_Business_Account__c 
                                                    Where Account__r.Covetrus_Customer_Number__c =: covetrusCustomerKey
                                                ]);

        System.debug ( 'CCV - Practice - Raw DB Accounts ' + accounts );                                       
        // TODO: Remap below
        // Iterate through accounts, populating the practAcctMap with the fetched account information
        for ( Line_Of_Business_Account__c acct : accounts ) {
            if ( pracAcctMap.containsKey ( acct.id ) == false ) {
                // build the json object.
                ccv_Practice jsonPractice = new ccv_Practice();
                
                jsonPractice.covetrusCustomerNumber = acct.Account__r.Covetrus_Customer_Number__c;
                jsonPractice.systemOfRecord = 'GSS'; 
                jsonPractice.practiceName = acct.Name;
                jsonPractice.addressLine1 = acct.Billing_Address_Line_1__c;
                jsonPractice.addressLine2 = acct.Billing_Address_Line_2__c;
                jsonPractice.city = acct.Billing_City__c;
                jsonPractice.state = acct.Billing_State__c;
                jsonPractice.zipCode = acct.Billing_Postal_Code__c;
                jsonPractice.countryCode = acct.Billing_Country__c;
                jsonPractice.numberOfVets = String.valueOf ( acct.Number_of_Vets__c );
                jsonPractice.phone = acct.Phone__c;
                jsonPractice.website = acct.Website__c;
                pracAcctMap.put ( acct.account__c, jsonPractice );
            }
        }
        return pracAcctMap;
    }

    private Map < ID, List < ccv_Opportunity >> buildOpportunityMap () {

        // create opp map indexed by account
        Map < ID, List < ccv_Opportunity >> oppAcctMap = new Map < ID, List < ccv_Opportunity >> ();

        // Pull Opportunities and necessary attributes.
        List<Opportunity> opportunities = new List<Opportunity>([SELECT Id,
                                                                Name,
                                                                Type,  // Not Migrated for GSS
                                                                CloseDate,
                                                                Amount,
                                                                StageName,
                                                                AccountId
                                                                // CONTACT FULL NAME MISSING
                                                                FROM Opportunity
                                                                WHERE Account.Covetrus_Customer_Number__c	 =: this.covetrusCustomerKey]);

        System.debug ( 'CCV - Opportunity - Raw DB ' + opportunities );   
        for ( Opportunity opp : opportunities ) {
            if ( oppAcctMap.containsKey ( opp.AccountId ) == false ) {
                oppAcctMap.put ( opp.AccountId, new List < ccv_Opportunity > ());
            }
            // build the json object
            ccv_Opportunity jsonOpp = new ccv_Opportunity();
            jsonOpp.name = opp.name;
            jsonOpp.type = opp.type;
            jsonOpp.closeDate = String.valueOf ( opp.closeDate );
            jsonOpp.amount = opp.amount;
            jsonOpp.stageName = opp.stageName;
            // opportunity.contactFullName = opportunity.contactFullName;
            oppAcctMap.get ( opp.AccountId ).add ( jsonOpp );
        }

        return oppAcctMap;
    }

    // 1/27/2020 - There is no data in Account Teams fyi
    private Map < ID, List < ccv_SalesRepresentative >> buildSalesRepresentativeMap () {
        
        // create salesRep map indexed by account
        Map < ID, List < ccv_SalesRepresentative >> salesRepAcctMap = new Map < ID, List < ccv_SalesRepresentative >> ();
        /*
        // Pull Account Teams and necessary attributes
        List<AccountTeamMember> salesRepresentatives = new List<AccountTeamMember>([SELECT ID,
                                                                                    User.FirstName,
                                                                                    User.LastName,
                                                                                    User.Phone,
                                                                                    User.Userrole.RollupDescription,
                                                                                    User.Email,
                                                                                    AccountId
                                                                                    FROM AccountTeamMember
                                                                                    WHERE account.Covetrus_Customer_Number__c	 =: this.covetrusCustomerKey]);
        
        
        for ( AccountTeamMember salesRep : salesRepresentatives ) {
            if ( salesRepAcctMap.containsKey ( salesRep.AccountId ) == false ) {
                salesRepAcctMap.put ( salesRep.AccountId, new List < ccv_SalesRepresentative > ());
            }
            // build json object
            ccv_SalesRepresentative jsonSalesRep = new ccv_SalesRepresentative();
            jsonSalesRep.firstName =  salesRep.User.FirstName;
            jsonSalesRep.lastName = salesRep.User.LastName;
            jsonSalesRep.emailAddress = salesRep.User.Email;
            jsonSalesRep.phone = salesRep.User.Phone;
            jsonSalesRep.role = salesRep.User.Userrole.RollupDescription;
            salesRepAcctMap.get ( salesRep.AccountId ).add ( jsonSalesRep );
        }
        */
        return salesRepAcctMap;
    }

    private Map < ID, List < ccv_Contact >> buildContactMap () {
        // create contact map indexed by account
        Map < ID, List < ccv_Contact >> contactAcctMap = new Map < ID, List < ccv_Contact >> ();

        // Pull Contacts and necessary Attributes
        List<Contact> contacts = new List<Contact>([SELECT Id,
                                                    DoNotCall,
                                                    FirstName,
                                                    LastName,
                                                    Phone,
                                                    Email,
                                                    Title,
                                                    AccountId
                                                    FROM Contact
                                                    WHERE Account.Covetrus_Customer_Number__c	=: this.covetrusCustomerKey]);

        System.debug ( 'CCV - Contact - Raw DB Accounts ' + contacts ); 

        // iterate through contact list and add to contactmap
        for ( Contact con : contacts ) {
            if ( contactAcctMap.containsKey ( con.AccountId ) == false ) {
                contactAcctMap.put ( con.AccountId, new List < ccv_Contact > ());
            }
            // build json object
            ccv_Contact jsonContact = new ccv_Contact();
            jsonContact.firstName = con.FirstName;
            jsonContact.lastName = con.LastName;
            jsonContact.phone = con.Phone;
            jsonContact.emailAddress = con.Email;
            jsonContact.role = con.Title;
            jsonContact.doNotContact = String.valueOf ( con.DoNotCall );
            contactAcctMap.get ( con.AccountId ).add ( jsonContact );
        }
        return contactAcctMap;
    }

    private Map < ID, List < ccv_Activity >> buildTaskMap () {

        // create task map indexed by account
        Map < ID, List < ccv_Activity >> taskAcctMap = new Map < ID, List < ccv_Activity >> ();

        //Pull tasks and necessary attributes (paired with events below)
        List<Task> tasks = new List<Task>([SELECT Id,
                                    Status,
                                    Type,
                                    ActivityDate,
                                    Owner.Name,
                                    Subject,
                                    Description,
                                    AccountId
                                    FROM Task
                                    WHERE Account.Covetrus_Customer_Number__c	 =: this.covetrusCustomerKey
                                    ORDER BY activityDate DESC 
                                    LIMIT 15 ]);

        
        for ( Task t : tasks ) {
            if ( taskAcctMap.containsKey ( t.AccountId ) == false ) {
                taskAcctMap.put ( t.AccountId, new List < ccv_Activity > ());
            }
            // build activity json
            ccv_Activity jsonTask = new ccv_Activity();
            jsonTask.status = t.Status;
            jsonTask.type = t.Type;
            jsonTask.activityDate = String.valueOf ( t.ActivityDate );
            jsonTask.ownerFullName = t.Owner.Name;
            jsonTask.name = t.Subject;
            jsonTask.description = t.Description;
            taskAcctMap.get ( t.AccountId ).add ( jsonTask );
        }
        return taskAcctMap;
    }

    private Map < ID, List < ccv_Activity >> buildEventMap () {

        // create event map indexed by account
        Map < ID, List < ccv_Activity >> eventAcctMap = new Map < ID, List < ccv_Activity >> ();
        
        //Pull events and necessary attributes (paired with tasks above)
        List<Event> events = new List<Event>([SELECT Id,
                                            //Event_Status__c,
                                            Type,
                                            ActivityDate,
                                            Owner.Name,
                                            Subject,
                                            Description,
                                            AccountId
                                            FROM Event
                                            WHERE Account.Covetrus_Customer_Number__c	 =: this.covetrusCustomerKey
                                            ORDER BY ActivityDate DESC 
                                            LIMIT 15 ]);

        
        for ( Event evt : events ) {
            if ( eventAcctMap.containsKey ( evt.AccountId ) == false ) {
                eventAcctMap.put ( evt.AccountId, new List < ccv_Activity > ());
            }
            // build json object
            ccv_Activity jsonEvt = new ccv_Activity();
            // NOTE: NO STATUS
            jsonEvt.type = evt.Type;
            jsonEvt.activityDate = String.valueOf ( evt.ActivityDate );
            jsonEvt.ownerFullName = evt.Owner.Name;
            jsonEvt.name = evt.Subject;
            jsonEvt.description = evt.Description;
            eventAcctMap.get ( evt.AccountId ).add ( jsonEvt );
        }
        return eventAcctMap;
    }

    private Map < ID, List < ccv_AccountSummary >> buildAccountSummaryMap () {

        // Create a map, indexed by store, to store last6months of revenue data.
        Map<ID,Decimal> lastsixMap = new Map <ID,Decimal>();
        Map<ID,Decimal> mtdMap = new Map <ID,Decimal>();
        Map<ID,Decimal> ytdMap = new Map <ID,Decimal>();

        // Build a map, indexed by account.id (primary_practice__c) of stores
        Map < ID, List < ccv_AccountSummary >> acctSumAcctMap = new Map < ID, List < ccv_AccountSummary >> ();
        
        /* -> REFACTOR FOR GSS
        // Pull summaries - by store, of weekly stats over last 6 months to get rolling revenue.
        Aggregateresult[] lastsixmonths = [SELECT SUM(Total_Price__c),DVM_Order__r.DVM_Client__r.Store_Account__c
                                                 FROM DVM_Order_Line_Item__c
                                                 WHERE DVM_Order__r.DVM_Client__r.Store_Account__r.Primary_Practice__r.Covetrus_Customer_Number__c =: this.covetrusCustomerKey
                                                 AND DVM_Order__r.OrderStatus__c = 'Shipped'
                                                 AND DVM_Order__c IN (SELECT DVM_Order__c from DVM_Order_Shipment__c WHERE shipdate__c >= LAST_N_Months:6 AND DVM_Order__r.DVM_Client__r.Store_Account__r.Primary_Practice__r.Covetrus_Customer_Number__c =: this.covetrusCustomerKey)
                                         		Group by DVM_Order__r.DVM_Client__r.Store_Account__c];

        Aggregateresult[] mtdretail = [SELECT SUM(Total_Price__c),DVM_Order__r.DVM_Client__r.Store_Account__c
                                                 FROM DVM_Order_Line_Item__c
                                                 WHERE DVM_Order__r.DVM_Client__r.Store_Account__r.Primary_Practice__r.Covetrus_Customer_Number__c =: this.covetrusCustomerKey
                                                 AND DVM_Order__r.OrderStatus__c = 'Shipped'
                                                 AND DVM_Order__c IN (SELECT DVM_Order__c from DVM_Order_Shipment__c WHERE shipdate__c >= THIS_MONTH AND DVM_Order__r.DVM_Client__r.Store_Account__r.Primary_Practice__r.Covetrus_Customer_Number__c =: this.covetrusCustomerKey)
                                         		Group by DVM_Order__r.DVM_Client__r.Store_Account__c];

        Aggregateresult[] ytdretail = [SELECT SUM(Total_Price__c),DVM_Order__r.DVM_Client__r.Store_Account__c
                                                 FROM DVM_Order_Line_Item__c
                                                 WHERE DVM_Order__r.DVM_Client__r.Store_Account__r.Primary_Practice__r.Covetrus_Customer_Number__c =: this.covetrusCustomerKey
                                                 AND DVM_Order__r.OrderStatus__c = 'Shipped'
                                                 AND DVM_Order__c IN (SELECT DVM_Order__c from DVM_Order_Shipment__c WHERE shipdate__c >= THIS_YEAR AND DVM_Order__r.DVM_Client__r.Store_Account__r.Primary_Practice__r.Covetrus_Customer_Number__c =: this.covetrusCustomerKey)
                                         		Group by DVM_Order__r.DVM_Client__r.Store_Account__c];

        // iterate through aggregate to populate map
        for(Aggregateresult ar : lastsixmonths){
            lastsixMap.put((Id)ar.get('Store_Account__c'),(Decimal)ar.get('expr0'));
        }

        for(Aggregateresult ar : mtdretail){
            mtdMap.put((Id)ar.get('Store_Account__c'),(Decimal)ar.get('expr0'));
        }

        for(Aggregateresult ar : ytdretail){
            ytdMap.put((Id)ar.get('Store_Account__c'),(Decimal)ar.get('expr0'));
        }

        // Retrieve stores as the basis of accountsummaries
        List< Store__c > stores = new List< Store__c > ([SELECT ID,
                                                         Name,
                                                         Active__c,
                                                         Recordtype.name,
                                                         Primary_Practice__c,
                                                         Primary_Practice__r.VFC_Close_Date__c,
                                                         First_Revenue_Date__c,
                                                         Primary_Practice__r.Number_of_Vets__c,
                                                         Primary_Practice__r.Termination_Date__c,
                                                         Primary_Practice__r.Customer_Status__c,
                                                         Primary_Practice__r.Covetrus_Customer_Number__c
                                                         FROM Store__c
                                                         WHERE Primary_Practice__r.Covetrus_Customer_Number__c =: this.covetrusCustomerKey
                                                         ]);
        
        

        // Iterate through stores to populate the map, leveraging the aggregate map to populate rolling l6months of net revenue.
        for(Store__c store : stores){
            
            // Account summaries is returned differently depending on record type of the practice; business line. 
            // Different business lines have different data available.
            if(store.recordtype.name == 'VetsFirstChoice'){
                
                // Check if the map contains a that, key, populate if needed, so that the json object can be added to the map properly.
                if ( acctSumAcctMap.containsKey ( store.Primary_Practice__c ) == false ) {
                    acctSumAcctMap.put ( store.Primary_Practice__c, new List < ccv_AccountSummary > ());
                }

                // Make sure number of vets defaults to zero.
                Decimal numberofvets;
                if((decimal)store.primary_practice__r.Number_Of_Vets__c != null){
                    numberofvets = (decimal)store.primary_practice__r.Number_Of_Vets__c;
                }else {
                    // When number of vets is null, we assume that the number of vets at the practice is 1 per business intelligence.
                    numberofvets = 1;
                }

                // Verifies that it is not an inactive referral store with zero revenue historically.
                // 3/12/2019 - BT: removing this logic per confirmation from the business
                //if(string.valueof(store.Active__c) == 'TRUE' || String.isnotblank(string.valueof(store.First_Revenue_Date__c))){
                    
                    // build the json object.
                    ccv_AccountSummary jsonAS = new ccv_AccountSummary();
                    jsonAS.type = store.RecordType.Name;
                    jsonAS.startDate = String.valueOf ( store.Primary_Practice__r.VFC_Close_Date__c );
                    jsonAS.firstOrderDate = String.valueOf ( store.First_Revenue_Date__c );
                    jsonAS.inactivityDate = String.valueOf ( store.Primary_Practice__r.Termination_Date__c );
                    jsonAS.status = store.primary_practice__r.Customer_Status__c;
                    jsonAS.annualRevenuePotential = numberofvets * 12000;
                    //jsonAS.annualRevenueActual = 
                    jsonAS.mtdRevenuePotential = numberofvets * 1000;
                    jsonAS.mtdRevenueActual = mtdMap.get(store.Id);
                    jsonAS.rollingSixMonthsRevenueActual = lastsixMap.get(store.Id);
                    jsonAS.rollingSixMonthsPotential = numberofvets * 6000;
                    jsonAS.ytdRevenue = ytdMap.get(store.Id);
                    acctSumAcctMap.get(store.Primary_Practice__c).add(jsonAS);
                    system.debug(store);
                //}else {
                //    System.debug('Inactive Referral with Zero Revenue');
                //}

            // Account summaries is returned differently depending on record type of the practice; business line. 
            // Different business lines have different data available.
            }else if(store.RecordType.Name == 'Roadrunner'){
                
                if ( acctSumAcctMap.containsKey ( store.Primary_Practice__c ) == false ) {
                    acctSumAcctMap.put ( store.Primary_Practice__c, new List < ccv_AccountSummary > ());
                }

                Decimal numberofvets;
                if((decimal)store.primary_practice__r.Number_Of_Vets__c != null){
                    numberofvets = (decimal)store.primary_practice__r.Number_Of_Vets__c;
                }else {
                    numberofvets = 0;
                }

                ccv_AccountSummary jsonAS = new ccv_AccountSummary();
                jsonAS.type = store.RecordType.Name;
                //jsonAS.startDate = store.Primary_Practice__r.VFC_Close_Date__c;
                //jsonAS.firstOrderDate = store.First_Revenue_Date__c;
                //jsonAS.inactivityDate = store.Primary_Practice__r.Termination_Date__c;
                //jsonAS.status = store.primary_practice__r.Customer_Status__c;
                //jsonAS.annualRevenuePotential = store.primary_practice__r.Number_Of_Vets__c * 12000;
                //jsonAS.annualRevenueActual = 
                //jsonAS.mtdRevenuePotential = store.primary_practice__r.Number_Of_Vets__c * 1000;
                jsonAS.mtdRevenueActual = mtdMap.get(store.Id);
                jsonAS.rollingSixMonthsRevenueActual = lastsixMap.get(store.Id);
                jsonAS.rollingSixMonthsPotential = numberofvets * 6000;
                jsonAS.ytdRevenue = ytdMap.get(store.Id);
                acctSumAcctMap.get(store.Primary_Practice__c).add(jsonAS);
            
            // Account summaries is returned differently depending on record type of the practice; business line. 
            // Different business lines have different data available.
            }else if(store.RecordType.Name == 'VPA'){
                
                if ( acctSumAcctMap.containsKey ( store.Primary_Practice__c ) == false ) {
                    acctSumAcctMap.put ( store.Primary_Practice__c, new List < ccv_AccountSummary > ());
                }
                
                Decimal numberofvets;
                if((decimal)store.primary_practice__r.Number_Of_Vets__c != null){
                    numberofvets = (decimal)store.primary_practice__r.Number_Of_Vets__c;
                }else {
                    numberofvets = 0;
                }

                ccv_AccountSummary jsonAS = new ccv_AccountSummary();
                jsonAS.type = store.RecordType.Name;
                //jsonAS.startDate = store.Primary_Practice__r.VFC_Close_Date__c;
                //jsonAS.firstOrderDate = store.First_Revenue_Date__c;
                //jsonAS.inactivityDate = store.Primary_Practice__r.Termination_Date__c;
                //jsonAS.status = store.primary_practice__r.Customer_Status__c;
                //jsonAS.annualRevenuePotential = store.primary_practice__r.Number_Of_Vets__c * 12000;
                //jsonAS.annualRevenueActual = 
                //jsonAS.mtdRevenuePotential = store.primary_practice__r.Number_Of_Vets__c * 1000;
                jsonAS.mtdRevenueActual = mtdMap.get(store.Id);
                jsonAS.rollingSixMonthsRevenueActual = lastsixMap.get(store.Id);
                jsonAS.rollingSixMonthsPotential = numberofvets * 6000;
                jsonAS.ytdRevenue = ytdMap.get(store.Id);
                acctSumAcctMap.get(store.Primary_Practice__c).add(jsonAS);

            // Account summaries is returned differently depending on record type of the practice; business line. 
            // Different business lines have different data available.
            }else if(store.RecordType.Name == 'Atlas'){
                
                if ( acctSumAcctMap.containsKey ( store.Primary_Practice__c ) == false ) {
                    acctSumAcctMap.put ( store.Primary_Practice__c, new List < ccv_AccountSummary > ());
                }

                Decimal numberofvets;
                if((decimal)store.primary_practice__r.Number_Of_Vets__c != null){
                    numberofvets = (decimal)store.primary_practice__r.Number_Of_Vets__c;
                }else {
                    numberofvets = 0;
                }

                ccv_AccountSummary jsonAS = new ccv_AccountSummary();
                jsonAS.type = store.RecordType.Name;
                //jsonAS.startDate = store.Primary_Practice__r.VFC_Close_Date__c;
                //jsonAS.firstOrderDate = store.First_Revenue_Date__c;
                //jsonAS.inactivityDate = store.Primary_Practice__r.Termination_Date__c;
                //jsonAS.status = store.primary_practice__r.Customer_Status__c;
                //jsonAS.annualRevenuePotential = store.primary_practice__r.Number_Of_Vets__c * 12000;
                //jsonAS.annualRevenueActual = 
                //jsonAS.mtdRevenuePotential = store.primary_practice__r.Number_Of_Vets__c * 1000;
                jsonAS.mtdRevenueActual = mtdMap.get(store.Id);
                jsonAS.rollingSixMonthsRevenueActual = lastsixMap.get(store.Id);
                jsonAS.rollingSixMonthsPotential = numberofvets * 6000;
                jsonAS.ytdRevenue = ytdMap.get(store.Id);
                acctSumAcctMap.get(store.Primary_Practice__c).add(jsonAS);

            }else {
                System.debug('Bad Store Type: ' + store.RecordType.Name);
            }
        }
        */
        return acctSumAcctMap;
        
    }

}