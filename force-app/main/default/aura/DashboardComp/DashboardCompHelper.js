({
    helperMethod : function() {

    },

    setColumns : function(cmp) {
        console.log('setting columns');
        cmp.set('v.columns', [
            {label: 'Tradeline Name', fieldName: 'tradelineName', type: 'text', sortable: true},
            {label: 'Original Balance', fieldName: 'originalBalance', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}, sortable: true},
            {label: 'Current Balance', fieldName: 'currentBalance', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}, sortable: true},
            {label: 'Offer Name', fieldName: 'offerName', type: 'text', sortable: true},
            {label: 'Offer Amount', fieldName: 'offerAmount', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}},
            {label: 'Savings Percent', fieldName: 'savingsPercent', type: 'integer', sortable: true},
            {label: 'Payment Name', fieldName: 'paymentName', type: 'text', sortable: true},
            {label: 'Payment Sequence Number', fieldName: 'paymentSequenceNumber', type: 'integer', sortable: true},
            {label: 'Schedule Date', fieldName: 'scheduleDate', type: 'date', sortable: true},
            {label: 'Payment Amount', fieldName: 'paymentAmount', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}, sortable: true},
            {label: 'Payment Total Method', fieldName: 'paymentTotalAmount', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}, sortable: true}
        ]);
    }
})