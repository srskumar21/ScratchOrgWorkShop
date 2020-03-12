global class ccv_RequestQueryStringHelper {

    private string queryString;
    private Map < String, String > queryValues;

    global ccv_RequestQueryStringHelper () {
        this.queryValues = new Map < String, String > ();
    }

    global void setQueryString ( string queryString ) {
        this.queryString = queryString;
    }

    global void put ( String key, String value ) {
        this.queryValues.put ( key, value );
    }

    global void replaceAllKeys () {
        // for each token, try to replace 
        for ( string tokenKey : this.queryValues.keySet ()) {

            string searchKey = '{!' + tokenKey + '}';
            string replacement = EncodingUtil.urlEncode ( this.queryValues.get ( tokenKey ), 'UTF-8' );
            this.queryString = this.queryString.replace ( searchKey, replacement );
        }

        // check that all {} are gone
        if (( this.queryString.indexOf ('{') != -1 ) || ( this.queryString.indexOf ('}') != -1 )) {
            throw new ccv_RequestException ( ccv_RequestException.ErrorType.FATAL, 'Query String token replacement did not clear all values - query string ' + this.queryString, 'Please report this issue to the Salesforce Team', null );
        }
    }

    global string getQueryString () {
        return this.queryString;
    }
}