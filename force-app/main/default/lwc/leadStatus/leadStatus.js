import { LightningElement, api, track } from 'lwc';
import { handleError, handleNotify } from 'c/cvetHelper';
import requestLeadStatusEmail from '@salesforce/apex/LeadFormController.requestLeadStatusEmail';

export default class LeadStatus extends LightningElement {

    // parent component inputs
    @api famEmail;

    // form state
    @track showGetStarted;
    @track showCreate;
    @track showSubmitted;

    // locals
    _data = {};

    connectedCallback () {
        // clean up inputs
        if ( this.famEmail ) {
            this.famEmail = decodeURIComponent ( this.famEmail );
        }
        // set local data
        this._data.famEmail = this.famEmail;
        // default form state
        this.showGetStarted = true;
    }

    // form validity
    areFieldsValid () {
        const inputValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        const comboValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        const checkboxGroupValid = [...this.template.querySelectorAll('lightning-checkbox-group')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        return inputValid && comboValid && checkboxGroupValid;
    }

    handleChange ( event ) {
        this._data [ event.target.name ] = event.target.value;
    }

    // UI Controls
    handleSpinner ( state ) {
        this.showSpinner = state;
    }

    async handleSubmit ( event ) {
        event.preventDefault ();
        // validate form
        if ( this.areFieldsValid () === false ) {
            handleNotify ( 'Submission Errors', 'Please see errors below', 'error' );
        } else {
            // submit
            try {
                this.handleSpinner ( true );
                const submission = await requestLeadStatusEmail ({ 'famEmail' : this._data.famEmail });
                console.log ( 'committed', submission );
                // show success
                this.showCreate = false;
                this.showSubmitted = true;
            } catch ( e ) {
                handleError ( e );
            }
            this.handleSpinner ( false );
        }
    }

    handleGetStarted ( event ) {
        event.preventDefault ();
        this.showGetStarted = false;
        this.showCreate = true;
    }
}