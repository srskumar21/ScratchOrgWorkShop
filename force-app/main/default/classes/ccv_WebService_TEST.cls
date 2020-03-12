// Web Service Test Class

@isTest
private class ccv_WebService_TEST {

    @TestSetup
    static void makeData (){
        // create test Custom Settings
        Covetrus_Environment__c env = new Covetrus_Environment__c ();
        env.Covetrus_Shared_View_Service_Name__c = 'TEST';
        env.Shared_View_Request_Timeout__c = '10000';
        insert env;
    }
    

    @isTest
    private static void basic_mock () {

        Test.startTest ();
        string mockJson = '{"practices":[{"covetrusCustomerNumber":"0"}],"dataControl":{"version":1.0}}';
        ccv_MockService.MockData data = new ccv_MockService.MockData ( 'echo-key', (object) mockJson );
        ccv_DataInterface mockConverter = ( ccv_DataInterface ) Test.createStub ( ccv_DataInterface.class, new ccv_MockService ( data ));
        // invoke web service inner method
        RestRequest req = new RestRequest ();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/covetrus-customer/id/C123';
        RestContext.request = req;
        RestResponse res = ccv_WebService.getMethodHelper ( req, mockConverter );
        Test.stopTest ();
        
        string resBody = res.responseBody.toString ();
        System.debug ( resBody );
        system.assertEquals ( true, resBody.contains ( 'C123' ));

    }
    @isTest
    private static void basic_response_exception () {

        Test.startTest ();
        ccv_MockService.MockData data = new ccv_MockService.MockData ( 'response-exception', 'mock error' );
        ccv_DataInterface mockConverter = ( ccv_DataInterface ) Test.createStub ( ccv_DataInterface.class, new ccv_MockService ( data ));
        // invoke web service inner method
        RestRequest req = new RestRequest ();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/covetrus-customer/id/C123';
        RestContext.request = req;
        RestResponse res = ccv_WebService.getMethodHelper ( req, mockConverter );
        Test.stopTest ();
        
        string resBody = res.responseBody.toString ();
        System.debug ( resBody );
        System.assertEquals ( 444, res.statusCode );

    }

    @isTest
    private static void basic_query_exception () {

        Test.startTest ();
        ccv_MockService.MockData data = new ccv_MockService.MockData ( 'query-exception', 'mock error' );
        ccv_DataInterface mockConverter = ( ccv_DataInterface ) Test.createStub ( ccv_DataInterface.class, new ccv_MockService ( data ));
        // invoke web service inner method
        RestRequest req = new RestRequest ();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/covetrus-customer/id/C123';
        RestContext.request = req;
        RestResponse res = ccv_WebService.getMethodHelper ( req, mockConverter );
        Test.stopTest ();
        
        string resBody = res.responseBody.toString ();
        System.debug ( resBody );
        System.assertEquals ( 500, res.statusCode );

    }

    @isTest
    private static void basic_web_service_call () {

        RestRequest req = new RestRequest ();

        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/covetrus-customer/id/C123';
        RestContext.request = req;

        Test.startTest ();
        ccv_WebService.getMethod ();
        Test.stopTest ();

        string resBody = RestContext.response.responseBody.toString ();

        // add assert after we have a fully working sObjectToJson class

    }

    @isTest
    private static void no_customer_id_exception () {

        RestRequest req = new RestRequest ();

        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/covetrus-customer/id/';
        RestContext.request = req;

        Test.startTest ();
        ccv_WebService.getMethod ();
        Test.stopTest ();

        string resBody = RestContext.response.responseBody.toString ();
        System.assertEquals ( 444, RestContext.response.statusCode );
    }

}