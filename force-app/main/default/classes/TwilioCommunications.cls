global class TwilioCommunications {

    
    global static nu_dse.TwilioMessage sendSMS(String toPhone, String fromPhone, String sms) {
     
        nu_dse.TwilioRestClient client = nu_dse.TwilioAPI.getDefaultClient();
        
        /*
         * Only Supports US numbers. 
         */ 
        
        if(!toPhone.startsWith('+1')){
            
            toPhone = '+1'+toPHone;
        }
       
        Map<String,String> properties = new Map<String,String>(); 
        properties.put('To',toPhone); 
        properties.put('From',fromPhone);
        properties.put('Body',sms);
        
             
          nu_dse.TwilioMessage message = client.getAccount().getMessages().create(properties); 
          system.debug('message-->'+message);
          return message ;
    }
}