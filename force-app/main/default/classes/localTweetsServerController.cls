public with sharing class localTweetsServerController {
    
    @AuraEnabled
    public String street { get;set; }
    @AuraEnabled
    public String city { get;set; }
    @AuraEnabled
    public String state { get;set; }
    @AuraEnabled
    public String country { get;set; }

    @AuraEnabled(cacheable=true)
    public static localTweetsServerController getLocationAddress(String locationID) {
        localTweetsServerController obj = new localTweetsServerController();

        System.Debug('##### locationID: ' + locationID);

        Sobject address;
        String soql = 'SELECT City,Country,State,Street from Address WHERE ParentId = ' + ' \'' + locationID +'\'' + ' and isDeleted = false order by createddate desc limit 1';
        System.Debug('##### soql: ' + soql);
        if (String.isNotEmpty(locationID))
            address = Database.query(soql);

        if (address != null)
        {
            System.Debug('##### address is not null: ' + address);
            obj.street = (String)address.get('Street');
            obj.city = (String)address.get('City');
            obj.state = (String)address.get('State');
            
        }
        return obj;

    }

    @AuraEnabled(cacheable=true)
    public static localTweetsServerController getOfficialsTweets(String cityState) {
        
        localTweetsServerController obj = new localTweetsServerController();

        /* ------------ Start: authenticate to Twitter: ----------------- */
        Twitter_Integration__mdt twitterSecret = [SELECT Token_Secret__c,Token__c FROM Twitter_Integration__mdt limit 1];

        String oauthConsumerKey = twitterSecret.Token__c;        
        String oauthConsumerSecret = twitterSecret.Token_Secret__c;

        String baseUrl = 'https://api.twitter.com';
        String oauthSignatureMethod = 'HMAC-SHA1';
            
        String keyencoded = EncodingUtil.urlEncode(oauthConsumerKey, 'UTF-8');
        String secretkeyencoded = EncodingUtil.urlEncode(oauthConsumerSecret, 'UTF-8');
        
        //Create Final Key String
        String sFinal = keyencoded + ':' + secretkeyencoded;
        //Convert to Blob
        Blob headerValue = Blob.valueOf(sFinal);
        
        //Build Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.twitter.com/oauth2/token');
        req.setMethod('POST');
        
        //Add Auth Header
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        
        //You need to add this to the request - proved easy to miss in instructions...
        req.setBody('grant_type=client_credentials');
        
        //Make request
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        System.debug('########## Twitter authentication responseBody : ' + responseBody);
        String stoken;
        //Parse JSON for Bearer Token
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'access_token'){
            parser.nextToken();
            stoken = parser.getText();
            System.debug('########## bearer token : ' + stoken);
            }
        }

        /* ------------ End: authenticate to Twitter: ----------------- */

        return obj;
    }
}
