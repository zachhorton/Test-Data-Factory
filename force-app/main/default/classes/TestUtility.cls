@isTest
public class TestUtility {

	public static SObject createSObject(SObject sObj) {
		// Check what type of object we are creating and add any defaults that are needed.
		Schema.SObjectType token = sObj.getSObjectType();
		Schema.DescribeSObjectResult dr = token.getDescribe();
		// Construct the default values class. Salesforce doesn't allow '__' in class names
		String defaultClassName = 'TestUtility.' + dr.getName().replace('__c', '') + 'Defaults';
		// If there is a class the exists for the default values, then use them
		if (Type.forName(defaultClassName) != null) {
			sObj = createSObject(sObj, defaultClassName);
		}
		return sObj;
	}

	public static SObject createSObject(SObject sObj, String defaultClassName) {
		// Create an instance of the defaults class so we can get the Map of field defaults
		Type t = Type.forName(defaultClassName);
		if (t == null) {
			//RSH, I added the class name so you can see where you made the mistake easier
			Throw new TestFactoryException('Invalid defaults class.[' + defaultClassName + ']');
		}
		FieldDefaults defaults = (FieldDefaults)t.newInstance();
		addFieldDefaults(sObj, defaults.getFieldDefaults());
		return sObj;
	}

	public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
		return createSObjectList(sObj, numberOfObjects, null);
	}

	public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
		SObject[] sObjs = new SObject[]{};
		SObject newObj;

		// Get one copy of the object
		if (defaultClassName == null) {
			newObj = createSObject(sObj);
		} else {
			newObj = createSObject(sObj, defaultClassName);
		}

		String sobjType = String.valueOf(newObj.getSObjectType());

		// Get the name field for the object
		String nameField = nameFieldMap.get(sobjType);
		if (nameField == null) {
			nameField = 'Name';
		}

		// Clone the object the number of times requested. Increment the name field so each record is unique
		for (Integer i = 0; i < numberOfObjects; i++) {
			SObject clonedSObj = newObj.clone(false, true);
			//RSH, I change this to prefix with the nubmer for User types
			if (sobjType == 'User') {
				clonedSObj.put('CommunityNickname', String.valueOf(i) + '_' + (String)clonedSObj.get('CommunityNickname'));
				clonedSObj.put(nameField, String.valueOf(i) + '_' + (String)clonedSObj.get(nameField));
			}

			sObjs.add(clonedSObj);
		}
		return sObjs;
	}

	private static void addFieldDefaults(SObject sObj, Map<String, Object> defaults) {
		// Loop through the map of fields and if they are null on the object, fill them.
		for (String field : defaults.keySet()) {
			if (sObj.get(field) == null) {
				sObj.put(field, defaults.get(field));
			}
		}
	}

	// When we create a list of SObjects, we need to have each record in the list unique.
	// Most objects use the name field, but a few don't.
	// Use this map to store the name of the field when Name isn't available.
	private static Map<String, String> nameFieldMap = new Map<String, String> {
		'Contact' => 'LastName',
		'Case' => 'Subject',
		'User' => 'Username',
		'ContentVersion' => 'Title',
		'EmailMessage' => 'Subject'
	};

	public class TestFactoryException extends Exception {}

	// Use the FieldDefaults interface to set up values you want to default in for all objects.
	public interface FieldDefaults {
		Map<String, Object> getFieldDefaults();
	}
    
	public class AccountDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults() {
			return new Map<String, Object> {
				'Name' => 'Test Account',
                'BillingCountry' => 'USA',
                'BillingPostalCode' => '12345',
				'Phone' => '9999999999',
				'Required_Field__c' => 'required field value'
			};
		}
	}

	public class OpportunityDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults() {
			return new Map<String, Object> {
				'Name' => 'Test Opportunity',
				'StageName' => 'Closed Won',
				'CloseDate' => System.today()
			};
		}
	}

	public class ContactDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults() {
			return new Map<String, Object> {
				'FirstName' => 'First',
				'LastName' => 'Last',
				'Phone' => '(987) 654-3210',
				'Required_Field__c' => 'required field value'
			};
		}
	}

	public class UserDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults() {
			String orgId = userInfo.getOrganizationId();
		    String dateString = String.valueof(Date.today()).replace(' ','').replace(':','').replace('-','');
		    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		    String uniqueName = orgId + dateString + randomInt;
	        return new Map<String, Object> {
				'FirstName' => 'Joe',
				'LastName' => 'Tester',
				'Username' => uniqueName + '@test' + orgId + '.org',
				'Email' => uniqueName + '@test' + orgId + '.org',
				'Alias' => 'joet',
				'IsActive' => true,
				'CommunityNickname' => uniqueName,
				'TimeZoneSidKey' => 'America/New_York',
				'LocaleSidKey' => 'en_US',
				'EmailEncodingKey' => 'ISO-8859-1',
				'LanguageLocaleKey' => 'en_US',
				'ProfileId' => UserInfo.getProfileId()
		   };
		}
    }

    public class Product2Defaults implements FieldDefaults {
    	public Map<String, Object> getFieldDefaults() {
    		return new Map<String, Object> {
    			'Name' => 'All Tests',
    			'CanUseRevenueSchedule' => true
    		};
    	}
    }
}