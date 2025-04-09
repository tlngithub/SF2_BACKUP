@isTest
private class UserUtilsTest {
    @testSetup
    static void setup() {
        Group testGroup = new Group(Name = 'TestPublicGroup', Type = 'Regular');
        insert testGroup;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testUserUtils@testorg.com'
        );
        insert testUser;

        GroupMember gm = new GroupMember(
            GroupId = testGroup.Id,
            UserOrGroupId = testUser.Id
        );
        insert gm;
    }

    @isTest
    static void testUserIsInPublicGroupByName() {
        User testUser = [
            SELECT Id
            FROM User
            WHERE UserName = 'testUserUtils@testorg.com'
            LIMIT 1
        ];
        Group testGroup = [
            SELECT Id
            FROM Group
            WHERE Name = 'TestPublicGroup'
            LIMIT 1
        ];

        Test.startTest();
        Boolean isInGroup = UserUtils.userIsInPublicGroupByName(testUser.Id, 'TestPublicGroup');
        Test.stopTest();

        System.assertEquals(true, isInGroup, 'The user should be in the public group.');
    }
}