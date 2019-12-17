import { LightningElement, wire, api } from 'lwc';
import { getRecordUi } from 'lightning/uiRecordApi';

export default class EstimatedBalanceFieldLayout extends LightningElement {
 
    @api programId;
    @wire(getRecordUi, { recordIds: [programId], layoutTypes: ['Full'], modes: ['View'] })
    programRecordUi;

    function1() {
        console.log('-->',this.programId);
    }
    
}