public with sharing class OpportunityController {

    public Opportunity opportunity;

    public OpportunityController() {
        this.opportunity = getOpportunity();
    }

    public static Opportunity getOpportunity() {
        return [
            SELECT Id, Name, Invoice_Number__c, Owner.Name
            FROM Opportunity
            WHERE Id = :ApexPages.currentPage().getParameters().get('id')
            LIMIT 1
        ];
    }
}