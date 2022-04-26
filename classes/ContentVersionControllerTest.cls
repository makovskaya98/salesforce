@IsTest
public with sharing class ContentVersionControllerTest {

    @TestSetup
    public static void testSetup() {
        Opportunity opportunity = new Opportunity(Name = 'Grand Hotels SLA', StageName = 'Proposal/Price Quote', CloseDate = Date.newInstance(2022, 05, 05));
        insert opportunity;
    }

    @IsTest
    public static void getDocumentUrlTestTest() {
        Opportunity opportunity = [SELECT Name, StageName, CloseDate, Invoice_Number__c FROM Opportunity];
        PageReference testPage = Page.OpportunityPDF;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opportunity.Id));
        Test.startTest();
        ContentVersionController contentVersionController = new ContentVersionController();
        String url = contentVersionController.getDocumentUrl();
        Test.stopTest();
        System.assertEquals(url, '/apex/opportunitypdf?id=' + opportunity.Id);
    }

    @IsTest
    public static void createPdfFileTest() {
        Opportunity opportunity = [SELECT Id, Name, StageName, CloseDate, Invoice_Number__c FROM Opportunity];
        PageReference testPage = Page.OpportunityPDF;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opportunity.Id));
        Test.startTest();
        PageReference pageReference = ContentVersionController.createPDFFile();
        Test.stopTest();
        System.assertEquals(pageReference.getUrl(), new PageReference('/' + opportunity.Id).getUrl());
    }

    @IsTest
    public static void createContentVersionWithoutDocumentTest() {
        Opportunity opportunity = [SELECT Name, StageName, CloseDate, Invoice_Number__c FROM Opportunity];
        PageReference testPage = Page.OpportunityPDF;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opportunity.Id));
        Blob fileContent = Blob.valueOf('Test Data');
        Test.startTest();
        ContentVersionController.createContentVersion();
        Test.stopTest();
        ContentVersion contentVersion = [SELECT Id, IsLatest, ContentDocumentId FROM ContentVersion WHERE IsLatest = TRUE LIMIT 1];
        ContentDocument contentDocument = [
            SELECT Id, Title
            FROM ContentDocument
            WHERE Title = :opportunity.Invoice_Number__c
            LIMIT 1
        ];
        System.assertEquals(contentVersion.ContentDocumentId, contentDocument.Id);
    }

    @IsTest
    public static void createContentVersionWithDocumentTest() {
        Opportunity opportunity = [SELECT Name, StageName, CloseDate, Invoice_Number__c FROM Opportunity];
        PageReference testPage = Page.OpportunityPDF;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opportunity.Id));
        Blob fileContent = Blob.valueOf('Test Data');
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.Title = opportunity.Invoice_Number__c;
        contentVersion.PathOnClient = opportunity.Invoice_Number__c + '.pdf';
        contentVersion.VersionData = fileContent;
        insert contentVersion;
        Test.startTest();
        ContentVersionController.createContentVersion();
        Test.stopTest();
        ContentVersion contDocumentId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentVersion.Id
            LIMIT 1
        ];
        System.assert(contDocumentId != null);
    }
}