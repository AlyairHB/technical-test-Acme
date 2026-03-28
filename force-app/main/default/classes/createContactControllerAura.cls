public with sharing class createContactControllerAura {

    @AuraEnabled
    public static String createContact(
        String firstName,
        String lastName,
        String recordTypeDeveloperName,
        String accountId
    ) {
        try {
            Id rtId = [
                SELECT Id FROM RecordType
                WHERE SObjectType = 'Contact'
                AND DeveloperName = :recordTypeDeveloperName
                LIMIT 1
            ].Id;

            Contact c = new Contact(
                FirstName    = firstName,
                LastName     = lastName,
                RecordTypeId = rtId,
                AccountId    = accountId
            );
            insert c;
            return c.Id;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}