({
    setColumns : function(cmp) {
        console.log('setting columns');
        cmp.set('v.columns', [
            {label: 'Action', type: 'button', initialWidth: 100, typeAttributes:
                { 
                    label: "Complete", 
                    title: 'Click to Edit', name: 'edit_status', 
                    iconName: 'utility:check', 
                    disabled: 
                    {
                        fieldName: 'actionDisabled'
                    }, 
                    class: 'btn_next'
                }
            },
            {label: 'Task Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true},
            {label: 'Group Task Name', fieldName: 'Name', type: 'text', sortable: true},
            //{label: 'Documents on File', fieldName: 'offerName', type: 'text', sortable: true},
            {label: 'Program Number', fieldName: 'Program__r.Name',  type: 'text', sortable: true},
            {label: 'Subject', fieldName: 'nu_dse__Subject__c', type: 'text'},
            {label: 'Task Created By', fieldName: 'CreatedBy.Name', type: 'text', sortable: true},
            {label: 'Activity Date', fieldName: 'nu_dse__ActivityDate__c', type: 'date', sortable: true},
            {label: 'Status', fieldName: 'nu_dse__Status__c', type: 'text', sortable: true},
            {label: 'Assigned to', fieldName: 'Owner_Name__c', type: 'text', sortable: true},
            {label: 'Notes', fieldName: 'nu_dse__Description__c', type: 'text', sortable: true}
        ]);
    },
})