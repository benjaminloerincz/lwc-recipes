public with sharing class ContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList() {
        List<Contact> contacts = [
            SELECT
                Id,
                Name,
                FirstName,
                LastName,
                Title,
                Phone,
                Email,
                Picture__c
            FROM Contact
            WHERE Picture__c != NULL
            WITH USER_MODE
            LIMIT 10
        ];
        Logger.debug('Retrieved ' + contacts.size() + ' contacts')
            .addTag('ContactController');
        Logger.saveLog();
        return contacts;
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> findContacts(String searchKey) {
        String key = '%' + searchKey + '%';
        List<Contact> contacts = [
            SELECT Id, Name, Title, Phone, Email, Picture__c
            FROM Contact
            WHERE Name LIKE :key AND Picture__c != NULL
            WITH USER_MODE
            LIMIT 10
        ];
        Logger.debug(
                'Found ' +
                    contacts.size() +
                    ' contacts for search key \'' +
                    searchKey +
                    '\''
            )
            .addTag('ContactController');
        Logger.saveLog();
        return contacts;
    }

    @AuraEnabled(cacheable=true)
    public static Contact getSingleContact() {
        Contact cont = [
            SELECT Id, Name, Title, Phone, Email, Picture__c
            FROM Contact
            WITH USER_MODE
            LIMIT 1
        ];
        Logger.debug('Retrieved single contact')
            .setRecord(cont)
            .addTag('ContactController');
        Logger.saveLog();
        return cont;
    }

    @AuraEnabled
    public static void updateContacts(List<Contact> contactsForUpdate) {
        try {
            // Make sure we can update the database before trying to update
            if (!Schema.sObjectType.Contact.isUpdateable()) {
                Logger.warn('Insufficient permissions to update contacts')
                    .addTag('ContactController');
                throw new SecurityException(
                    'Insufficient permissions to update contacts'
                );
            }
            update contactsForUpdate;
            Logger.info('Updated ' + contactsForUpdate.size() + ' contacts')
                .setRecord(contactsForUpdate)
                .addTag('ContactController');
        } catch (System.DmlException e) {
            Logger.error('Failed to update contacts', e)
                .setRecord(contactsForUpdate)
                .addTag('ContactController');
            throw e;
        } finally {
            Logger.saveLog();
        }
    }

    @AuraEnabled
    public static void updateContact(
        Id recordId,
        String firstName,
        String lastName
    ) {
        Contact contact = new Contact(
            Id = recordId,
            FirstName = firstName,
            LastName = lastName
        );
        try {
            update contact;
            Logger.info('Updated contact')
                .setRecord(contact)
                .addTag('ContactController');
        } catch (System.DmlException e) {
            Logger.error('Failed to update contact with ID ' + recordId, e)
                .addTag('ContactController');
            throw e;
        } finally {
            Logger.saveLog();
        }
    }
}
