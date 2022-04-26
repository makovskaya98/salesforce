@IsTest
public with sharing class SummaryDataOnCustomersControllerTest {

    @TestSetup
    public static void testSetup() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(Name = 'Acc ' + i));
        }
        insert accounts;
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            opportunities.add(new Opportunity(
                AccountId = accounts[i].Id,
                Name = 'Opportunity ' + i,
                CloseDate = Date.newInstance(2022, 05, 05),
                Amount = 2000,
                StageName = 'Closed Won'
            ));
        }
        insert opportunities;
        List<Product2> product2s = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            product2s.add(new Product2(Name = 'Product ' + i));
        }
        insert product2s;
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        Id stdPriceBookId = Test.getStandardPricebookId();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 product : product2s) {
            pricebookEntries.add(new PricebookEntry(Product2Id = product.Id, Pricebook2Id = stdPriceBookId, IsActive = true, UnitPrice = 2000));
        }
        insert pricebookEntries;
        opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opportunities[0].Id, Product2Id = product2s[0].Id, PricebookEntryId = pricebookEntries[0].Id, Quantity = 2, TotalPrice = 4000));
        opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opportunities[0].Id, Product2Id = product2s[1].Id, PricebookEntryId = pricebookEntries[1].Id, Quantity = 4, TotalPrice = 8000));
        opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opportunities[0].Id, Product2Id = product2s[2].Id, PricebookEntryId = pricebookEntries[2].Id, Quantity = 2, TotalPrice = 4000));
        opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opportunities[1].Id, Product2Id = product2s[3].Id, PricebookEntryId = pricebookEntries[3].Id, Quantity = 2, TotalPrice = 4000));
        opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opportunities[1].Id, Product2Id = product2s[4].Id, PricebookEntryId = pricebookEntries[4].Id, Quantity = 3, TotalPrice = 6000));
        insert opportunityLineItems;
    }

    @IsTest
    public static void getSoldProducts() {
        Opportunity opportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Opportunity 0'];
        SummaryDataOnCustomersController.getSoldProducts(opportunity.Id);
    }

    @IsTest
    public static void getSummaryDataOnCustomersTestCase1() {
        List<Opportunity> opportunities = [
            SELECT Id, AccountId, Account.Name, Name, CreatedDate, CloseDate, Amount, Account.Total_Amount__c
            FROM Opportunity
            WHERE IsClosed = TRUE
        ];
        Integer recordsSize = SummaryDataOnCustomersController.getSummaryDataOnCustomers(null).size();
        System.assertEquals(opportunities.size(), recordsSize);
    }

    @IsTest
    public static void getSummaryDataOnCustomersTestCase2() {
        Account account = [SELECT Id, Name FROM Account WHERE Account.Name = 'Acc 0' LIMIT 1];
        Integer recordsSize = SummaryDataOnCustomersController.getSummaryDataOnCustomers(account.Id).size();
        System.assertEquals(recordsSize, 1);
    }
}