public with sharing class ContentVersionController {

    public String documentUrl { get; set; }

    public ContentVersionController() {
        this.documentUrl = getDocumentUrl();
    }

    public String getDocumentUrl() {
        PageReference pref = Page.OpportunityPDF;
        return pref.getUrl() + '?id=' + ApexPages.currentPage().getParameters().get('id');
    }

    public static void createContentVersion() {
        Opportunity opportunity = [
            SELECT Id, Invoice_Number__c
            FROM Opportunity
            WHERE Id = :ApexPages.currentPage().getParameters().get('id')
            LIMIT 1
        ];

        List<ContentDocument> contentDocument = [
            SELECT Id, Title
            FROM ContentDocument
            WHERE Title = :opportunity.Invoice_Number__c
            LIMIT 1
        ];

        PageReference pref = Page.OpportunityPDF;
        pref.getParameters().put('id', opportunity.Id);
        pref.setRedirect(true);
        Blob bdata;
        if (Test.isRunningTest()) {
            bdata = Blob.valueOf('Unit.Test');
        } else {
            bdata = pref.getContent();
        }
        ContentVersion contentVersion = new ContentVersion();

        if (contentDocument.size() != 0) {
            contentVersion.ContentLocation = 'S';
            contentVersion.Title = opportunity.Invoice_Number__c;
            contentVersion.PathOnClient = opportunity.Invoice_Number__c + '.pdf';
            contentVersion.VersionData = bdata;
            contentVersion.ContentDocumentId = contentDocument[0].Id;
            insert contentVersion;
        } else {
            contentVersion.ContentLocation = 'S';
            contentVersion.Title = opportunity.Invoice_Number__c;
            contentVersion.PathOnClient = opportunity.Invoice_Number__c + '.pdf';
            contentVersion.VersionData = bdata;
            insert contentVersion;

            ContentVersion contDocumentId = [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :contentVersion.Id
                LIMIT 1
            ];

            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = contDocumentId.ContentDocumentId;
            contentDocumentLink.LinkedEntityId = ApexPages.currentPage().getParameters().get('id');
            contentDocumentLink.ShareType = 'V';
            contentDocumentLink.Visibility = 'AllUsers';
            insert contentDocumentLink;
        }
    }

    public static PageReference createPDFFile() {
        PageReference pageRef = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
        pageRef.setRedirect(false);
        return pageRef;
    }

}