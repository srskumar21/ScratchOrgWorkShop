global class ccv_RequestException extends Exception {
    
    private string errorMessage;
    private Exception e;
    global enum ErrorType { UNKNOWN, WARNING, FATAL }

    global ccv_RequestException ( ErrorType eType, String msg, String nextSteps, Exception e ) {
        this.errorMessage = msg;
        this.e = e;
        System.debug ( 'ccv_RequestException::Constructor - this - ' + this + ' exception - ' + e );
        // build the data construct to return to UI
        ErrorData data = new ErrorData ();
        data.message = msg;
        data.nextSteps = nextSteps;
        data.type = eType.name ();
        // figure out title
        if ( eType == ErrorType.FATAL ) {
            data.title = 'A serious problem has occurred preventing your request';
        } else if ( eType == ErrorType.WARNING ) {
            data.title = 'Some information about your request';
        } else {
            data.title = 'There was a problem with your request';
        }

        throw new AuraHandledException ( JSON.serialize( data ));
    }
    
    global class ErrorData {
        global string type;
        global string title;
        global string message;
        global string nextSteps;
    }
}