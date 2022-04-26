@IsTest
public with sharing class SendInvoiceControllerTest {

    @TestSetup
    public static void testSetup() {
        Opportunity opportunity = TestDataFactory.createOpportunity();
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account);
        OpportunityContactRole opportunityContactRole = TestDataFactory.createOpportunityContactRole(contact.Id, opportunity.Id);
    }

    @IsTest
    public static void getOpportunityContactRoleTest() {
        Opportunity opportunity = [SELECT Name, StageName, CloseDate, Invoice_Number__c FROM Opportunity LIMIT 1];
        OpportunityContactRole oppContRole = [SELECT Id, OpportunityId FROM OpportunityContactRole WHERE OpportunityId = :opportunity.Id LIMIT 1];
        List<OpportunityContactRole> opportunityContactRole = SendInvoiceController.getOpportunityContactRole(opportunity.Id);
        System.assertEquals(opportunityContactRole[0].Id, oppContRole.Id);
    }

    @IsTest
    public static void getEmailBodyTest() {
        Opportunity opportunity = [SELECT Name, StageName, Owner.Name, CloseDate, Invoice_Number__c FROM Opportunity LIMIT 1];
        OpportunityContactRole oppContRole = [
            SELECT Id, Contact.Name, Contact.Email, IsPrimary, Opportunity.CloseDate, Opportunity.Owner.Name, Opportunity.Invoice_Number__c
            FROM OpportunityContactRole
            WHERE OpportunityId = :opportunity.Id
            AND IsPrimary = TRUE
            LIMIT 1
        ];
        String emailBody = SendInvoiceController.getEmailBody(opportunity.Id);
        System.assertEquals(emailBody.contains(oppContRole.Contact.Name), true);
        System.assertEquals(emailBody.contains(String.valueOf(oppContRole.Opportunity.CloseDate)), true);
        System.assertEquals(emailBody.contains(oppContRole.Opportunity.Owner.Name), true);
        System.assertEquals(emailBody.contains(oppContRole.Opportunity.Invoice_Number__c), true);
    }

    @IsTest
    public static void getDocumentIdTest() {
        Opportunity opportunity = [SELECT Name, StageName, CloseDate, Invoice_Number__c FROM Opportunity LIMIT 1];
        PageReference testPage = Page.OpportunityPDF;
        String emailBodyText = 'Text body';
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opportunity.Id));
        Blob fileContent = Blob.valueOf('Test Data');
        ContentVersionController.createContentVersion();
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE IsLatest = TRUE LIMIT 1];
        Test.startTest();
        String getDocumentId = SendInvoiceController.getDocumentId(opportunity.Id);
        Test.stopTest();
        System.assertEquals(contentVersion.ContentDocumentId, getDocumentId);
    }

    @IsTest
    public static void sendEmailTest() {
        Opportunity opportunity = [SELECT Name, StageName, CloseDate, Invoice_Number__c FROM Opportunity LIMIT 1];
        OpportunityContactRole opportunityContactRole = [
            SELECT Id, ContactId, OpportunityId
            FROM OpportunityContactRole
            WHERE IsPrimary = TRUE
            LIMIT 1
        ];
        PageReference testPage = Page.OpportunityPDF;
        String emailBodyText = 'Text body';
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opportunity.Id));
        Blob fileContent = Blob.valueOf('Test Data');
        ContentVersionController.createContentVersion();
        ContentDocument contentDocument = [
            SELECT Id, Title
            FROM ContentDocument
            WHERE Title = :opportunity.Invoice_Number__c
            LIMIT 1
        ];
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');
        SendInvoiceController.sendEmail(opportunity.Invoice_Number__c, emailBodyText, opportunityContactRole.ContactId, contentDocument.Id);
        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
    }
}