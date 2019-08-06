@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global static HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://lowcost-env.qhbvrijfxy.us-east-2.elasticbeanstalk.com/odata/PreLead', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        // 
        // 
        if(req.getBody().containsIgnoreCase('MailerId=1')){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"@odata.context":"http://uat.beyondfinance.com/odata/$metadata#PreLead/$entity","MailerId":"1","MailDate":"2010-01-12T00:00:00Z","ExpirationDate":"2010-01-11T00:00:00Z","InsertDate":"2010-01-01T00:00:00Z","FirstName":"John123","MiddleName":"Dave","LastName":"Sanders","Address1":"123 st","Address2":"","City":"Jacksonville","State":"FL","Zip":"12345","EmailAddress":"john@test.com","PhoneNumber":"99988866623","UnsecuredDebtAmount":100,"BestTimeToCall":"Morning","PardotId":"1045678","StateQualification":"pass","DebtAmountQualification":"fail"}]');
        res.setStatusCode(200);
        return res;
        }else{
            
        HttpResponse res2 = new HttpResponse();
        res2.setHeader('Content-Type', 'application/json');
        res2.setBody('[{"@odata.context":"http://uat.beyondfinance.com/odata/$metadata#PreLead/$entity","MailerId":"1","MailDate":"2010-01-12T00:00:00Z","ExpirationDate":"2010-01-11T00:00:00Z","InsertDate":"2010-01-01T00:00:00Z","FirstName":"John123","MiddleName":"Dave","LastName":"Sanders","Address1":"123 st","Address2":"","City":"Jacksonville","State":"FL","Zip":"12345","EmailAddress":"john@test.com","PhoneNumber":"99988866623","UnsecuredDebtAmount":100,"BestTimeToCall":"Morning","PardotId":"1045678","StateQualification":"pass","DebtAmountQualification":"fail"}]');
        res2.setStatusCode(200);
           return res2;  
        }
    }
}