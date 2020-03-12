// Test Class for Request

@isTest
private class ccv_Request_TEST {
    @isTest
    private static void basic_request_mock () {
        string covetrusCustomerNumber = '123';
        Test.setMock ( HttpCalloutMock.class, new ccv_Request_MOCK ( covetrusCustomerNumber ));

        ccv_Request req = new ccv_Request ( new ccv_RequestQueryStringHelper ());
        // skip initialize
        // make the call
        ccv_SharedCustomerJSON customer;
        try {
            customer = req.getCovetrusCustomer ( covetrusCustomerNumber, null );
        } catch ( exception e ) {
            System.assert ( false, e.getMessage());
        }
        // check the return value
        System.assertEquals ( covetrusCustomerNumber, customer.practices[0].covetrusCustomerNumber );

    }

    @isTest
    private static void status_code_error_request_mock () {
        string covetrusCustomerNumber = 'ERR';
        Test.setMock ( HttpCalloutMock.class, new ccv_Request_MOCK ( covetrusCustomerNumber ));

        ccv_Request req = new ccv_Request ( new ccv_RequestQueryStringHelper ());
        // skip initialize
        // make the call
        ccv_SharedCustomerJSON customer;
        try {
            customer = req.getCovetrusCustomer ( covetrusCustomerNumber, null );
        } catch ( exception e ) {
            System.assert ( true, e.getMessage());
            return;
        }
        System.assert ( false, 'Expected Exception not found' );

    }

    @isTest
    private static void end_to_end_test () {
        string covetrusCustomerNumber = '123';
        Test.setMock ( HttpCalloutMock.class, new ccv_Request_MOCK ( covetrusCustomerNumber ));

        ccv_Request req = new ccv_Request ( new ccv_RequestQueryStringHelper ());
        req.initialize ( 'TEST' );  // use the test CMDT
        // make the call
        ccv_SharedCustomerJSON customer;
        try {
            customer = req.getCovetrusCustomer ( covetrusCustomerNumber, null );
        } catch ( exception e ) {
            System.assert ( false, e.getMessage());
        }
        // check the return value
        System.assertEquals ( covetrusCustomerNumber, customer.practices[0].covetrusCustomerNumber );

    }

}