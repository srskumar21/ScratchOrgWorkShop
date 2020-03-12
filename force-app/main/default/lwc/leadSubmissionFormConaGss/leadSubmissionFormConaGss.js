// lead submission form - CONA -> GSS
// Bhanudas Tanaka - Covetrus - Feb 2020
// Hosted in Communities, Public / Guest Access
// Two parameters on page (see API section below)

import { LightningElement, api, track } from 'lwc';
import { handleError, handleNotify } from 'c/cvetHelper';
import createLead from '@salesforce/apex/LeadFormController.createLead';

export default class LeadSubmissionFormConaGss extends LightningElement {

    // inputs from GSS
    @api enterpriseKey
    @api txtFAMFirstName;
    @api txtFAMLastName;
    @api txtFAMEmail;
    @api txtFAMPhone;

    // form keys
    @api covetrusId;
    @api famEmail;

    // form picklist values

    @track referredProductOptions  = [  { label: 'Practice Management Software', value: 'Practice Management Software' },
                                        { label: 'Credit Card Processing', value: 'Credit Card Processing' },
                                        { label: 'Rapport', value: 'Rapport' },
                                        { label: 'VetStreet', value: 'VetStreet' }
                                    ];
    
    @track stateProvinceOptions = [ { label: 'Alabama', value: 'Alabama' },
                                    { label: 'Alaska', value: 'Alaska' },
                                    { label: 'Arizona', value: 'Arizona' },
                                    { label: 'Arkansas', value: 'Arkansas' },
                                    { label: 'California', value: 'California' },
                                    { label: 'Colorado', value: 'Colorado' },
                                    { label: 'Connecticut', value: 'Connecticut' },
                                    { label: 'Delaware', value: 'Delaware' },
                                    { label: 'District of Columbia', value: 'District of Columbia' },
                                    { label: 'Florida', value: 'Florida' },
                                    { label: 'Georgia', value: 'Georgia' },
                                    { label: 'Hawaii', value: 'Hawaii' },
                                    { label: 'Idaho', value: 'Idaho' },
                                    { label: 'Illinois', value: 'Illinois' },
                                    { label: 'Indiana', value: 'Indiana' },
                                    { label: 'Iowa', value: 'Iowa' },
                                    { label: 'Kansas', value: 'Kansas' },
                                    { label: 'Kentucky', value: 'Kentucky' },
                                    { label: 'Louisiana', value: 'Louisiana' },
                                    { label: 'Maine', value: 'Maine' },
                                    { label: 'Maryland', value: 'Maryland' },
                                    { label: 'Massachusetts', value: 'Massachusetts' },
                                    { label: 'Michigan', value: 'Michigan' },
                                    { label: 'Minnesota', value: 'Minnesota' },
                                    { label: 'Mississippi', value: 'Mississippi' },
                                    { label: 'Missouri', value: 'Missouri' },
                                    { label: 'Montana', value: 'Montana' },
                                    { label: 'Nebraska', value: 'Nebraska' },
                                    { label: 'Nevada', value: 'Nevada' },
                                    { label: 'New Hampshire', value: 'New Hampshire' },
                                    { label: 'New Jersey', value: 'New Jersey' },
                                    { label: 'New Mexico', value: 'New Mexico' },
                                    { label: 'New York', value: 'New York' },
                                    { label: 'North Carolina', value: 'North Carolina' },
                                    { label: 'North Dakota', value: 'North Dakota' },
                                    { label: 'Ohio', value: 'Ohio' },
                                    { label: 'Oklahoma', value: 'Oklahoma' },
                                    { label: 'Oregon', value: 'Oregon' },
                                    { label: 'Pennsylvania', value: 'Pennsylvania' },
                                    { label: 'Rhode Island', value: 'Rhode Island' },
                                    { label: 'South Carolina', value: 'South Carolina' },
                                    { label: 'South Dakota', value: 'South Dakota' },
                                    { label: 'Tennessee', value: 'Tennessee' },
                                    { label: 'Texas', value: 'Texas' },
                                    { label: 'Utah', value: 'Utah' },
                                    { label: 'Vermont', value: 'Vermont' },
                                    { label: 'Virginia', value: 'Virginia' },
                                    { label: 'Washington', value: 'Washington' },
                                    { label: 'West Virginia', value: 'West Virginia' },
                                    { label: 'Wisconsin', value: 'Wisconsin' },
                                    { label: 'Wyoming', value: 'Wyoming' }
                                ];

