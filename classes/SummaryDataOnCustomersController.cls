public with sharing class SummaryDataOnCustomersController {

    @AuraEnabled
    public static List<SummaryDataOnCustomersWrapper> getSummaryDataOnCustomers(String recordId) {
        Map<Id, SummaryDataOnCustomersWrapper> idAccountToListOpportunities = new Map<Id, SummaryDataOnCustomersWrapper>();
        String getOpportunities = 'SELECT Id, AccountId, Account.Name, Name, CreatedDate, CloseDate, Amount, Account.Total_Amount__c FROM Opportunity WHERE IsClosed = TRUE';
        List<Opportunity> opportunities = new List<Opportunity>();

        if (recordId == null) {
            opportunities = Database.query(getOpportunities);
        } else {
            opportunities = Database.query(getOpportunities + ' AND AccountId =: recordId');
        }

        for (Opportunity opportunity : opportunities) {
            SummaryDataOnCustomersWrapper summaryDataOnCustomersWrapper = new SummaryDataOnCustomersWrapper();
            if (!idAccountToListOpportunities.containsKey(opportunity.AccountId)) {
                summaryDataOnCustomersWrapper.accountName = opportunity.Account.Name + ' — Total amount: ' + opportunity.Account.Total_Amount__c;
                summaryDataOnCustomersWrapper.opportunities = new List<Opportunity>{
                    opportunity
                };
                idAccountToListOpportunities.put(opportunity.AccountId, summaryDataOnCustomersWrapper);
            } else {
                idAccountToListOpportunities.get(opportunity.AccountId).opportunities.add(opportunity);
            }
        }
        return idAccountToListOpportunities.values();
    }

    @AuraEnabled
    public static List<OpportunityLineItem> getSoldProducts(String idOpportunity) {
        List<OpportunityLineItem> opportunityLineItems = [
            SELECT Id, Opportunity.IsClosed, OpportunityId, Product2.Name, Quantity, UnitPrice, Subtotal
            FROM OpportunityLineItem
            WHERE Opportunity.IsClosed = TRUE AND OpportunityId = :idOpportunity
        ];
        return opportunityLineItems;
    }

    class SummaryDataOnCustomersWrapper {
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public List<Opportunity> opportunities;
    }
}