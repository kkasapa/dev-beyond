trigger ProspectConversionTrigger on Contact (after insert) {
   // Depricate...SF-581
   //ContactToProspectConversion.convertToPropsect(trigger.newMap);
}