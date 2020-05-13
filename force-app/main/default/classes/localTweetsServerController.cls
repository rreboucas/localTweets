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
}
