({
    handleRegionChange: function(component, event) {
        component.set('v.selectedRegion', event.getSource().get('v.value'));
    },

    handleCreate: function(component, event, helper) {
      console.log('>>> handleCreate disparado');
        console.log('firstName:',  component.get('v.firstName'));
        console.log('lastName:',   component.get('v.lastName'));
        console.log('region:',     component.get('v.selectedRegion'));
        console.log('accountId:',  component.get('v.accountId'));
        helper.createContact(component);
    }
})