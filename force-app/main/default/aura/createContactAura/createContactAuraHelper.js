({
    createContact: function(component) {
        var firstName  = component.get('v.firstName');
        var lastName   = component.get('v.lastName');
        var region     = component.get('v.selectedRegion');
        var accountId  = component.get('v.accountId');
        console.log("=== VALORES DEL FORMULARIO ===");
console.log("firstName:", firstName);
console.log("lastName:", lastName);
console.log("region:", region);
console.log("accountId:", accountId);
console.log("accountId tiene valor?:", !!accountId);        if (!firstName || !lastName || !region) {
          console.log("Estoy en el error ")
            component.set('v.errorMessage', 'Please fill all fields and select a region.');
            return;
        }

        var action = component.get('c.createContact');
        action.setParams({
            firstName : firstName,
            lastName  : lastName,
            recordTypeDeveloperName : region,
            accountId : accountId
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                console.log("SUCCESS", response.getReturnValue());
                component.set('v.successMessage', 'Contact created successfully!');
                component.set('v.errorMessage', '');
            } else {
              console.log("errorMessage");
                component.set('v.errorMessage', 'Error: ' + response.getError()[0].message);
            }
        });

        $A.enqueueAction(action);
    }
})