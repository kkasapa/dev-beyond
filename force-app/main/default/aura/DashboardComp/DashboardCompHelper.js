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
    },
    setTradelinesColumns : function(cmp) {
        console.log('setting columns');
        cmp.set('v.columns', [
            {label: 'Tradeline Name', fieldName: 'tradelineName', type: 'text', sortable: true},
            {label: 'Offer Name', fieldName: 'offerName', type: 'text', sortable: true},
            {label: 'Offer Amount', fieldName: 'offerAmount', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}},
            {label: 'Payment Name', fieldName: 'paymentName', type: 'text', sortable: true},
            {label: 'Payment Sequence Number', fieldName: 'paymentSequenceNumber', type: 'integer', sortable: true},
            {label: 'Schedule Date', fieldName: 'scheduleDate', type: 'date', sortable: true},
            {label: 'Payment Amount', fieldName: 'paymentAmount', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}, sortable: true},
            {label: 'Payment Total Method', fieldName: 'paymentTotalAmount', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}, sortable: true}
        ]);
    },
    handleActive: function (cmp, event) {
        var tab = event.getSource();
        console.log('ids->'+tab.get('v.id'));
        switch (tab.get('v.id')) {
            case 'tradelineSettlement' :
                this.injectComponent(cmp, 'c:RelatedListTableComp', tab);
                break;
            case 'tradelineSettlementsPending' :
                this.injectComponent(cmp,'c:RelatedListTableComp', tab);
                break;
            case 'otherTradelines':
                this.injectComponent(cmp, 'c:RelatedListTableComp', tab);
                break;
            case 'tradelineSettlementPayments':
                this.injectComponent(cmp, 'c:RelatedListTableComp', tab);
                break;
        }
    },
    injectComponent: function (cmp, name, target) {
        console.log('injecting');
        let data = cmp.get('v.data');
        $A.createComponent(name, {
            "data" : data,
            "column" : cmp.get("v.columns"),
            "iconName" : "standard:individual", 
            "cardTitle" : "Tradelines/Creditors" 
        }, function (contentComponent, status, error) {
            if (status === "SUCCESS") {
                target.set('v.body', contentComponent);
            } else {
                throw new Error(error);
            }
        });
    }
})