public class Schedulable_PlatformEventUsageCheck implements Schedulable {
    public void execute(SchedulableContext context) {

        //map for name uniqueness
        Map<String, Platform_Event_Tracker__c> peumMap = new Map<String, Platform_Event_Tracker__c>();
        //loop through Order By EndDate ASC with the most recent making sure only the rolling 24 hour record is being tracked and overwritten
        for(PlatformEventUsageMetric peum :[SELECT Id, Name, StartDate, EndDate, Value FROM PlatformEventUsageMetric where EndDate = Today Order By EndDate ASC]){
            Platform_Event_Tracker__c pet = new Platform_Event_Tracker__c();
            String name = peum.Name +' '+DateTime.now();
            pet.Name = name;
            pet.StartDate__c = peum.StartDate;
            pet.EndDate__c = peum.EndDate;
            pet.Value__c = peum.Value;
            pet.UniqueName__c = name;//when saved this will throw any errors for duplicates, a duplicate could occur if the previous day had events being published / delivered but not today as the end date would be todays date.
            peumMap.put(peum.Name, pet);
        }

        List<Database.SaveResult> srList = Database.insert(peumMap.values());
        // Iterate through each returned result change to save logs if you would like
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
}