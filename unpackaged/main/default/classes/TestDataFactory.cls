/**
 * Test Data Factory
 */
@isTest
public class TestDataFactory {
    public static Lead createLead() {
        return new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Status = 'New',
            Company = 'TLN'
        );
    }
    
    public static Case createCase() {
        return new Case(
            Status = 'New',
            Origin = 'Email'
        );
    }
}