global class ProspectProgramChildsDeleteUtil {

    webservice static String deleteProspectProgramChilds(Id sobjectId) {
    
        String responseMsg;
        Savepoint sp = Database.setSavepoint();
        try {
        
            if (sobjectId != null) {
            
                String sobjectIdString = String.valueOf(sobjectId);
                
                if ((sobjectIdString.length() == 15 || sobjectIdString.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', sobjectIdString)) {
                
                    String prospectKeyPrefix = nu_dse__Prospect__c.SObjecttype.getDescribe().getKeyPrefix();
                    String programKeyPrefix = nu_dse__Program__c.SObjecttype.getDescribe().getKeyPrefix();
                    
                    String objectName;
                    
                    if (sobjectIdString.startsWith(prospectKeyPrefix)) {
                    
                        objectName = 'nu_dse__Prospect__c';
                        responseMsg = 'Prospect and it\'s childs deleted successfully';
                    } else if (sobjectIdString.startsWith(programKeyPrefix)) {
                        
                        objectName = 'nu_dse__Program__c';
                        responseMsg = 'Program and it\'s childs deleted successfully';
                    }
                    
                    if (String.isNotBlank(objectName)) {
                        
                        // Delete Bank Account
                        String bankAcctQuery = 'SELECT Id FROM nu_dse__Bank_Account__c WHERE ' + objectName + ' = :sobjectId';
                        
                        List<nu_dse__Bank_Account__c> bankAcctToDelList = Database.query(bankAcctQuery);
                        
                        if (bankAcctToDelList != null && bankAcctToDelList.isEmpty() == False) {
                        
                            delete bankAcctToDelList;
                        }
                        
                        // Delete Tradeline
                        String tradelineQuery = 'SELECT Id FROM nu_dse__Tradeline__c WHERE ' + objectName + ' = :sobjectId';
                        
                        List<nu_dse__Tradeline__c> tradelineToDelList = Database.query(tradelineQuery);
                        
                        if (tradelineToDelList != null && tradelineToDelList.isEmpty() == False) {
                        
                            delete tradelineToDelList;
                        }
                        
                        // Delete Financial Profile
                        String financialProfileQuery = 'SELECT Id FROM nu_dse__Financial_Profile__c WHERE ' + objectName + ' = :sobjectId';
                        
                        List<nu_dse__Financial_Profile__c> financialProfileToDelList = Database.query(financialProfileQuery);
                        
                        if (financialProfileToDelList != null && financialProfileToDelList.isEmpty() == False) {
                        
                            delete financialProfileToDelList;
                        }
                        
                        // Delete Payment
                        String paymentQuery = 'SELECT Id FROM nu_dse__Payment__c WHERE ' + objectName + ' = :sobjectId';
                        
                        List<nu_dse__Payment__c> paymentToDelList = Database.query(paymentQuery);
                        
                        if (paymentToDelList != null && paymentToDelList.isEmpty() == False) {
                        
                            delete paymentToDelList;
                        }
                        
                        // Delete Group Task
                        String groupTaskQuery = 'SELECT Id FROM nu_dse__Group_Task__c WHERE ' + objectName.removeStart('nu_dse__') + ' = :sobjectId';
                        
                        List<nu_dse__Group_Task__c> grpTaskToDelList = Database.query(groupTaskQuery);
                        
                        if (grpTaskToDelList!= null && grpTaskToDelList.isEmpty() == False) {
                        
                            delete grpTaskToDelList;
                        }
                        
                        // Delete Task 
                        delete [SELECT Id FROM Task WHERE WhatId = :sobjectId];
                        
                        // Delete Event
                        delete [SELECT Id FROM Event WHERE WhatId = :sobjectId];
                        
                        // Delete Attachment
                        delete [SELECT Id FROM Attachment WHERE ParentId = :sobjectId];
                        
                        if (objectName == 'nu_dse__Program__c') {
                            
                            // Delete Prospect
                            List<nu_dse__program__c> programList = [SELECT Id, Prospect_ID__c FROM nu_dse__program__c WHERE Id = :sobjectId];
                        
                            if (programList != null && programList.isEmpty() == False) {
                            
                                delete [SELECT Id FROM nu_dse__prospect__c WHERE Id = :programList[0].Prospect_ID__c];
                                delete programList;
                            }
                        } else if (objectName == 'nu_dse__Prospect__c') {
                            
                            String quoteQuery = 'SELECT Id FROM nu_dse__Quote__c WHERE ' + objectName + ' = :sobjectId';
                            List<nu_dse__Quote__c> quoteToDelList = Database.query(quoteQuery);
                            if (quoteToDelList != null && quoteToDelList.isEmpty() == False) {
                            
                                delete quoteToDelList;
                            }
                            
                            List<nu_dse__Prospect__c> prospectList = [SELECT Id FROM nu_dse__prospect__c WHERE Id = :sobjectId];
                            if (prospectList != null && prospectList.isEmpty() == False) {
                                
                                delete prospectList;
                            }
                        }
                    }
                } else {
                
                    responseMsg = 'Error: Invalid Id';
                }
            } else {
            
                responseMsg = 'Error: Invalid Id';
            }
        } catch(Exception e) {
        
            Database.rollback(sp);
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
            
                responseMsg = 'Error: '+e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
            } else {
            
                responseMsg = 'Error: '+e.getMessage();
            }
        }
        return responseMsg;
    }
}