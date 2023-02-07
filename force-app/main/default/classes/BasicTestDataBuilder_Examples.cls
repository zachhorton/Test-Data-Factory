@isTest
private class BasicTestDataBuilder_Examples {
    @isTest static void ContactAndAccount() {
        
        // Creates two accounts in a parent/child relationship
        // Also creates a contact under the child Account

        String acctName = 'Test Account';
        String parentAcctName = 'Test Parent Account';
        String firstName = 'John';
        String lastName = 'Doe';
        Account parentAccount = BasicTestDataBuilder.makeAccount(false);
        parentAccount.Name = parentAcctName;
        insert parentAccount;
        Account childAccount = BasicTestDataBuilder.makeAccount(true);
        childAccount.ParentId = parentAccount.Id;
        update childAccount;

        Contact cont = BasicTestDataBuilder.makeContact(true, new Map<String, Object> {'FirstName' => firstName,'LastName' => LastName,'AccountId' => childAccount.Id});
        // insert cont; // No need to insert, the builder will do it for us.

        Account acct = [SELECT Id, Name, Parent.Name, (SELECT Id, FirstName, LastName, Phone, Required_Field__c FROM Contacts) FROM Account WHERE Name = :acctName];
        System.assertEquals(acctName, acct.Name);
        System.assertEquals(parentAcctName, acct.Parent.Name);

        Contact childContact = acct.Contacts[0];
        System.assertEquals(firstName, childContact.FirstName);
        System.assertEquals(lastName, childContact.LastName);
        System.assertEquals('(987) 654-3210', childContact.Phone); // Set in default values
        System.assertEquals('required field value', childContact.Required_Field__c); // Set in default values
    }

    @isTest static void ListOfAccounts() {
        // Create a list of 5 Account sObjects with different names and a same description
        List<String> acctNames = new List<String>{'Google','Amazon','Facebook','Apple','Microsoft'};
        String description = 'acct description';

        List<Account> accList = BasicTestDataBuilder.makeAccountList(false, 5);
        for (Integer i=0; i<accList.size(); i++) {
            Account acct = accList[i];
            acct.Name = acctNames[i];
            acct.Description = description;
        }
        insert accList;

        List<Account> acctResult = [SELECT Id, Name, Description, Required_Field__c FROM Account];
        System.assertEquals(5, acctResult.size());

        Set<String> acctNamesSet = new Set<String>();
        acctNamesSet.addAll(acctNames);
        for (Account acct : acctResult) {
            System.assertEquals(description, acct.Description);
            System.assertEquals(true, acctNamesSet.contains(acct.Name));
            System.assertNotEquals(null, acct.Required_Field__c, 'Required field should be automatically populated');
        }
    }
    
    @isTest static void ListOfUsers() {
        // Uses merge fields to create unique list of users
        // The following code creates 10 users with different usernames and nicknames

        Id profileId = UserInfo.getProfileId();
        List<User> uList = BasicTestDataBuilder.makeUserList(true, 10);
        // insert uList; // Done automatically in builder

        List<User> users = [SELECT Id, ProfileId, Username, CommunityNickname FROM User WHERE Id IN :uList];
        System.assertEquals(10, users.size());
        for (User usr : users) {
            System.assertEquals(profileId, usr.ProfileId);
            System.assertEquals(true, usr.Username.contains(usr.CommunityNickname.toLowerCase()), 'Nickname unique value should be identity of username email');
        }
    }
}