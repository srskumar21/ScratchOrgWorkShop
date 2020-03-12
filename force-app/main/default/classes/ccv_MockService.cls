global class ccv_MockService implements System.StubProvider {

    private MockData data;

    global ccv_MockService ( MockData data ) {
        this.data = data;
    }

    global Object handleMethodCall ( Object stubbedObject, String stubbedMethodName, Type returnType, List < Type > listOfParamTypes, List < String > listOfParamNames, List < Object > listOfArgs ) {
        system.debug ( 'ccv_MockService.handleMethodCall ( ' + stubbedMethodName + ') ' + stubbedObject ); 

        if ( stubbedObject instanceof ccv_DataInterface ) {
            if ( stubbedMethodName == 'create' ) {
                system.debug ( 'ccv_MockService - ccv_DataInterface - create ' + data );
                return ccv_sObjectToJSON_create ( listOfArgs[0] );
            }
        }

        return null;
    }

    // ccv_sObjectToJSON Stubs
    private string ccv_sObjectToJSON_create ( Object customerKey ) {
        // echo back the Covetrus Customer Number
        ccv_SharedCustomerJSON customer = new ccv_SharedCustomerJSON ();
        if ( data.containsKey ('echo-key' )) {
            customer = (ccv_SharedCustomerJSON) JSON.deserialize ( (string) data.get ( 'echo-key' ), ccv_SharedCustomerJSON.class );
            customer.practices[0].covetrusCustomerNumber = (string) customerKey;
        }
        if ( data.containsKey ('response-exception')) {
            throw new ccv_ResponseException ( null, (string) data.get ( 'response-exception' ), null );
        }
        if ( data.containsKey ('query-exception')) {
            throw new QueryException ( (string) data.get ( 'response-exception' ));
        }
        
        return JSON.serialize ( customer );

    }

    global class MockData {

        private  Map < String, Object > params;

        global MockData () {
            this.params = new Map < String, Object > ();
        }

        global MockData ( String str, Object obj ) {
            this ();
            this.params.put ( str, obj );
        }

        global void put ( String str, Object obj ) {
            this.params.put ( str, obj );
        }

        global object get ( String str ) {
            return this.params.get ( str );
        }

        global boolean containsKey ( String str ) {
            return this.params.containsKey ( str );
        }

    }

}