public with sharing class TestDataFactory {

    public static Opportunity createOpportunity() {
        Opportunity opportunity = new Opportunity(Name = 'Grand Hotels SLA', StageName = 'Proposal/Price Quote', CloseDate = Date.newInstance(2022, 05, 05));
        insert opportunity;
        return opportunity;
    }

    public static List<Product2> createProduct2s() {
        List<Product2> product2s = new List<Product2>();
        for (Integer i = 1; i <= 3; i++) {
            product2s.add(new Product2(Name = 'Product ' + i));
        }
        insert product2s;
        return product2s;
    }

    public static List<PricebookEntry> creatPricebookEntries(List<Product2> product2s, Id stdPriceBookId) {
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 product2 : product2s) {
            pricebookEntries.add(new PricebookEntry(Pricebook2Id = stdPriceBookId, Product2Id = product2.Id, UnitPrice = 2000, IsActive = true));
        }
        insert pricebookEntries;
        return pricebookEntries;
    }

    public static Account createAccount() {
        Account account = new Account(Name = 'Burlington Textiles Corp of America');
        insert account;
        return account;
    }

    public static Contact createContact(Account account) {
        Contact contact = new Contact(FirstName = 'Anna', LastName = 'Lorens', AccountId = account.Id, Email = 'test@gmail.com', Phone = '336-222-7000');
        insert contact;
        return contact;
    }

    public static OpportunityContactRole createOpportunityContactRole(Opportunity opportunity, Contact contact) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(OpportunityId = opportunity.Id, IsPrimary = true, ContactId = contact.Id);
        insert opportunityContactRole;
        return opportunityContactRole;
    }

    public static List<OpportunityLineItem> createOpportunityLineItems(List<PricebookEntry> pricebookEntries, Opportunity opportunity) {
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opportunity.Id, PricebookEntryId = pricebookEntry.Id, Product2Id = pricebookEntry.Product2Id, Quantity = 2, TotalPrice = 4000));
        }
        insert opportunityLineItems;
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

    public static OpportunityContactRole createOpportunityContactRole(String contactId, String opportunityId) {
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(ContactId = contactId, OpportunityId = opportunityId, IsPrimary = true);
        insert opportunityContactRole;
        return opportunityContactRole;
    }
}