
public class DynamicJobScheduler {
    
    private class DynamicJobSchedulerException extends Exception {}
    
    //anything above 30 will only create 1 per hour and anything above 60 minutes will not create a schedulable job
    public static void scheduleRecurringJob(String jobName, Integer minutes, String batchName){
        Type batchType = Type.forName(batchName);
        Object batchObj = batchType.newInstance();
        if(!(batchObj instanceof Schedulable)) throw new DynamicJobSchedulerException('The batch must implement the Schedulable interface https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_scheduler.htm');
        Schedulable SchedulableObj = (Schedulable)batchObj;
        
        Datetime sysTime = System.now();
        Integer numberOfJobs = 60/minutes;
        if(numberOfJobs <= 0)throw new DynamicJobSchedulerException('Anything above 60 minutes will not create a scheduleable job');
        for(Integer i = 0; i < numberOfJobs; i++){
            Integer addMinutes = i*minutes;
            Datetime sysTimeWithMinutes = System.now().addMinutes(addMinutes);
            String cronExpression = '' + 0 + ' ' + sysTimeWithMinutes.minute() +' * * * ?';
            system.debug(cronExpression);
            System.schedule(jobName+addMinutes, cronExpression, SchedulableObj);//make dynamic
        }
        
    }
}
