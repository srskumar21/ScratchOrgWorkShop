@isTest
public class ArchiveSchedulerTest {
    
    @isTest static void archiveRecordsDelete(){
        
        Test.startTest();
        ArchieveScheduler  archieveShcdlr =new ArchieveScheduler();
        String sch = '0 0 1 1 * ?';
        system.schedule('Test Territory Check', sch, archieveShcdlr);
 
        Test.stopTest();
    }

}