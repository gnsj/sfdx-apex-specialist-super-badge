public class MaintenanceRequestHelper {

    //new maintenance request
    public static void updateWorkOrders(List<Case> lstCases){ 
        system.debug('MaintenanceRequestHelper.createRoutineMaintenance()');
        system.debug('MaintenanceRequestHelper.createRoutineMaintenance.lstCases >>> ' + lstCases);
        
        //maintenance request of type Repair or Routine Maintenance is Closed
        List<Case> closedRepairOrRoutineMaintances = new List<Case>();
        Set<Id> maintenanceIds = new Set<Id>();
        for(Case c : lstCases){
            if((c.Type == 'Repair' || c.Type == 'Routine Maintenance') && c.Status == 'Closed'){
                closedRepairOrRoutineMaintances.add(c);
                maintenanceIds.add(c.Id);
            }
        }
        system.debug('MaintenanceRequestHelper.createRoutineMaintenance.maintenanceIds >>> ' + maintenanceIds);
        
        if(maintenanceIds.size() > 0) {
            //mapping all equipaments for each maintenance
            Map<Id, List<Product2>> mapEquipamentsByMaintenanceId = new Map<Id, List<Product2>>();
            mapEquipamentsByMaintenanceId = mappingEquipamentsByMaintenance(maintenanceIds);
            
            //create a new maintenance request for a future routine checkup
            List<Case> futureRoutineCheckupMaintenances = new List<Case>();
            for(Case c : closedRepairOrRoutineMaintances){
                Case newRoutineCase = new Case();
                //If multiple work parts are used in the maintenance request, choose the shortest maintenance cycle to define the service date.
                newRoutineCase.Date_Due__c = Date.today() + Integer.valueOf(mapEquipamentsByMaintenanceId.get(c.Id)[0].Maintenance_Cycle__c);
                //new request is tied to the same vehicle and piece of equipment to be serviced as the original closed service request
                newRoutineCase.Vehicle__c = c.Vehicle__c;
                newRoutineCase.Equipment__c = c.Equipment__c;
                //new request's Type should be set as Routine Maintenance
                newRoutineCase.Type = 'Routine Maintenance';
                //The Subject should not be null
                newRoutineCase.Subject = 'Routine Checkup';
                //Report Date field reflects the day the request was created
                newRoutineCase.Date_Reported__c = Date.today();
                futureRoutineCheckupMaintenances.add(newRoutineCase);
            }
            system.debug('MaintenanceRequestHelper.createRoutineMaintenance.futureRoutineCheckupMaintenances >>> ' + futureRoutineCheckupMaintenances);
            system.debug('MaintenanceRequestHelper.createRoutineMaintenance.futureRoutineCheckupMaintenances.size() >>> ' + futureRoutineCheckupMaintenances.size());
            
            if(futureRoutineCheckupMaintenances.size() > 0)
                insert futureRoutineCheckupMaintenances;
        }
    }
    
    //mapping equipament for each maintenance
    private static Map<Id, List<Product2>> mappingEquipamentsByMaintenance(Set<Id> closedRepairOrRoutineMaintancesId){
        system.debug('MaintenanceRequestHelper.mappingEquipamentsByMaintenance()');
        
        List<Case> maintenancesList = [SELECT Id,Equipment__c FROM Case WHERE Id IN :closedRepairOrRoutineMaintancesId];
        
        Set<Id> equipamentIds = new Set<Id>();
        for(Case c : maintenancesList){
            equipamentIds.add(c.Equipment__c);
        }
        system.debug('MaintenanceRequestHelper.mappingEquipamentsByMaintenance.equipamentIds >>> ' + equipamentIds);
        
        Map<Id, Product2> mapEquipaments = new Map<Id, Product2>([SELECT Id, Maintenance_Cycle__c FROM Product2 WHERE Id IN :equipamentIds ORDER BY Maintenance_Cycle__c ASC]);
        system.debug('MaintenanceRequestHelper.mappingEquipamentsByMaintenance.mapEquipaments >>> ' + mapEquipaments);
        
        Map<Id, List<Product2>> mapEquipamentsByMaintenanceId = new Map<Id, List<Product2>>();
        for(Case c : maintenancesList){
            List<Product2> tempList = new List<Product2>();
            tempList.add(mapEquipaments.get(c.Equipment__c));
            mapEquipamentsByMaintenanceId.put(c.Id, tempList);
        }
        
        system.debug('MaintenanceRequestHelper.mappingEquipamentsByMaintenance.mapEquipamentsByMaintenanceId >>> ' + mapEquipamentsByMaintenanceId);
        return mapEquipamentsByMaintenanceId;
    }
}