({
    handleRegionChange: function(component, event) {
        component.set('v.selectedRegion', event.getSource().get('v.value'));
    },

    handleCreate: function(component, event, helper) {
       
        helper.createContact(component);
    },

    init: function(component, event, helper) {
        try {
            var url = window.location.pathname;
           
            
            var parts = url.split('/');
            for (var i = 0; i < parts.length; i++) {
                var part = parts[i];
                if (part.length === 18 && /^[a-zA-Z0-9]{18}$/.test(part)) {
                                        if (part.startsWith('001')) {
                        component.set('v.accountId', part);
                                                break;
                    }
                }
            }
        } catch (e) {
            console.log('Error:', e.message);
        }
    }
})