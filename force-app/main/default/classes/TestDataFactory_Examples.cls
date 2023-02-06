/*
    Simple examples shown as tests, uses examples from https://github.com/benahm/TestDataFactory/blob/master/docs/EXAMPLES.md
*/

@isTest
private class TestDataFactory_Examples {
    @isTest static void ContactAndAccount() {
        
        // Creates two accounts in a parent/child relationship
        // Also creates a contact under the child Account

        String acctName = 'Test Account Name';
        String parentAcctName = 'Test Parent Account Name';
        String firstName = 'John';
        String lastName = 'Doe';
        Contact con = (Contact) TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'FirstName' => firstName,
            'LastName' => lastName,
            'Account.Description' => 'Description of the related account',
            'Account.Name' => acctName,
            'Account.Parent.Name' => parentAcctName
        });

        Account acct = [SELECT Id, Name, Parent.Name, (SELECT Id, FirstName, LastName FROM Contacts) FROM Account WHERE Name = :acctName];
        System.assertEquals(acctName, acct.Name);
        System.assertEquals(parentAcctName, acct.Parent.Name);

        Contact childContact = acct.Contacts[0];
        System.assertEquals(firstName, childContact.FirstName);
        System.assertEquals(lastName, childContact.LastName);
    }

    @isTest static void ListOfAccounts() {
        // Create a list of 5 Account sObjects with different names and a same description
        List<String> acctNames = new List<String>{'Google','Amazon','Facebook','Apple','Microsoft'};
        String description = 'acct description';

        List<Account> accList = TestDataFactory.createSObjectList('Account', new Map<String,Object>{
            'Name' => acctNames,
            'Description' => description
        },5);

        List<Account> acctResult = [SELECT Id, Name, Description FROM Account];
        System.assertEquals(5, acctResult.size());

        Set<String> acctNamesSet = new Set<String>();
        acctNamesSet.addAll(acctNames);
        for (Account acct : acctResult) {
            System.assertEquals(description, acct.Description);
            System.assertEquals(true, acctNamesSet.contains(acct.Name));
        }
    }

    @isTest static void ListOfUsers() {
        // Uses merge fields to create unique list of users
        // The following code creates 10 users with different usernames and nicknames

        Id profileId = UserInfo.getProfileId();
        List<User> uList = TestDataFactory.createSObjectList('User', new Map<String,Object>{
            'ProfileId' => profileId,
            'Username' => 'test{!index}@mytestdomain.developer',
            'CommunityNickname' => 'test{!index}'
        },10);

        List<User> users = [SELECT Id, ProfileId, Username, CommunityNickname FROM User WHERE Id IN :uList];
        System.assertEquals(10, users.size());
        for (User usr : users) {
            System.assertEquals(profileId, usr.ProfileId);
            System.assertEquals(true, usr.Username.contains(usr.CommunityNickname), 'Nickname test{!index} should be identity of username email');
        }
    }
}