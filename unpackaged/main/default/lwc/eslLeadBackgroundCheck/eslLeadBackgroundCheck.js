import { LightningElement, api} from 'lwc';
import makeCallout from '@salesforce/apex/ESLBackgroundCheckController.sendBackgroundCheck';
import featureEnabled from '@salesforce/apex/ESLBackgroundCheckController.isFeatureFlagEnabled';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class EslLeadBackgroundCheck extends LightningElement {
    @api recordId;

    @api invoke() {
        this.handleCallout();
    }

    handleCallout() {
        featureEnabled()
            .then(result => {
                if (result) {
                    this.showToast('Request Send', 'Your request has been sent. Please wait for a response from the server, this may take up to 20 seconds.', 'info');
                    return makeCallout({ recordId: this.recordId });
                } else {
                    this.showToast('Feature Disabled', 'This feature was disabled in settings.', 'info');
                }
            })
            .then((result) => {
                if (result) {
                    this.showToast('Success', result, 'success');
                }
            })
            .catch((error) => {
                const errorMessage = error.body ? error.body.message : 'Unknown Error';
                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.closeQuickAction();
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
            mode: ''
        });
        this.dispatchEvent(event);
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}