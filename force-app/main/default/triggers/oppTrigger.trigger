trigger oppTrigger on Opportunity (after update) {

  if(triggerHandler.opportunityTRunning){
      return;
    }
  
  triggerHandler.opportunityTRunning = true;
  Map<Id,String> accNewOpp = new Map<Id,String>();

  for(Opportunity opp : Trigger.new){
      Opportunity aux = Trigger.oldMap.get(opp.Id);
      if(opp.Name!= aux.Name && opp.AccountId != null){
        accNewOpp.put(opp.AccountId, opp.Name);
        }
    }

    if(!accNewOpp.isEmpty()){
        List<Contact> contacts = new List<Contact>();

        for(Opportunity opp : Trigger.new){
            Opportunity aux = Trigger.oldMap.get(opp.Id);
            if(opp.Name == aux.Name || opp.AccountId==null){
                continue;
              }
              list<Contact> candidate = [SELECT Id, FirstName, LastName FROM Contact
                WHERE AccountId = :opp.AccountId ];

              for(Contact c : candidate ){
                if((c.FirstName+' '+ c.LastName) == aux.Name){
                String[] partName = opp.Name.split('',2);
                  if(partName.size() > 0){
                      c.FirstName = partName[0];
                      if(partName.size() > 1){
                          c.LastName = partName[1];
                        }else{
                            c.LastName = opp.Name;
                          }
                    }else{
                        c.FirstName = '';
                      }
                }
                }
          }
        if(!contacts.isEmpty()){
            triggerHandler.contactRunning = true;
            update contacts;
            triggerHandler.contactRunning = false;
          }
      }

      triggerHandler.opportunityTRunning = false;

    
}