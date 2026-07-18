/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @description   :-  Test class for DocumentUploadController
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        :-  Bhavesh Sharma <bhavesh.sharma@salesforce.com> 
* @author        :-  Udit Singhal <udit.singhal@salesforce.com> 
* @Company       :-  Salesforce
* @version       :-  1.0.0
* @created       :-  10/11/2024
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class DocumentUploadControllerTest {
    @IsTest
    public static void testUploadDocument() {
        Account accRecord = new Account(Name = 'Test Account');
        insert accRecord;
        
        Document_Checklist__c checkListRecord = new Document_Checklist__c();
        checkListRecord.Account__c = accRecord.Id;
        checkListRecord.Document_Name__c = 'Test document.pdf';
        checkListRecord.Category__c = 'Other Documents';
        checkListRecord.Content_Type__c = 'application/pdf';
        checkListRecord.Received__c = true;
        insert checkListRecord;
        
        checkListRecord = [SELECT Id,Document_Name__c,Remarks__c,Content_Type__c,Checklist_ID__c,Status__c
                           FROM Document_Checklist__c
                           LIMIT 1];
        
        Test.startTest();
        DocumentUploadController.uploadDocument('base64 test', accRecord.Id, checkListRecord);
        Test.stopTest();  
        List<Document_Checklist__c> updatedChecklist = [SELECT Id,Document_Name__c,Remarks__c,Content_Type__c,Checklist_ID__c,Status__c
                                                        FROM Document_Checklist__c
                                                       ];
        System.assert(updatedChecklist[0].Document_Name__c != Null,'Document name should not be null');
    }
    
    @IsTest
    public static void testGetCheckists() {
        Test.startTest();
        Account accRecord = new Account(Name = 'Test Account');
        insert accRecord;
        
        Document_Checklist__c checkListRecord = new Document_Checklist__c();
        checkListRecord.Account__c = accRecord.Id;
        checkListRecord.Document_Name__c = 'Test document.pdf';
        checkListRecord.Category__c = 'Other Documents';
        checkListRecord.Content_Type__c = 'application/pdf';
        checkListRecord.Received__c = true;
        insert checkListRecord;
        
        List<Document_Checklist__c> checkLists = DocumentUploadController.getCheckists(accRecord.Id);
        Test.stopTest();
        System.Assert(checkLists.size() > 0);
    }
}