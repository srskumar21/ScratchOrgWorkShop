public class ccv_Environment {

        public string ccvEndpointName;
        public integer requestTimeout;
        public string ccvProcessorClass;

        private Covetrus_Environment__c env;
        private CCV_Processor__mdt processor;

        // constructor - loads organizational defaults
        public ccv_Environment ( ) {
            // Fetch Custom Settings for Covetrus Values
            this.env = Covetrus_Environment__c.getOrgDefaults ();
            // Fetch Custom Metadata or initialize
            List < CCV_Processor__mdt > processors = new List < CCV_Processor__mdt > ([ SELECT Processor_Class__c FROM CCV_Processor__mdt WHERE Is_Active__c = TRUE ]);
            if ( processors.size () > 0 ) {
                this.processor = processors[0];
            } else {
                this.processor = new CCV_Processor__mdt ();
            }
        }

        // reads from custom setting
        public boolean load () {

            // read values
            this.ccvEndpointName = this.env.Covetrus_Shared_View_Service_Name__c;
            try {
                this.requestTimeout = Integer.valueOf ( this.env.Shared_View_Request_Timeout__c );
            } catch ( Exception e ) {
                // ignore, we'll just default
                this.requestTimeout = 0;
            }

            // processor class
            this.ccvProcessorClass = this.processor.Processor_Class__c;

            // handle timeout defaults
            if (( this.requestTimeout == null ) || ( this.requestTimeout < 2000 )) {
                // default to 2000 - 2 secs
                this.requestTimeout = 2000;
            }
            // if endpoint available, return true, else false
            if (( this.ccvEndpointName == null ) || ( this.ccvEndpointName == '' )) {
                return false;
            } else {
                return true;
            }
        }
    }