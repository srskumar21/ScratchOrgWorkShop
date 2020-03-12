@isTest
private class ccv_SharedCustomerUI_TEST {

    @TestSetup
    static void makeData (){
        // create base account
        Account a = new Account ();
        a.Name = 'test';
        a.Covetrus_Customer_Number__c = 'C123';
        a.BillingStreet = '123 Test Street';
        a.BillingPostalCode = '04106';
        a.BillingState = 'Maine';
        a.BillingCity = 'Portland';
        a.BillingCountry = 'United States';
        a.ShippingStreet = '123 Test Street';
        a.ShippingPostalCode = '04106';
        a.ShippingState = 'Maine';
        a.ShippingCity = 'Portland';
        a.CurrencyIsoCode = 'USD';
        a.Phone = '4159424788';
        a.ShippingCountry = 'United States';
        insert a;

        // create test Custom Settings
        Covetrus_Environment__c env = new Covetrus_Environment__c ();
        env.Covetrus_Shared_View_Service_Name__c = 'TEST';
        env.Shared_View_Request_Timeout__c = '10000';
        insert env;
    }

    @isTest
    static void base_test () {

        Account a = [ SELECT ID FROM Account ];
        Test.setMock ( HttpCalloutMock.class, new ccv_Request_MOCK ( 'C123' ));
        Test.startTest ();
        String jsonOutput = ccv_SharedCustomerUI.requestCustomerData ( a.id );
        Test.stopTest ();
        // assert
        ccv_SharedCustomerJSON customer = (ccv_SharedCustomerJSON) JSON.deserialize( jsonOutput, ccv_SharedCustomerJSON.class );
        // assert transformations
        System.assertEquals ( 'Test Rep', customer.practices[0].salesRepresentatives[0].fullName );
        System.assertEquals ( 'Test Contact', customer.practices[0].contacts[0].fullName );
        System.assertEquals ( 'Type Summary', customer.practices[0].accountSummaries[0].label );
    }

    @isTest
    static void bad_account_number () {

        Account a = [ SELECT ID FROM Account ];
        Test.setMock ( HttpCalloutMock.class, new ccv_Request_MOCK ( 'C123' ));

        boolean exceptionFound = false;

        Test.startTest ();
        try {
            String jsonOutput = ccv_SharedCustomerUI.requestCustomerData ( 'bad' );
        } catch ( Exception e ) {
            exceptionFound = true;
        }
        Test.stopTest ();

        System.assertEquals ( true, exceptionFound );
    }

    @isTest
    static void no_covetrus_key () {

        // set key to empty
        Account a = [ SELECT ID FROM Account ];
        a.Covetrus_Customer_Number__c = '';
        update a;

        Test.setMock ( HttpCalloutMock.class, new ccv_Request_MOCK ( 'C123' ));

        boolean exceptionFound = false;

        Test.startTest ();
        try {
            String jsonOutput = ccv_SharedCustomerUI.requestCustomerData ( a.id );
        } catch ( Exception e ) {
            exceptionFound = true;
        }
        Test.stopTest ();

        System.assertEquals ( true, exceptionFound );
    }

    @isTest
    static void no_custom_settings () {

        Account a = [ SELECT ID FROM Account ];
        
        // remove custom settings
        Covetrus_Environment__c env = [ SELECT ID From Covetrus_Environment__c ];
        delete env;

        Test.setMock ( HttpCalloutMock.class, new ccv_Request_MOCK ( 'C123' ));

        boolean exceptionFound = false;

        Test.startTest ();
        try {
            String jsonOutput = ccv_SharedCustomerUI.requestCustomerData ( a.id );
        } catch ( Exception e ) {
            exceptionFound = true;
        }
        Test.stopTest ();

        System.assertEquals ( true, exceptionFound );
    }

    @isTest
    static void no_practices_returned () {

        Account a = [ SELECT ID FROM Account ];
        
        Test.setMock ( HttpCalloutMock.class, new ccv_Request_MOCK ( 'NO-PRACTICE' ));

        boolean exceptionFound = false;

        Test.startTest ();
        try {
            String jsonOutput = ccv_SharedCustomerUI.requestCustomerData ( a.id );
        } catch ( Exception e ) {
            exceptionFound = true;
        }
        Test.stopTest ();

        System.assertEquals ( true, exceptionFound );
    }

    @isTest
    static void empty_custom_setting_endpoint_name () {

        // update custom setting
        Covetrus_Environment__c envC = [ SELECT Covetrus_Shared_View_Service_Name__c, Shared_View_Request_Timeout__c FROM Covetrus_Environment__c ];
        envC.Covetrus_Shared_View_Service_Name__c = null;
        envC.Shared_View_Request_Timeout__c = null;
        update envC;

        ccv_Environment env = new ccv_Environment ();
        boolean result = env.load ();

        System.assertEquals ( false, result );
    }

    @isTest
    static void custom_setting_default_request_timeout_low () {

        // update custom setting
        Covetrus_Environment__c envC = [ SELECT Covetrus_Shared_View_Service_Name__c, Shared_View_Request_Timeout__c FROM Covetrus_Environment__c ];
        envC.Covetrus_Shared_View_Service_Name__c = 'TEST';
        envC.Shared_View_Request_Timeout__c = '100';
        update envC;

        ccv_Environment env = new ccv_Environment ();
        boolean result = env.load ();

        System.assertEquals ( 2000, env.requestTimeout );
    }

    @isTest
    static void custom_setting_default_request_timeout_null () {

        // update custom setting
        Covetrus_Environment__c envC = [ SELECT Covetrus_Shared_View_Service_Name__c, Shared_View_Request_Timeout__c FROM Covetrus_Environment__c ];
        envC.Covetrus_Shared_View_Service_Name__c = 'TEST';
        envC.Shared_View_Request_Timeout__c = null;
        update envC;

        ccv_Environment env = new ccv_Environment ();
        boolean result = env.load ();

        System.assertEquals ( 2000, env.requestTimeout );
    }

    @isTest
    static void empty_json_child_lists () {

        Account a = [ SELECT ID FROM Account ];
        
        Test.setMock ( HttpCalloutMock.class, new ccv_Request_MOCK ( 'NO-CHILDREN' ));

        boolean exceptionFound = false;

        Test.startTest ();
        try {
            String jsonOutput = ccv_SharedCustomerUI.requestCustomerData ( a.id );
        } catch ( Exception e ) {
            exceptionFound = true;
        }
        Test.stopTest ();

        System.assertEquals ( false, exceptionFound );
    }
}