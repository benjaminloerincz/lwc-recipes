import { LightningElement } from 'lwc';
import { getLogger } from 'c/logger';
import findContacts from '@salesforce/apex/ContactController.findContacts';

export default class ApexImperativeMethodWithParams extends LightningElement {
    searchKey = '';
    contacts;
    error;
    logger = getLogger();

    handleKeyChange(event) {
        this.searchKey = event.target.value;
    }

    async handleSearch() {
        try {
            this.contacts = await findContacts({ searchKey: this.searchKey });
            this.error = undefined;
            this.logger
                .info(
                    'Found ' +
                        this.contacts.length +
                        " contacts for search key '" +
                        this.searchKey +
                        "'"
                )
                .addTag('apexImperativeMethodWithParams');
        } catch (error) {
            this.error = error;
            this.contacts = undefined;
            this.logger
                .error("Contact search failed for key '" + this.searchKey + "'")
                .setExceptionDetails(error)
                .addTag('apexImperativeMethodWithParams');
        } finally {
            await this.logger.saveLog();
        }
    }
}
