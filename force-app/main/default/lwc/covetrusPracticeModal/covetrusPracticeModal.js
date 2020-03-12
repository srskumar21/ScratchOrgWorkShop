import { LightningElement, api, track } from 'lwc';

// Thanks to Shaik Nagajani
// https://www.salesforcecodecrack.com/2019/01/popupmodal-box-in-salesforce-lightning.html

export default class CovetrusPracticeModal extends LightningElement {

    @track activity;
    @track trackedModalStatus = false;

    @api showModal ( inputActivity ) {
        console.log ('show modal');
        this.activity = inputActivity;
        console.log ( JSON.stringify ( this.activity ));
        this.trackedModalStatus = true;
    }

    closeModal () {
        this.trackedModalStatus = false;
    }
}