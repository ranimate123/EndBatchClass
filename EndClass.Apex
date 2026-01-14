global class LeaveTrackerEndDateBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, User__c, End_Date_Time__c, Repeatative__c,Record_Processed__c,
            Sunday__c, Monday__c, Tuesday__c,
            Wednesday__c, Thursday__c, Friday__c, Saturday__c
            FROM Leave_Tracker__c
            WHERE End_Date_Time__c != null
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Leave_Tracker__c> scope) {
        
        Set<Id> usersToReactivate = new Set<Id>();
        List<Leave_Tracker__c> leavesToUpdate = new List<Leave_Tracker__c>();
        
        for (Leave_Tracker__c lt : scope) {
            if (lt.End_Date_Time__c < System.now()) {
                usersToReactivate.add(lt.User__c);
                
                if (!lt.Repeatative__c) {
                    lt.Sunday__c = false;
                    lt.Monday__c = false;
                    lt.Tuesday__c = false;
                    lt.Wednesday__c = false;
                    lt.Thursday__c = false;
                    lt.Friday__c = false;
                    lt.Saturday__c = false;
                    lt.Record_Processed__c = false;
                    
                }
                
                leavesToUpdate.add(lt);
            }
        }
        
        if (!leavesToUpdate.isEmpty()) {
            update leavesToUpdate;
        }
        
        if (!usersToReactivate.isEmpty()) {
            List<Team_Members__c> teamMembers = [
                SELECT Id
                FROM Team_Members__c
                WHERE User__c IN :usersToReactivate
            ];
            
            for (Team_Members__c tm : teamMembers) {
                tm.User_Active__c = true;
            }
            
            if (!teamMembers.isEmpty()) {
                update teamMembers;
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {}
}
