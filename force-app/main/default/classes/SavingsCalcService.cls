/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
*
* SavingsCalcService will be used to call the savings calculator microservice and return output directly. 
* 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Vlad Polovtsev   <vpolovtsev@beyondfinance.com>
* @modifiedBy     Vlad Polovtsev   <vpolovtsev@beyondfinance.com>
* @maintainedBy   Vlad Polovtsev   <vpolovtsev@beyondfinance.com>
* @version        1.0
* @created        2019-08-08
* @modified       2019-08-08
* @systemLayer    Utility
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

/*
curl -X POST \
  https://beyondfinance.com/api/v1/savings \
  -H 'Content-Type: application/vnd.api+json' \
  -d '{"data":{"type":"savings","attributes":{"current_balance":10000000000,"minimum_payment":200000000,"annual_interest_rate":"16.41"}}}'
*/
public class SavingsCalcService{

    public string endpoint;
    public double rate;

    public SavingsCalcService()
    {
        Savings_Calculator_Microservice__c settings = Savings_Calculator_Microservice__c.getInstance(UserInfo.getUserId());

        if(settings != null)
        {
            endpoint = settings.Endpoint__c;
            rate = settings.InterestRate__c;
        }
        if(endpoint == null)
        {
			endpoint = 'https://beyondfinance.com/api/v1/savings';
            rate = 16.4;           
        }

    }

    public HttpRequest BuildQuery(Double debt, Double payment)
    {
        HttpRequest request = new HttpRequest();
        String body;
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setTimeout(2000);
        request.setHeader('Content-Type','application/vnd.api+json');
        body = '{"data":{"type":"savings","attributes":{"current_balance":'+ debt +',"minimum_payment":'+ payment +',"annual_interest_rate":"'+ rate +'"}}}';
        request.setBody(body);
        return request;
    }
    public HttpResponse sendRequest(HttpRequest req)
    {
        if(!Test.isRunningTest())
        {
            HTTP http = new http();
            HTTPResponse resp = http.send(req);
            return resp;
        }
        HTTPResponse resp2 = new HTTPResponse();
        resp2.setStatus('400');
        resp2.setBody('{"data": {"id": "772285","type": "savings","links": {"self": "/api/v1/savings/772285"},"attributes": {"current-balance": 1000.0,"annual-interest-rate": "16.41","minimum-percentage-principle": "20.0","minimum-payment": 200.0,"total-savings": 271.0,"total-months": 18,"total-payments": 1071.0,"absolute-minimum-payment": 15.0}}}');
        return resp2;
    }
}