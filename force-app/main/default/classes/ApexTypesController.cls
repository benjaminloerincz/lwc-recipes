public with sharing class ApexTypesController {
    @AuraEnabled(cacheable=true)
    public static String checkApexTypes(CustomWrapper wrapper) {
        // Log the received payload instead of using System.debug(), which isn't suitable for production use.
        Logger.fine(
                'Received CustomWrapper payload: ' + JSON.serialize(wrapper)
            )
            .addTag('ApexTypesController');
        Logger.saveLog();
        // The values are based on the data that is defined in the
        // apexImperativeMethodWithComplexParams Lightning web component.
        String response =
            'You entered "' +
            wrapper.someString +
            '" as String, and "' +
            wrapper.someInteger +
            '" as Integer value. The list contained ' +
            wrapper.someList.size() +
            ' items.';
        return response;
    }
}
