@isTest
private class WarehouseSyncScheduleTest {
    
    public static testMethod void testschedule() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        Test.StartTest();
        //WarehouseSyncSchedule sh1 = new WarehouseSyncSchedule();
        //String sch = '0 0 23 * * ?'; 
        //system.schedule('Test Territory Check', sch, sh1); 
        System.schedule('Scheduled Job 1', '0 1 * * * ?', new WarehouseSyncSchedule());
        Test.stopTest();
    }
    
}