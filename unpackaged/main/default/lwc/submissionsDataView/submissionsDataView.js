import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import fetchData from '@salesforce/apex/SubmissionDataController.fetchData'

export default class SubmissionsDataView extends LightningElement {
    isLoaded = false;
    isVisible = false;
    _recordId;
    result;

    @wire(CurrentPageReference)
    pageRef;

    @api get recordId() {
        return this._recordId;
    };
    set recordId(value) {
        if(this._recordId == null || this._recordId == undefined) {
            this._recordId = value;
            this.initData();
        }
    };

    @api
    get errorToast() {};
    set errorToast(value) {
        let event = new ShowToastEvent({
            title: 'Error',
            message: value,
            variant: 'error',
            mode: 'sticky'});
        this.dispatchEvent(event);
    }

    initData() {
        fetchData({ recordId: this.recordId })
            .then((response) => {
                this.result = response;
                console.log('::::: result = ', JSON.stringify(this.result));
                this.isVisible = this.result.isVisible;
            }).catch(error => {
                this.errorToast = error.body.message;
            }).finally(() => {
                this.isLoaded = true;
            });
    }
}