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

    }

    public HttpRequest BuildQuery(Double debt, Double payment)
    {
        HttpRequest request = new HttpRequest();
        String body;
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/vnd.api+json');
        body = '{"data":{"type":"savings","attributes":{"current_balance":'+ debt +',"minimum_payment":'+ payment +',"annual_interest_rate":"'+ rate +'"}}}';
        request.setBody(body);
        return request;
    }
    public HttpResponse sendRequest(HttpRequest req)
    {
        HTTP http = new http();
        HTTPResponse resp = http.send(req);
        return resp;
    }
}