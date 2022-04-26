@IsTest
public with sharing class EmailServiceTest {

    @TestSetup
    public static void testSetup() {
        Opportunity opportunity = new Opportunity(
            Name = 'Grand Hotels SLA',
            StageName = 'Proposal/Price Quote',
            CloseDate = Date.newInstance(2022, 05, 05)
        );
        insert opportunity;
    }

    @IsTest
    public static void handleInboundEmailTestApproved() {
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Opportunity opportunity = [
            SELECT Name, StageName, CloseDate, Invoice_Number__c
            FROM Opportunity
            LIMIT 1
        ];
        email.subject = 'Re: ' + opportunity.Invoice_Number__c;
        email.plainTextBody = 'Text body2... Please answer Approved or Rejected. Text body3... Approved';
        email.fromAddress = 'email.test@gmail.com';

        EmailService emailService = new EmailService();
        Messaging.InboundEmailResult result = emailService.handleInboundEmail(email, env);
        Opportunity updateOpportunity = [
            SELECT Name, StageName, CloseDate, Invoice_Number__c
            FROM Opportunity
            LIMIT 1
        ];
        System.assertEquals(result.success, true);
        System.assertEquals(updateOpportunity.StageName, 'Negotiation/Review');
    }

    @IsTest
    public static void handleInboundEmailTestRejected() {
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Opportunity opportunity = [
            SELECT Name, StageName, CloseDate, Invoice_Number__c
            FROM Opportunity
            LIMIT 1
        ];
        email.subject = 'Re: ' + opportunity.Invoice_Number__c;
        email.plainTextBody = 'Text body2... Please answer Approved or Rejected. Text body3... Rejected';
        email.fromAddress = 'email.test@gmail.com';

        EmailService emailService = new EmailService();
        Messaging.InboundEmailResult result = emailService.handleInboundEmail(email, env);
        Opportunity updateOpportunity = [
            SELECT Name, StageName, CloseDate, Invoice_Number__c
            FROM Opportunity
            LIMIT 1
        ];
        System.assertEquals(result.success, true);
        System.assertEquals(updateOpportunity.StageName, 'Closed Lost');
    }
}