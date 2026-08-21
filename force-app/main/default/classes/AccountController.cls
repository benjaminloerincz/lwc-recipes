public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountList() {
        List<Account> accounts = [
            SELECT Id, Name
            FROM Account
            WITH USER_MODE
            LIMIT 10
        ];
        Logger.debug('Retrieved ' + accounts.size() + ' accounts')
            .addTag('AccountController');
        Logger.saveLog();
        return accounts;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalNumber() {
        Integer total = [SELECT COUNT() FROM Account WITH USER_MODE];
        Logger.debug('Total account count is ' + total)
            .addTag('AccountController');
        Logger.saveLog();
        return total;
    }

    @AuraEnabled(cacheable=true)
    public static Account getSingleAccount() {
        Account acc = [
            SELECT Id, Name, Phone, Type
            FROM Account
            WITH USER_MODE
            LIMIT 1
        ];
        Logger.debug('Retrieved single account')
            .setRecord(acc)
            .addTag('AccountController');
        Logger.saveLog();
        return acc;
    }

    @AuraEnabled
    public static void randomizeAccountData(Id accountId) {
        try {
            Account acc = [
                SELECT Id, NumberOfEmployees
                FROM Account
                WHERE Id = :accountId
                WITH USER_MODE
                LIMIT 1
            ];
            acc.NumberOfEmployees = Integer.valueof((Math.random() * 100000));
            update as user acc;
            Logger.info('Randomized NumberOfEmployees for account')
                .setRecord(acc)
                .addTag('AccountController');
        } catch (Exception e) {
            Logger.error('Couldn\'t update account with ID ' + accountId, e)
                .addTag('AccountController');
            throw new AccountUpdateException(
                'Couldn\'t update account with ID ' + accountId
            );
        } finally {
            Logger.saveLog();
        }
    }

    public class AccountUpdateException extends Exception {
    }
}
