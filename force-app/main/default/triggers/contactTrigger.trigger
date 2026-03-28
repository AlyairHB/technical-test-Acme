trigger contactTrigger on Contact (after insert, after update) {

    if (Trigger.isInsert && Trigger.isAfter) {
        System.debug('=== CONTACT TRIGGER AFTER INSERT ===');
        System.debug('Number of contacts: ' + Trigger.new.size());
        
        for (Contact c : Trigger.new) {
            System.debug('Contact: ' + c.FirstName + ' ' + c.LastName);
            System.debug('AccountId: ' + c.AccountId);
            System.debug('RecordTypeId: ' + c.RecordTypeId);
        }

        Set<Id> recordTypeIds = new Set<Id>();
        for (Contact c : Trigger.new) {
            if (c.RecordTypeId != null) {
                recordTypeIds.add(c.RecordTypeId);
            }
        }

        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([
            SELECT Id, DeveloperName FROM RecordType WHERE Id IN :recordTypeIds
        ]);

        Map<String, String> rtRegion = new Map<String, String>{
            'Americas_Contact' => 'Americas',
            'Europe_Contact'   => 'Europe'
        };

        List<Opportunity> oppsInsert = new List<Opportunity>();

        for (Contact c : Trigger.new) {
            if (c.AccountId != null) {
                String region = '';
                RecordType rt = recordTypeMap.get(c.RecordTypeId);
                if (rt != null && rtRegion.containsKey(rt.DeveloperName)) {
                    region = rtRegion.get(rt.DeveloperName);
                }

                Opportunity newOpp = new Opportunity(
                    Name      = c.FirstName + ' ' + c.LastName,
                    AccountId = c.AccountId,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addDays(30),
                    Region__c = region
                );

                oppsInsert.add(newOpp);
                System.debug('Opportunity TO INSERT: ' + newOpp.Name + ', AccountId: ' + newOpp.AccountId);
            } else {
                System.debug('NO AccountId - Opportunity NOT created for: ' + c.FirstName + ' ' + c.LastName);
            }
        }

        if (!oppsInsert.isEmpty()) {
            System.debug('Inserting ' + oppsInsert.size() + ' opportunities');
            try {
                insert oppsInsert;
                System.debug('SUCCESS: Opportunities inserted');
            } catch (DmlException e) {
                System.debug('ERROR inserting opportunities: ' + e.getMessage());
            }
        } else {
            System.debug('No opportunities to insert - oppsInsert list is empty');
        }
    }

    if (Trigger.isUpdate && !triggerHandler.contactRunning) {
        triggerHandler.contactRunning = true;

        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for (Contact c : Trigger.new) {
            Contact old = Trigger.oldMap.get(c.Id);
            String newName = c.FirstName + ' ' + c.LastName;
            String oldName = old.FirstName + ' ' + old.LastName;

            if (oldName == newName || c.AccountId == null) continue;

            for (Opportunity opp : [
                SELECT Id, Name FROM Opportunity
                WHERE AccountId = :c.AccountId AND Name = :oldName
            ]) {
                opp.Name = newName;
                oppsToUpdate.add(opp);
            }
        }

        if (!oppsToUpdate.isEmpty()) {
            triggerHandler.opportunityTRunning = true;
            update oppsToUpdate;
            triggerHandler.opportunityTRunning = false;
        }

        triggerHandler.contactRunning = false;
    }
}
