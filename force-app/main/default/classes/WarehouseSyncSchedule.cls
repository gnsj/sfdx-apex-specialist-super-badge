global class WarehouseSyncSchedule implements Schedulable{
	//Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
	//System.schedule('Scheduled Job 1', '0 1 * * * ?', new WarehouseSyncSchedule());
	//
	//This test runs a scheduled job at midnight Sept. 3rd. 2022
   	//public static String CRON_EXP = '0 0 0 3 9 ? 2022';


    global void execute(SchedulableContext ctx) {
        WarehouseCalloutService.runWarehouseEquipmentSync();
    }  
}