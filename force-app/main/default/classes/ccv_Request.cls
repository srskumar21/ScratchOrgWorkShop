// Handles outbound request to third party CRM

global class ccv_Request {

    private String fullyQualifiedURL;
    private String queryString;
    private String crmName;
    private ccv_RequestQueryStringHelper queryStringHelper;

    global ccv_Request ( ccv_RequestQueryStringHelper queryStringHelper ) {

        this.queryString = '';
        this.queryStringHelper = queryStringHelper;

    }

    global void initialize ( string crmName ) {
        // load CMT based on crmName
        this.crmName = crmName;

        List < Connected_CRM__mdt > crmList = new List < Connected_CRM__mdt > ([ SELECT Server_Address__c, 
                                                                                        Covetrus_Customer_Request_Path__c,
                                                                                        Query__c
                                                                                 FROM   Connected_CRM__mdt 
                                                                                 WHERE  DeveloperName =: crmName ]);

        if ( crmList.size () == 0 ) {
            throw new ccv_RequestException ( ccv_RequestException.ErrorType.FATAL, 'Could not find configuration for CRM ' + crmName, 'Please contact the Salesforce Team and report this issue', null );
        }

        // store the URL for request
        this.fullyQualifiedURL = 'https://' + crmList[0].Server_Address__c + crmList[0].Covetrus_Customer_Request_Path__c;
        // store query string with tokens
        this.queryString = crmList[0].Query__c;

        // decrypt and store credentials
    }

    global ccv_SharedCustomerJSON getCovetrusCustomer ( string covetrusCustomerNumber, integer requestTimeOut ) {
        ccv_SharedCustomerJSON customer;
        // setup outbound request
        HttpRequest req = new HttpRequest ();
        req.setMethod ( 'GET' );
        // set timeout
        if ( requestTimeOut == null ) {
            requestTimeOut = 2000; // default to 2 sec
        }
        req.setTimeout( requestTimeOut ); // set timeout to 10 sec
        // set authentication

        // add parse query string and replace values
        this.queryStringHelper.setQueryString ( this.queryString );
        this.queryStringHelper.put ( 'covetrus-customer-number', covetrusCustomerNumber );
        this.queryStringHelper.replaceAllkeys ();

        req.setEndPoint ( this.fullyQualifiedURL + '?' + this.queryStringHelper.getQueryString ());

        // make the call
        HttpResponse res;
        try {
            res = new Http ().send ( req );
        } catch ( Exception e ) {
            throw new ccv_RequestException ( ccv_RequestException.ErrorType.FATAL, this.crmName + ' could not complete this request - ' + e.getMessage(), 'Please contact the Salesforce Team and report this issue', null );
        }
        
        if ( res.getStatusCode () != 200 ) {
            throw new ccv_RequestException ( ccv_RequestException.ErrorType.FATAL, 'Response from CRM ' + this.crmName + ' did not return a 200.  Status Code: ' + res.getStatusCode () + ' Message: ' + res.getStatus (), 'Please contact the Salesforce Team and report this issue', null );
        }

        // convert body to JSON
        try {
            customer = (ccv_SharedCustomerJSON) JSON.deserialize( res.getBody (), ccv_SharedCustomerJSON.class );
        } catch ( Exception e ) {
            throw new ccv_RequestException ( ccv_RequestException.ErrorType.FATAL, 'Error in JSON deserialization of data: ', 'Please contact the Salesforce Team and report this issue', e );
        }
        return customer;
    }

}