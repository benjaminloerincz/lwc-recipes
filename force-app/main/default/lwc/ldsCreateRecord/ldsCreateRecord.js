import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { reduceErrors } from 'c/ldsUtils';
import { getLogger } from 'c/logger';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';

export default class LdsCreateRecord extends LightningElement {
    accountId;

    name = '';
    logger = getLogger();

    handleNameChange(event) {
        this.accountId = undefined;
        this.name = event.target.value;
    }

    async createAccount() {
        const fields = {};
        fields[NAME_FIELD.fieldApiName] = this.name;
        const recordInput = { apiName: ACCOUNT_OBJECT.objectApiName, fields };
        try {
            const account = await createRecord(recordInput);
            this.accountId = account.id;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Account created',
                    variant: 'success'
                })
            );
            this.logger
                .info('Created account record')
                .setRecordId(account.id)
                .addTag('ldsCreateRecord');
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
            this.logger
                .error('Failed to create account record')
                .setExceptionDetails(error)
                .addTag('ldsCreateRecord');
        } finally {
            await this.logger.saveLog();
        }
    }
}
