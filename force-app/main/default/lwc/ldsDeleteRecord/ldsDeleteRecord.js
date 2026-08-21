import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import getAccountList from '@salesforce/apex/AccountController.getAccountList';
import { reduceErrors } from 'c/ldsUtils';
import { getLogger } from 'c/logger';

export default class LdsDeleteRecord extends LightningElement {
    accounts;
    error;
    logger = getLogger();

    /** Wired Apex result so it can be refreshed programmatically */
    wiredAccountsResult;

    @wire(getAccountList)
    wiredAccounts(result) {
        this.wiredAccountsResult = result;
        if (result.data) {
            this.accounts = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.accounts = undefined;
        }
    }

    async deleteAccount(event) {
        const recordId = event.target.dataset.recordid;

        try {
            await deleteRecord(recordId);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Account deleted',
                    variant: 'success'
                })
            );
            await refreshApex(this.wiredAccountsResult);
            this.logger
                .info('Deleted account record')
                .setRecordId(recordId)
                .addTag('ldsDeleteRecord');
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
            this.logger
                .error('Failed to delete account record')
                .setRecordId(recordId)
                .setExceptionDetails(error)
                .addTag('ldsDeleteRecord');
        } finally {
            await this.logger.saveLog();
        }
    }
}
