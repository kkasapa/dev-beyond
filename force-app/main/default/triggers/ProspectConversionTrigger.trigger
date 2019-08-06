trigger ProspectConversionTrigger on Contact (after insert) {
   
   ContactToProspectConversion.convertToPropsect(trigger.newMap);
}