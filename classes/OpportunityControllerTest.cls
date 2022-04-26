@IsTest
public with sharing class OpportunityControllerTest {

    @TestSetup
    public static void testSetup() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i <= 20; i++) {
            opportunities.add(new Opportunity(Name = 'Test ' + i, StageName = 'Proposal/Price Quote', CloseDate = Date.newInstance(2022, 05, 05)));
        }
        insert opportunities;
    }

    @IsTest
    public static void getOpportunityTest() {
        Opportunity opportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test 10' LIMIT 1];
        PageReference testPage = Page.OpportunityPDF;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opportunity.Id));
        Opportunity opp = OpportunityController.getOpportunity();
        System.assertEquals(opp.Id, opportunity.Id);
        OpportunityController oppController = new OpportunityController();
    }
}