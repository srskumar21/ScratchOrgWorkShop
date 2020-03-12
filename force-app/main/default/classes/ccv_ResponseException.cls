global class ccv_ResponseException extends Exception {
    
    private string responseErrorMessage;
    private integer httpCode;
    global enum ErrorType { UNKNOWN, WARNING, FATAL }

    global ccv_ResponseException ( ErrorType eType, String errorMessage, Exception e ) {
        // handle the exception
        this.responseErrorMessage = errorMessage;
        this.httpCode = 444;
        System.debug ( 'ccv_ResponseException::Constructor - this - ' + this + ' exception - ' + e );

    }

    global string getResponseErrorMessage () {
        return ccv_ResponseException.createErrorResponse ( this.responseErrorMessage );
    }

    global integer getHttpCode () {
        return this.httpCode;
    }

    global static string createErrorResponse ( string errorMessage ) {
        ccv_DataControl dc = new ccv_DataControl ();
        dc.errorMessage = errorMessage;
        ccv_SharedCustomerJSON sc = new ccv_SharedCustomerJSON ();
        sc.dataControl = dc;
        return JSON.serialize( sc );
    }
}