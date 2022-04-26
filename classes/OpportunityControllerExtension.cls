public with sharing class OpportunityControllerExtension {

    private final Opportunity opportunity;
    public Contact contact { get; set; }
    public List<OpportunityLineItem> opportunityLineItems { get; set; }
    public Decimal totalPrice { get; set; }

    public OpportunityControllerExtension(ApexPages.StandardController stdController) {
        this.opportunity = (Opportunity) stdController.getRecord();
        this.contact = getContact();
        this.opportunityLineItems = getOpportunityLineItem();
        this.totalPrice = getTotalPrice();
    }

    public static Contact getContact() {
        OpportunityContactRole opportunityContact = [
            SELECT Id, OpportunityId, IsPrimary, Role, ContactId
            FROM OpportunityContactRole
            WHERE OpportunityId = :ApexPages.currentPage().getParameters().get('id')
            AND IsPrimary = TRUE
            LIMIT 1
        ];
        return [
            SELECT Name, Account.Name, Email, Phone
            FROM Contact
            WHERE Id = :opportunityContact.ContactId
            LIMIT 1
        ];
    }

    public static List<OpportunityLineItem> getOpportunityLineItem() {
        List<OpportunityLineItem> opportunityLineItems = [
            SELECT Id, OpportunityId, Product2.Name, Quantity, UnitPrice, TotalPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :ApexPages.currentPage().getParameters().get('id')
        ];
        List<OpportunityLineItem> emptyOpportunityLineItems = new List<OpportunityLineItem>();
        Integer count = 11;
        if (opportunityLineItems.size() < 11) {
            for (Integer i = opportunityLineItems.size(); i <= count; i++) {
                emptyOpportunityLineItems.add(new OpportunityLineItem(TotalPrice = 0.00));
            }
        }
        opportunityLineItems.addAll(emptyOpportunityLineItems);
        return opportunityLineItems;
    }

    public static Decimal getTotalPrice() {
        List<OpportunityLineItem> opportunityLineItems = [
            SELECT Id, OpportunityId, Product2.Name, Quantity, UnitPrice, TotalPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :ApexPages.currentPage().getParameters().get('id')
        ];
        Double sum = 0;
        for (OpportunityLineItem opportunityLineItem : opportunityLineItems) {
            sum += opportunityLineItem.TotalPrice;
        }
        return sum;
    }
}