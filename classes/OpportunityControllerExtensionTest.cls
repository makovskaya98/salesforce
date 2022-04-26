@IsTest
public with sharing class OpportunityControllerExtensionTest {

    @TestSetup
    public static void testSetup() {
        Opportunity opportunity = TestDataFactory.createOpportunity();
        Id stdPriceBookId = Test.getStandardPricebookId();
        List<Product2> product2s = TestDataFactory.createProduct2s();
        List<PricebookEntry> pricebookEntries = TestDataFactory.creatPricebookEntries(product2s, stdPriceBookId);
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account);
        OpportunityContactRole opportunityContactRoles = TestDataFactory.createOpportunityContactRole(opportunity, contact);
        List<OpportunityLineItem> opportunityLineItems = TestDataFactory.createOpportunityLineItems(pricebookEntries, opportunity);
    }

    @IsTest
    public static void getTotalPriceTest() {
        Opportunity opportunity = [
            SELECT Id, Name
            FROM Opportunity
            WHERE Name = 'Grand Hotels SLA'
        ];
        PageReference testPage = Page.OpportunityPDF;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opportunity.Id));
        List<OpportunityLineItem> opportunityLineItems = [
            SELECT Id, OpportunityId, Product2.Name, Quantity, UnitPrice, TotalPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunity.Id
        ];
        Decimal totalPrice = 0;
        for (OpportunityLineItem opportunityLineItem : opportunityLineItems) {
            totalPrice += opportunityLineItem.TotalPrice;
        }
        Test.startTest();
        Decimal getTotalPrice = OpportunityControllerExtension.getTotalPrice();
        Test.stopTest();
        System.assertEquals(getTotalPrice, totalPrice);
    }

    @IsTest
    public static void getContactTest() {
        Opportunity opportunity = [
            SELECT Id, Name
            FROM Opportunity
            WHERE Name = 'Grand Hotels SLA'
        ];
        PageReference testPage = Page.OpportunityPDF;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opportunity.Id));
        OpportunityContactRole opportunityContact = [
            SELECT Id, OpportunityId, IsPrimary, Role, ContactId
            FROM OpportunityContactRole
            WHERE OpportunityId = :opportunity.Id
            AND IsPrimary = TRUE
            LIMIT 1
        ];
        Contact cont = [
            SELECT Name, Account.Name, Email, Phone
            FROM Contact
            WHERE Id = :opportunityContact.ContactId
            LIMIT 1
        ];
        Test.startTest();
        Contact contact = OpportunityControllerExtension.getContact();
        Test.stopTest();
        System.assertEquals(contact.Id, cont.Id);
    }

    @IsTest
    public static void getOpportunityLineItemTest() {
        Opportunity opportunity = [
            SELECT Id, Name
            FROM Opportunity
            WHERE Name = 'Grand Hotels SLA'
        ];
        PageReference testPage = Page.OpportunityPDF;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opportunity.Id));
        Test.startTest();
        List<OpportunityLineItem> opportunityLineItems = OpportunityControllerExtension.getOpportunityLineItem();
        Test.stopTest();
        System.assertEquals(opportunityLineItems.size(), 12);
        ApexPages.StandardController sc = new ApexPages.StandardController(opportunity);
        OpportunityControllerExtension ext = new OpportunityControllerExtension(sc);
    }
}