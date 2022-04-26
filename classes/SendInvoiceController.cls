public with sharing class SendInvoiceController {

    @AuraEnabled(Cacheable=true)
    public static List<OpportunityContactRole> getOpportunityContactRole(String recordId) {
        return [
            SELECT Id, Contact.Name, Contact.Email, IsPrimary, Opportunity.Invoice_Number__c
            FROM OpportunityContactRole
            WHERE OpportunityId = :recordId
            AND IsPrimary = TRUE
            LIMIT 1
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static String getEmailBody(String recordId) {
        OpportunityContactRole opportunityContactRole = [
            SELECT Id, Contact.Name, Contact.Email, IsPrimary, Opportunity.CloseDate, Opportunity.Owner.Name, Opportunity.Invoice_Number__c
            FROM OpportunityContactRole
            WHERE OpportunityId = :recordId
            AND IsPrimary = TRUE
            LIMIT 1
        ];
        EmailTemplate emailTemplates = [
            SELECT Id, Name, DeveloperName, Body
            FROM EmailTemplate
            WHERE DeveloperName = 'Invoice_Number_Template'
            LIMIT 1
        ];
        String emailBody = emailTemplates.Body;
        String newEmailBody = emailBody.replace('ContactName', opportunityContactRole.Contact.Name)
            .replace('CloseDate', String.valueOf(opportunityContactRole.Opportunity.CloseDate))
            .replace('UserName', opportunityContactRole.Opportunity.Owner.Name)
            .replace('InvoiceNumber', opportunityContactRole.Opportunity.Invoice_Number__c);
        return newEmailBody;
    }

    @AuraEnabled(Cacheable=true)
    public static String getDocumentId(String recordId) {
        ContentDocumentLink contentDocumentLink = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            LIMIT 1
        ];
        return contentDocumentLink.ContentDocumentId;
    }

    @AuraEnabled(Cacheable=true)
    public static void sendEmail(String invoiceNumber, String emailBodyText, String contactEmail, String documentId) {
        try {
            ContentVersion contentVersion = [
                SELECT Id, ContentDocumentId, IsLatest
                FROM ContentVersion
                WHERE IsLatest = TRUE
                AND ContentDocumentId = :documentId
                LIMIT 1
            ];
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{
                contactEmail
            };
            String[] ccAddresses = new String[]{
                contactEmail
            };
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            mail.setSenderDisplayName('Salesforce');
            mail.setSubject(invoiceNumber);
            mail.setPlainTextBody(emailBodyText);
            mail.setHtmlBody(emailBodyText);
            mail.setReplyTo('emailservice@f8dsu8fvq4ntiw7admi65b6op5ap8im9bx4obfh3m50xv9biq.5j-bvjxseat.ap27.apex.salesforce.com');
            mail.setEntityAttachments(new String[]{
                contentVersion.Id
            });
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
            });
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
}