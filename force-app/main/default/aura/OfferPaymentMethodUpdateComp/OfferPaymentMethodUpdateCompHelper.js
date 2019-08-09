({
	setPaymentColumns : function(cmp) {
        console.log('setting columns');
        cmp.set('v.paymentColumns', [
            {label: 'Payment Name', fieldName: 'Name', type: 'text'},
            {label: 'Amount', fieldName: 'nu_dse__Amount__c', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}},
            {label: 'Total Amount', fieldName: 'nu_dse__Total_Amount__c', type: 'currency', typeAttributes: { currencyCode: 'USD', maximumSignificantDigits: 5}},
            {label: 'Transaction Status', fieldName: 'nu_dse__Transaction_Status__c', type: 'text'},
            {label: 'Transaction Method', fieldName: 'nu_dse__Transaction_Method__c', type: 'text'}
        ]);
}
})