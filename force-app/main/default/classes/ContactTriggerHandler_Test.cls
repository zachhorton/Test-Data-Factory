@isTest
private class ContactTriggerHandler_Test {
    static Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    static Profile otherProfile = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND Id != :UserInfo.getProfileId() LIMIT 1];
    @isTest static void MakeFollowUpTask_Factory() {
        User nonAdminUser = (User) TestDataFactory.createSObject('User', 
            new Map<String, Object>{
                'ProfileId' => otherProfile.Id, 
                'Username' => 'test11@mytestdomain.developer',
                'CommunityNickname' => 'test11'
            }, false);

        // runs as admin
        Contact adminContact = (Contact) TestDataFactory.createSObject('Contact', new Map<String,Object>{'LastName' => 'adminContact'});
        // make non admin contact but don't insert
        Contact nonAdminContact = (Contact) TestDataFactory.createSObject('Contact', new Map<String,Object>{'LastName' => 'nonAdminContact'}, false);
        
        System.runAs(nonAdminUser) {
            insert nonAdminContact;
        }
        checkTasks(adminContact.Id, nonAdminContact.Id);
    }
    
    @isTest static void MakeFollowUpTask_Utility() {
        User nonAdminUser = (User) TestUtility.createSObject(new User(ProfileId = otherProfile.Id), 'TestUtility.UserDefaults');

        // runs as admin
        Contact adminContact = (Contact) TestUtility.createSObject(new Contact(LastName = 'adminContact'), 'TestUtility.ContactDefaults');
        insert adminContact;

        Contact nonAdminContact;
        System.runAs(nonAdminUser) {
            nonAdminContact = (Contact) TestUtility.createSObject(new Contact(LastName = 'nonAdminContact'), 'TestUtility.ContactDefaults');
            insert nonAdminContact;
        }
        checkTasks(adminContact.Id, nonAdminContact.Id);
    }
    
    @isTest static void MakeFollowUpTask_Basic() {
        User nonAdminUser = BasicTestDataBuilder.makeUser(false, new Map<String, Object>{'ProfileId' => otherProfile.Id});

        // runs as admin
        Contact adminContact = BasicTestDataBuilder.makeContact(true, new Map<String, Object>{'LastName' => 'adminContact'});

        Contact nonAdminContact;
        System.runAs(nonAdminUser) {
            nonAdminContact = BasicTestDataBuilder.makeContact(true, new Map<String, Object>{'LastName' => 'nonAdminContact'});
        }
        checkTasks(adminContact.Id, nonAdminContact.Id);
    }

    private static void checkTasks(Id adminContactId, Id nonAdminContactId) {
        List<Task> adminTasks = [SELECT Id FROM Task WHERE WhoId = :adminContactId];
        System.assertEquals(0, adminTasks.size());
        
        List<Task> nonAdminTasks = [SELECT Id FROM Task WHERE WhoId = :nonAdminContactId];
        System.assertEquals(1, nonAdminTasks.size());
    }
}