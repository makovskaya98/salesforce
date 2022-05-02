global with sharing class EmailService implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String textMessage = 'Please answer Approved or Rejected.';
        String invoiceNumber = email.subject.replace('Re: ', '');
        String emailBodyText = email.plainTextBody;
        List<Schema.PicklistEntry> fieldResult = Opportunity.StageName.getDescribe().getPicklistValues();
        String pathEmailBodyText = emailBodyText.substring(emailBodyText.indexOf(textMessage) + textMessage.length());
        Map<Integer, String> stageNamePickList = new Map<Integer, String>();
        Opportunity opportunity = [
            SELECT Id, Invoice_Number__c, StageName
            FROM Opportunity
            WHERE Invoice_Number__c = :invoiceNumber
            LIMIT 1
        ];
        for (Integer i = 0; i < fieldResult.size(); i++) {
            stageNamePickList.put(i, fieldResult[i].label);
        }
        if (opportunity.StageName == stageNamePickList.get(6) && pathEmailBodyText.containsIgnoreCase('approved')) {
            opportunity.StageName = 'Negotiation/Review';
            update opportunity;
        } else if (opportunity.StageName == stageNamePickList.get(6) && pathEmailBodyText.containsIgnoreCase('rejected')) {
            opportunity.StageName = 'Closed Lost';
            update opportunity;
        }
        return result;
    }
}