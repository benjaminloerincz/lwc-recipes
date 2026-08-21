import { LightningElement } from 'lwc';
import { getLogger } from 'c/logger';
import getContactList from '@salesforce/apex/ContactController.getContactList';

export default class ApexImperativeMethod extends LightningElement {
    contacts;
    error;
    logger = getLogger();

    async handleLoad() {
        try {
            this.contacts = await getContactList();
            this.error = undefined;
            this.logger
                .info('Loaded ' + this.contacts.length + ' contacts')
                .addTag('apexImperativeMethod');
        } catch (error) {
            this.contacts = undefined;
            this.error = error;
            this.logger
                .error('Failed to load contact list')
                .setExceptionDetails(error)
                .addTag('apexImperativeMethod');
        } finally {
            await this.logger.saveLog();
        }
    }
}
