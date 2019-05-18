@isTest
private class WarehouseCalloutServiceTest {
    @isTest static void testRunWarehouseEquipmentSyncPositive() {
        
        Product2 prod = new Product2();
        prod.Cost__c = 50;
        prod.Name = 'Ball Valve 10 cm';
        prod.Lifespan_Months__c = 12;
        prod.Maintenance_Cycle__c = 365;
        prod.Current_Inventory__c = 50;
        prod.Replacement_Part__c = true;
        prod.Warehouse_SKU__c = '100004';
        insert prod;
        System.assertEquals(1, [SELECT count() FROM Product2 WHERE Name = 'Ball Valve 10 cm']);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        Test.startTest();
        	WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();
        
        //check if equipment is updated
        system.assertEquals(300, [SELECT Id, Cost__c FROM Product2 WHERE Warehouse_SKU__c='100004'].Cost__c);
    }
    
    @isTest static void testRunWarehouseEquipmentSyncNegative() {
        Product2 prod = new Product2();
        prod.Cost__c = 50;
        prod.Name = 'Ball Valve 10 cm';
        prod.Lifespan_Months__c = 12;
        prod.Maintenance_Cycle__c = 365;
        prod.Current_Inventory__c = 50;
        prod.Replacement_Part__c = true;
        prod.Warehouse_SKU__c = '100001';
        insert prod;
        System.assertEquals(1, [SELECT count() FROM Product2 WHERE Name = 'Ball Valve 10 cm']);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        
        Test.startTest();
        	WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();
        
        //we should have now 2 equipaments
        system.assertEquals(2, [SELECT count() FROM Product2]);
        //check if equipment is not updated, once SKU dpesn't match
        system.assertEquals(50, [SELECT Id, Cost__c FROM Product2 WHERE Warehouse_SKU__c='100001'].Cost__c);
        system.assertEquals(300, [SELECT Id, Cost__c FROM Product2 WHERE Warehouse_SKU__c='100004'].Cost__c);
    }
}