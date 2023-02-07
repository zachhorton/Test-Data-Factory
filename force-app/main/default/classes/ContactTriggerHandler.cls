public without sharing class ContactTriggerHandler {
    
    public static void MakeFollowUpTask(Contact[] records) {
        // Check if user is admin...skip
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        if (adminProfile.Id == UserInfo.getProfileId()) return;

        List<Task> tasks = new List<Task>();
        Date threeDaysOut = System.today().addDays(3);
        for (Contact cont : records) {
            Task tsk = new Task(
                ActivityDate = threeDaysOut,
                OwnerId = cont.OwnerId,
                Status = 'Not Started',
                Subject = 'New Contact Follow Up',
                WhoId = cont.Id
            );
            tasks.add(tsk);
        }
        insert tasks;
    }
}