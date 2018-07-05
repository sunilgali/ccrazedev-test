public class CCTwitterAPI {
    public static String access_token {get;set;}
    @AuraEnabled
    public static string callTwitterAPI(String value) {
        system.debug('callTwitterAPI'+value);
        authenticate();
        return getAPIResponse(value);
    }
    
    
    /*Methods*/
    public static void authenticate() {
        Social_Media_Feed__mdt twtcs = [SELECT 	API_Consumer_Client_Key__c,API_Consumer_Client_Secret__c  FROM Social_Media_Feed__mdt WHERE Label='Twitter Hash Feed'];
        
        String keyencoded = EncodingUtil.urlEncode(twtcs.API_Consumer_Client_Key__c,'UTF-8');
        String secretkeyencoded = EncodingUtil.urlEncode(twtcs.API_Consumer_Client_Secret__c, 'UTF-8');
        String sFinal = keyencoded + ':' + secretkeyencoded;
        Blob headerValue = Blob.valueOf(sFinal);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.twitter.com/oauth2/token');
        req.setMethod('POST');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        //system.debug(authorizationHeader);
        req.setHeader('Authorization', authorizationHeader);
        req.setBody('grant_type=client_credentials');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        //system.debug('res: '+res);
        JSONParser parser = JSON.createParser(res.getBody());
        while(parser.nextToken() != null)
        {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME)
            {
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'access_token')
                {
                    access_token = parser.getText();
                }
            }
        }
    }
    
    public static string getAPIResponse(String value) {
        system.debug('getAPIResponsevalue'+value);
        HttpRequest req2 = new HttpRequest();
        string URL='https://api.twitter.com/1.1/search/tweets.json?q=%23'+value+'&count=50';
        req2.setEndpoint(URL);
        req2.setMethod('GET');
        
        //Call Bearer token Method
        String authorizationHeader = 'Bearer ' + access_token;
        //system.debug('authHead '+authorizationHeader);
        req2.setHeader('Authorization', authorizationHeader);
        
        Http http = new Http();
        HTTPResponse res = http.send(req2);
        string apiRes = res.getBody();
        //system.debug(apiRes);
        return JSON.serialize(generateTweets(apiRes));
    }
    
    public static List<tweetData> generateTweets(string apiRes){
        List<tweetData> retrievedTweets = new List<tweetData>();
        JSONParser parser = JSON.createParser(apiRes);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Tweet twt = (Tweet)parser.readValueAs(Tweet.class);
                        if (twt.created_at != null && twt.retweeted_status == null) {
                            // (twt.retweeted_status) == null is for filtering out retweets
                            TweetData td = new TweetData();
                            //td.userName = twt.user.name;
                            td.screenName = twt.user.screen_name;
                            td.userName = '<span class="userNameLink"><b><a href="https://twitter.com/'+twt.user.screen_name+'" target="_blank" title="@'+twt.user.screen_name+' (Opens New Tab)"><span class="userName">'+twt.user.name+'</span></b> @'+twt.user.screen_name+'</a></span>';
                            
                            String bodyText = twt.text;
                            /*URL hyperlink*/
                            Pattern patt3 = Pattern.compile('(https:\\/\\/.\\p{Punct}co\\/\\w+)\\b');
                            Matcher match3 = patt3.matcher(bodyText);
                            string result3 = '';
                            while (match3.find()) {
                                result3 = match3.group();
                                result3 = result3.replace(' ', '');
                                String searchHTML='<a href="'+result3+'" target="_blank">'+result3+'</a>';
                                bodyText = bodyText.replace(result3,searchHTML);
                            }
                            
                            /*hash hyperlink*/
                            Pattern patt = Pattern.compile('(#\\w+)\\b');
                            Matcher match = patt.matcher(bodyText);
                            string result = '';
                            system.debug('\n');
                            system.debug('USER = '+twt.user.name);
                            while (match.find()) {
                                result = match.group();
                                result = result.replace(' ', '');//#word
                                String search = result.replace('#', '');//word
                                String searchHTML='<a href="https://twitter.com/hashtag/' + search + '?src=hash" target="_blank">' + result + '</a>';
                                bodyText = bodyText.replaceAll('\\'+result+'\\b',searchHTML);
                            }
                            
                            /*@ hyperlink*/
                            Pattern patt2 = Pattern.compile('(?:\\s|\\A)[@]+([A-Za-z0-9-_]+)');
                            Matcher match2 = patt2.matcher(bodyText);
                            result = '';
                            while (match2.find()) {
                                result = match2.group();
                                result = result.replace(' ', '');
                                String search = result.replace('@', '');
                                String searchHTML='<a href="https://twitter.com/' + search + '" target="_blank">' + result + '</a>';
                                bodyText = bodyText.replace(result,searchHTML);
                            }
                            //system.debug(bodyText);
                            td.body = bodyText;
                            td.dateCreated = formatTime(twt.created_at);
                            td.profileImg = '<a href="https://twitter.com/'+twt.user.screen_name+'" target="_blank" title="@'+twt.user.screen_name+' (Opens New Tab)">'+
                                '<img src="'+twt.user.profile_image_url+'"/></a>';
                            if (retrievedTweets.size() <= 19) { //20 total
                                retrievedTweets.add(td);
                            }
                        }
                    }
                }
            }
        } //end of 1st while
        return retrievedTweets;
    } //end of generateTweets
    
    public static string formatTime(string td) {
        //needs a little polishing
        list<string> timeInfo = td.split(' ');
        list<string> clockTime = timeInfo.get(3).split(':');
        
        Map <String, Integer> months = new Map <String, Integer> {'Jan'=>1, 'Feb'=>2
            , 'Mar'=>3, 'Apr'=>4, 'May'=>5, 'Jun'=>6, 'Jul'=>7, 'Aug'=>8, 'Sep'=>9
            , 'Oct'=>10, 'Nov'=>11, 'Dec'=>12};
                
                integer day = integer.valueof(timeInfo.get(2)); //not referring to "monday" "tue" etc
        integer month = months.get(timeInfo.get(1));
        integer year = integer.valueOf(timeInfo.get(5));
        integer hour = integer.valueOf(clockTime.get(0));
        integer minute = integer.valueOf(clockTime.get(1));
        integer second = integer.valueOf(clockTime.get(2));
        
        DateTime mydatetime = DateTime.newInstance(year, month, day, hour, minute, second);
        return mydatetime.format();
    }
    
    /*Classes for nested Tweet properties*/
    public class TweetData { //final data for lightning output
        public string userName;
        public string screenName;
        public string body;
        public string dateCreated;
        public string profileImg;
    }
    public class Tweet {
        public string created_at;
        public string text;
        public UserInfo user; //type is a custom object/class
        public Retweeted retweeted_status;
        public Tweet(string ca, string txt, UserInfo usr) {
            created_at = ca;
            text = txt;
            user = usr;
            //user = usr.clone();
        }
    }
    public class UserInfo {
        public string profile_image_url;
        public string name;
        public string screen_name;
        public UserInfo(string pi, string nm, string un) {
            profile_image_url = pi;
            name = nm;
            screen_name = un;
        }
    }
    public class Retweeted {
        public string created_at;
        public Retweeted(string ca) {
            created_at = ca;
        }
    }
    
}