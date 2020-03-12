// Mock for Request Testing
global class ccv_Request_MOCK implements HttpCalloutMock {

    private string covetrusCustomerNumber;

    global ccv_Request_MOCK ( String covetrusCustomerNumber ) {
        this.covetrusCustomerNumber = covetrusCustomerNumber;
    }

    global HttpResponse respond ( HTTPRequest req ) {
        // future: be selective of the request path, etc...

        HttpResponse res = new HttpResponse ();
        res.setHeader ( 'Content-Type', 'application/json' );
        if ( this.covetrusCustomerNumber != 'ERR' ) {
            res.setStatusCode ( 200 );
        } else {
            // force a 500 code
            res.setStatusCode ( 500 );
            res.setStatus ( 'Mocked Server Error' );
        }
        
        // set body
        res.setBody ( this.handleJson ( this.covetrusCustomerNumber ));
        // return
        return res;
    }

    private string handleJson ( string covetrusNumber ) {
        // create child data objects
        ccv_Practice practice1 = new ccv_Practice ();
        practice1.covetrusCustomerNumber = covetrusNumber;

        ccv_SalesRepresentative sr1 = new ccv_SalesRepresentative ();
        sr1.firstName = 'Test';
        sr1.lastName = 'Rep';

        ccv_Contact con1 = new ccv_Contact ();
        con1.firstName = 'Test';
        con1.lastName = 'Contact';

        ccv_AccountSummary acct1 = new ccv_AccountSummary ();
        acct1.type = 'Type';
        acct1.summaryName = 'Summary';

        ccv_Activity a1 = new ccv_Activity ();
        a1.name = 'TEST';

        // add to practice
        practice1.salesRepresentatives = new List < ccv_SalesRepresentative > ();
        practice1.salesRepresentatives.add ( sr1 );
        practice1.contacts = new List < ccv_Contact > ();
        practice1.contacts.add ( con1 );
        practice1.accountSummaries = new List < ccv_AccountSummary > ();
        practice1.accountSummaries.add ( acct1 );
        practice1.activities = new List < ccv_Activity > ();
        practice1.activities.add ( a1 );

        // add to master object
        ccv_SharedCustomerJSON customer = new ccv_SharedCustomerJSON ();
        customer.practices = new List < ccv_Practice > ();
        customer.practices.add ( practice1 );

        // special modifiers for testing UI
        if ( covetrusNumber == 'NO-PRACTICE' ) {
            customer.practices.clear ();
        }
        if ( covetrusNumber == 'NO-CHILDREN' ) {
            customer.practices[0].salesRepresentatives = null;
            customer.practices[0].contacts = null;
            customer.practices[0].opportunities = null;
            customer.practices[0].activities = null;
            customer.practices[0].accountSummaries = null;
        }
        
        return JSON.serialize( customer );

    }
}