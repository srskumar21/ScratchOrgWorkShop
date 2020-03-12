// REST End Point for Covetrus Customer View

@RestResource ( urlMapping = '/covetrus-customer/*' )

global class ccv_WebService {

    
    // Rest End Point GET Method
    // handles the processing of return object, catching of exceptions, and formulating response
    @HttpGet
    global static ccv_SharedCustomerJSON getMethod () {

        // get class name
        ccv_Environment env = new ccv_Environment ();
        env.load ();
        // instantiate class
        ccv_DataInterface di = ( ccv_DataInterface ) Type.forName ( env.ccvProcessorClass ).newInstance ();
        // call the processor via local helper
        RestContext.response = ccv_WebService.getMethodHelper ( RestContext.request, di );
        // return response
        return (ccv_SharedCustomerJSON) JSON.deserialize( RestContext.response.responseBody.toString (), ccv_SharedCustomerJSON.class );

    }

    // Processing Logic for GET Method
    // handles the parsing of request input and processing data/request in app/data tier
    @testVisible
    private static RestResponse getMethodHelper ( RestRequest req, ccv_DataInterface converter ) {

        integer httpCode = 200;
        string contentType;
        string responseBody;

        try {
            // read the request to pull out the ID
            string covetrusCustomerKey = req.requestURI.substring ( req.requestURI.lastIndexOf ( '/' ) + 1 );
            System.debug ( 'ccv_WebService::getMethodHelper covetrusCustomerKey - ' + covetrusCustomerKey );
            // send the ID into sObjectToJSON and return object
            // and build response
            responseBody = converter.create ( covetrusCustomerKey );
            contentType = 'application/json';
        } catch ( ccv_ResponseException re ) {
            // process the exception and handle return codes
            contentType = 'application/json';
            responseBody = re.getResponseErrorMessage ();
            httpCode = re.getHttpCode ();
        } catch ( Exception e ) {
            // handle
            contentType = 'application/json';
            responseBody = ccv_ResponseException.createErrorResponse ( e.getMessage ());
            httpCode = 500;
        }

        // formulate response
        RestResponse res = new RestResponse ();
        res.addHeader ( 'Content-Type', contentType );
        res.responseBody = Blob.valueOf ( responseBody );
        res.statusCode = httpCode;
        System.debug ( 'ccv_WebService::getMethodHelper responseBody - ' + responseBody );

        return res;
    }

}