import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class CovetrusCustomerError extends LightningElement {

    @api error;
    @track errorDisplay;
    toastDisplayed=false;

    connectedCallback () {
        console.log ( 'covetrus customer error' );
        console.log ( JSON.stringify ( this.error ));
        // convert into display formation
        this.errorDisplay = JSON.parse ( this.error.body.message );
        // throw the Toast event
        // display error
        if (( this.toastDisplayed === false ) && ( this.errorDisplay.type === 'FATAL' )) {
            const event = new ShowToastEvent({
                title: 'Oh oh...we ran into a problem',
                message: this.errorDisplay.message,
            });
            this.toastDisplayed = true;
            this.dispatchEvent(event);
        }
        
    }

}