    @track currentPimsOptions = [   { label: 'AltaPoint', value: 'AltaPoint' },
                                    { label: 'Avimark', value: 'Avimark' },
                                    { label: 'Advantage Plus', value: 'Advantage Plus' },
                                    { label: 'Betterchoice', value: 'Betterchoice' },
                                    { label: 'Clientrax', value: 'Clientrax' },
                                    { label: 'Complete Clinic', value: 'Complete Clinic' },
                                    { label: 'Cornerstone', value: 'Cornerstone' },
                                    { label: 'DataVet (DataWare)', value: 'DataVet (DataWare)' },
                                    { label: 'DVMax', value: 'DVMax' },
                                    { label: 'DVM Manager', value: 'DVM Manager' },
                                    { label: 'EFriends', value: 'EFriends' },
                                    { label: 'Elinc (VIA)', value: 'Elinc (VIA)' },
                                    { label: 'eVetPractice', value: 'eVetPractice' },
                                    { label: 'Impromed', value: 'Impromed' },
                                    { label: 'Intravet', value: 'Intravet' },
                                    { label: 'Paws', value: 'Paws' },
                                    { label: 'StringSoft', value: 'StringSoft' },
                                    { label: 'Sunpoint', value: 'Sunpoint' },
                                    { label: 'VetLink', value: 'VetLink' },
                                    { label: 'VetTech', value: 'VetTech' },
                                    { label: 'V-Tech', value: 'V-Tech' },
                                    { label: 'VetPort', value: 'VetPort' },
                                    { label: 'VIA', value: 'VIA' },
                                    { label: 'VetBlue', value: 'VetBlue' },
                                    { label: 'Vetter', value: 'Vetter' },
                                    { label: 'None', value: 'None' }
                                ];

    // form state
    @track showCreate;
    @track showSubmitted;
    @track showSpinner;

    // form fields
    @track referredProducts = [];
    @track pcFirstName;
    @track pcLastName;
    @track pcEmail;
    @track pcPhone;
    @track accountName;
    @track stateProvince;
    @track currentPims;
    @track famFirstName;
    @track famLastName;
    @track notes;

    // locals
    _data = {};

    connectedCallback () {
        // clean up inputs
        if ( this.enterpriseKey ) {
            this.enterpriseKey = decodeURIComponent ( this.enterpriseKey );
        }
        if ( this.txtFAMFirstName ) {
            this.txtFAMFirstName = decodeURIComponent ( this.txtFAMFirstName );
        }
        if ( this.txtFAMLastName ) {
            this.txtFAMLastName = decodeURIComponent ( this.txtFAMLastName );
        }
        if ( this.txtFAMEmail ) {
            this.txtFAMEmail = decodeURIComponent ( this.txtFAMEmail );
        }
        if ( this.txtFAMPhone ) {
            this.txtFAMPhone = decodeURIComponent ( this.txtFAMPhone );
        }

        // set initial form state
        this.showCreate = true;
        // set input values
        this._data.famEmail = this.famEmail = this.txtFAMEmail;
        this._data.covetrusId = this.enterpriseKey;
        this._data.famFirstName = this.famFirstName = this.txtFAMFirstName;
        this._data.famLastName = this.famLastName = this.txtFAMLastName;
    }

    // form input
    handleChange ( event ) {
        this._data [ event.target.name ] = event.target.value;
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
            console.log ( 'handle submit', this._submissionPerson, this._data );
            
            // submit
            try {
                this.handleSpinner ( true );
                const submission = await createLead ({ 'leadFormJson' : JSON.stringify ( this._data ) });
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
}