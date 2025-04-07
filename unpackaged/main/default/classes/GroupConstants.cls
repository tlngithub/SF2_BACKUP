/**
 * @description Is sued to store constants variables for groups.
 * @author Eugene
 * @date 29.01.2025
**/
public class GroupConstants {

    public static final String QUEUE_ELIGIBILITY = 'Eligibility';

    public static final Map<String, String> TEAM_TO_QUEUE_MAPPING = new Map<String, String> {
            TaskConstants.TEAM_RCM => QUEUE_ELIGIBILITY
    };

    public static final Map<String, Group> QUEUES_BY_NAMES {
        get {
            if(QUEUES_BY_NAMES == NULL) {
                QUEUES_BY_NAMES = new Map<String, Group>();
                for(Group queue : [SELECT DeveloperName FROM Group WHERE Type = 'Queue']) {
                    QUEUES_BY_NAMES.put(queue.DeveloperName, queue);
                }
            }
            return QUEUES_BY_NAMES;
        }
        set {
            QUEUES_BY_NAMES = value;
        }
    }
}