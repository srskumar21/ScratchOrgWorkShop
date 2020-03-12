@isTest
private class ccv_RequestQueryStringHelper_TEST {
    @isTest
    private static void basic () {

        ccv_RequestQueryStringHelper qh = new ccv_RequestQueryStringHelper ();

        try {
            qh.setQueryString ( 'key1={!key1}&key2={!key2}' );
            qh.put ( 'key1', 'value1' );
            qh.put ( 'key2', 'value2' );
            qh.replaceAllKeys ();
        } catch ( Exception e ) {
            System.assert ( false, 'Exception ' + e.getMessage() + ' caught' );
        }

        System.assertEquals ( 'key1=value1&key2=value2', qh.getQueryString ());

    }

    @isTest
    private static void exception_query_string () {

        ccv_RequestQueryStringHelper qh = new ccv_RequestQueryStringHelper ();

        try {
            qh.setQueryString ( 'key1={!key1}&key2={!key2}' );
            qh.put ( 'key1', 'value1' );
            qh.put ( 'key3', 'value3' );
            qh.replaceAllKeys ();
        } catch ( Exception e ) {
            System.assert ( true );
            return;
        }

        System.assert ( false, 'Exception not thrown' );

    }
}