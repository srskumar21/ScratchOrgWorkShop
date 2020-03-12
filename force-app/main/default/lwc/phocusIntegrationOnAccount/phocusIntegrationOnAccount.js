import {
    LightningElement,
    api,track,
    wire
} from 'lwc';
import {
    getRecord
} from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id';
export default class PhocusIntegrationOnAccount extends LightningElement {
    @api recordId;
    @track account;
    @wire(getRecord, {
        recordId: '$recordId',
        fields:['Account.AccountNumber']
    })
    account;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: ['User.Username']
    })
    user;


    get phocusURL() {
        return "https://goto.provet.com.au/salesforce?Customer=" + 
                escape(this.account.data.fields.AccountNumber.value) +
                "&Username=" + escape(this.user.data.fields.Username.value);
    }
}