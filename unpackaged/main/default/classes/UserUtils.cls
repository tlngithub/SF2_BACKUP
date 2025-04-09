public with sharing class UserUtils {
    public static Boolean userIsInPublicGroupByName(Id userId, String publicGroupName) {
        return userIsInPublicGroupById(
            userId,
            getGroupIdByName(publicGroupName)
        );
    }

    public static Boolean userIsInPublicGroupById(Id userId, Id publicGroupId) {
        Set<Id> results = new Set<Id>();
        Map<Id, Id> grRoleMap = new Map<Id, Id>();

        for (Group gr : [SELECT id, relatedid, name FROM Group]) {
            if (gr.relatedId != null) {
                grRoleMap.put(gr.relatedId, gr.id);
            }
        }

        //Populating the Group with User with GroupId we are filtering only for Group of Type Regular,Role and RoleAndSubordinates
        for (GroupMember u : [
            SELECT groupId
            FROM GroupMember
            WHERE
                UserOrGroupId = :userId
                AND (Group.Type = 'Regular'
                OR Group.Type = 'Role'
                OR Group.Type = 'RoleAndSubordinates')
        ]) {
            results.add(u.groupId);
        }

        //Groups with Role
        for (User u : [SELECT UserRoleId FROM User WHERE id = :userId]) {
            if (grRoleMap.containsKey(u.UserRoleId)) {
                results.add(grRoleMap.get(u.UserRoleId));
            }
        }

        //Traversing the whole list of Groups to check any other nested Group
        Map<Id, Id> grMap = new Map<Id, Id>();
        for (GroupMember gr : [
            SELECT id, UserOrGroupId, Groupid
            FROM GroupMember
            WHERE
                Group.Type = 'Regular'
                OR Group.Type = 'Role'
                OR Group.Type = 'RoleAndSubordinates'
        ]) {
            grMap.put(gr.UserOrGroupId, gr.Groupid);
        }
        for (Id i : results) {
            if (grMap.containsKey(i)) {
                results.add(grMap.get(i));
            }
        }

        return results.contains(publicGroupId);
    }

    private static Id getGroupIdByName(String groupName) {
        Group groupRecord = [
            SELECT Id
            FROM Group
            WHERE DeveloperName = :groupName
            LIMIT 1
        ];

        return groupRecord.Id;
    }
}