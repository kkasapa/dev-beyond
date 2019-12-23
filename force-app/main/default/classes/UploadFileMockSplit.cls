global with sharing class UploadFileMockSplit implements HTTPCalloutMock{
    
    
    global HTTPResponse respond(HTTPRequest req){
        
        HttpResponse res = new HTTPResponse();
        String json = ('{"splitNodes":[{"title":"Limited Power of Attorney to Speak and Negotiate","outputFileName":"P-38060Shravan DasariLPOA.pdf"},{"title":"Authorization Letter for Beyond Finance, Inc.","outputFileName":"P-38060Shravan DasariAuthLetter.pdf"},{"title":"Authorization To Communicate for Beyond Finance, Inc.","outputFileName":"P-38060Shravan DasariATC.pdf"}],"sourceFileName":"Program/P-38060/P-38060-P-38060-AUTHORIZATION-SPAA-Enrollment-Agreement.pdf","bucket":"bf-test-salesforce-upload"}');
        json = '['+json+']';        
        res.setHeader('Content-Type', 'application/JSON');
        res.setBody(json);
        res.setStatusCode(200);
        return res;
    }    
}