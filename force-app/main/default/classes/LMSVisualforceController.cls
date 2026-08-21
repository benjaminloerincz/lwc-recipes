public with sharing class LMSVisualforceController {
    // Class to support Visualforce pages used in Lightning Message Service recipes
    public Contact contactRecord { get; set; }

    public LMSVisualforceController() {
        this.contactRecord = new Contact();
    }

    public PageReference refreshContact() {
        Id contactId = ApexPages.currentPage().getParameters().get('Id');

        try {
            this.contactRecord = [
                SELECT Id, Name, Title, Phone, Email, Picture__c
                FROM Contact
                WHERE Id = :contactId
                WITH USER_MODE
                LIMIT 1
            ];
            Logger.debug('Refreshed contact record')
                .setRecord(this.contactRecord)
                .addTag('LMSVisualforceController');
        } catch (Exception e) {
            Logger.error('Failed to refresh contact with ID ' + contactId, e)
                .addTag('LMSVisualforceController');
        } finally {
            Logger.saveLog();
        }

        return null;
    }
}
