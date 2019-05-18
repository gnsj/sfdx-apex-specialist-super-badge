public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    // complete this method to make the callout (using @future) to the
    // REST endpoint and update equipment on hand.
    @future(callout=true)
    public static void runWarehouseEquipmentSync(){
        system.debug('WarehouseCalloutService.runWarehouseEquipmentSync()');
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            //The callout’s JSON response returns the equipment records that you upsert in Salesforce.
            List<Equipment> inventoryEquipments = (List<Equipment>)Json.deserialize(response.getBody(), List<Equipment>.class);
            system.debug('WarehouseCalloutService.runWarehouseEquipmentSync.inventoryEquipments >>> ' + inventoryEquipments);
            
            List<Product2> equipmentsToUpdate = new List<Product2>();
            for(Equipment e : inventoryEquipments){
                //Your class maps the following fields: replacement part (always true), cost, current inventory, lifespan, maintenance cycle, and warehouse SKU.
                Product2 equip = new Product2();
                equip.Cost__c = e.cost;
                equip.Current_Inventory__c = e.quantity;
                equip.Lifespan_Months__c = e.lifespan;
                equip.Maintenance_Cycle__c = e.maintenanceperiod;
                equip.Warehouse_SKU__c = e.sku;
                equip.Replacement_Part__c = e.replacement;
                equip.Name = e.name;
                equipmentsToUpdate.add(equip);

            }
            
            system.debug('WarehouseCalloutService.runWarehouseEquipmentSync.equipmentsToUpdate >>> ' + equipmentsToUpdate);
            //Use the warehouse SKU as the external ID to identify which equipment records to update within Salesforce.
            if(equipmentsToUpdate.size() > 0){
                Database.upsert(equipmentsToUpdate, Product2.Fields.Warehouse_SKU__c);
            }
        }
    }
    
    class Equipment{
        public boolean replacement{get;set;}
        public Integer quantity{get;set;}
        public String name{get;set;}
        public Decimal maintenanceperiod{get;set;}
        public Decimal lifespan{get;set;}
        public Decimal cost{get;set;}
        public String sku{get;set;}
    }

}