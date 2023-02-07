@isTest
public class BasicTestDataBuilder {
    ///// Account Builder /////
    public static Account makeAccount(Boolean doInsert) {
        return makeAccount(doInsert, new Map<String, Object>());
    }
    public static Account makeAccount(Boolean doInsert,  Map<String, Object> providedFields) {
        Account acct = new Account(
            Name = 'Test Account',
            Required_Field__c = 'required field value'
        );
        
        // Set provided field values
        acct = (Account) setProvidedFields(acct, providedFields);

        if (doInsert) insert acct;
        return acct;
    }
    public static List<Account> makeAccountList(Boolean doInsert, Integer count) {
        return makeAccountList(doInsert, count, new Map<String, Object>());
    }
    public static List<Account> makeAccountList(Boolean doInsert, Integer count, Map<String, Object> providedFields) {
        List<Account> accounts = new List<Account>();
        Account acctProto = makeAccount(false, providedFields);
        for (Integer i=0; i<count; i++) {
            Account acct = acctProto.clone();
            acct.Name = acct.Name + i;
            accounts.add(acct);
        }

        if (doInsert) insert accounts;
        return accounts;
    }
    
    
    ///// Contact Builder /////
    public static Contact makeContact(Boolean doInsert) {
        return makeContact(doInsert, new Map<String, Object>());
    }
    public static Contact makeContact(Boolean doInsert, Map<String, Object> providedFields) {
        Contact cont = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Phone = '(987) 654-3210',
            Required_Field__c = 'required field value'
        );
        
        // Set provided field values
        cont = (Contact) setProvidedFields(cont, providedFields);

        if (doInsert) insert cont;
        return cont;
    }
    public static List<Contact> makeContactList(Boolean doInsert, Integer count) {
        return makeContactList(doInsert, count, new Map<String, Object>());
    }
    public static List<Contact> makeContactList(Boolean doInsert, Integer count, Map<String, Object> providedFields) {
        List<Contact> contacts = new List<Contact>();
        Contact contProto = makeContact(false, providedFields);
        for (Integer i=0; i<count; i++) {
            Contact cont = contProto.clone();
            cont.LastName = cont.LastName + i;
            contacts.add(cont);
        }
        if (doInsert) insert contacts;
        return contacts;
    }
    
    ///// User Builder /////
    public static User makeUser(Boolean doInsert) {
        return makeUser(doInsert, new Map<String, Object>());
    }
    public static User makeUser(Boolean doInsert, Map<String, Object> providedFields) {
        User testUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            ProfileId = UserInfo.getProfileId(),
            Username = 'testuser@testdomain.com.test',
            Email = 'testuser@testdomain.com.test',
            CommunityNickname = 'testuser',
            IsActive = true,
            Alias = 'johnd',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
    
        // Set provided field values
        testUser = (User) setProvidedFields(testUser, providedFields);

        if (doInsert) insert testUser;
        return testUser;
    }
    public static List<User> makeUserList(Boolean doInsert, Integer count) {
        return makeUserList(doInsert, count, new Map<String, Object>());
    }
    public static List<User> makeUserList(Boolean doInsert, Integer count, Map<String, Object> providedFields) {
        List<User> users = new List<User>();
        User userProto = makeUser(false, providedFields);
        for (Integer i=0; i<count; i++) {
            User testUser = userProto.clone();
            testUser.LastName = testUser.LastName + i;
            testUser.Username = i+'testuser@testdomain.com.test';
            testUser.Email = i+'testuser@testdomain.com.test';
            testUser.CommunityNickname = i+'testuser';
            users.add(testUser);
        }
        if (doInsert) insert users;
        return users;
    }

    private static SObject setProvidedFields(SObject sObj, Map<String, Object> providedFields) {
        for (String field : providedFields.keySet()) {
            Object value = providedFields.get(field);
            sObj.put(field, value);
        }
        return sObj;
    }
    
}