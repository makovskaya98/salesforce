global with sharing class EmailService implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String textMessage = 'Please answer Approved or Rejected.';
        String invoiceNumber = email.subject.replace('Re: ', '');
        String emailBodyText = email.plainTextBody;
        String pathEmailBodyText = emailBodyText.substring(emailBodyText.indexOf(textMessage) + textMessage.length());
        Opportunity opportunity = [
            SELECT Id, Invoice_Number__c, StageName
            FROM Opportunity
            WHERE Invoice_Number__c = :invoiceNumber
            LIMIT 1
        ];

        if (opportunity.StageName == 'Proposal/Price Quote' && pathEmailBodyText.containsIgnoreCase('approved')) {
            opportunity.StageName = 'Negotiation/Review';
            update opportunity;
        } else if (opportunity.StageName == 'Proposal/Price Quote' && pathEmailBodyText.containsIgnoreCase('rejected')) {
            opportunity.StageName = 'Closed Lost';
            update opportunity;
        }
        return result;
    }
}