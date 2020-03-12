import { LightningElement, wire, track, api } from 'lwc';
import getSharedCustomer from '@salesforce/apex/ccv_SharedCustomerUI.requestCustomerData';


export default class CovetrusCustomer extends LightningElement {
    @api recordId;
    sharedCustomer;
    @track practices;
    @track selectedPractice;
    @track dataLoading = true;
    @track error;
    @track trackShowModal = false;

    @wire ( getSharedCustomer, { accountId: '$recordId' })
    makeRemoteRequest ({ error, data }) {
        if ( data ) {
            //console.log ('have data');
            //console.log ( data );
            this.sharedCustomer = JSON.parse ( data );
            this.practices = this.sharedCustomer.practices;
            console.log ('covetrusCustomer wiring');
            console.log ( JSON.stringify (this.practices) );
            // spinner control
            this.dataLoading = false;
        } else if ( error ) {
            console.log ('error');
            this.error = error;
            this.dataLoading = false;
        }
    }

    showActivityDetail ( event ) {
        console.log ('in covetrus customer');
        console.log ( JSON.stringify ( event.detail.activity ));
        // find the modal component and call the show method
        this.template.querySelector('c-covetrus-practice-modal').showModal ( event.detail.activity );

    }

    get practiceList () {
        console.log ('covetrusCustomer get practiceList ()');
        //console.log ( JSON.stringify (this.practices));
        return this.practices;
    }

}