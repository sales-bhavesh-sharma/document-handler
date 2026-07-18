/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @description   :-  Controller for DocumentViewerController
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        :-  Bhavesh Sharma <bhavesh.sharma@salesforce.com> 
* @author        :-  Udit Singhal <udit.singhal@salesforce.com> 
* @Company       :-  Salesforce
* @version       :-  1.0.0
* @created       :-  10/11/2024
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class DocumentViewerControllerTest {
    @IsTest
    public static void testDoCallout() {
        Account accRecord = new Account(Name = 'Test Account');
        insert accRecord;
        
        Document_Checklist__c checkListRecord = new Document_Checklist__c();
        checkListRecord.Account__c = accRecord.Id;
        checkListRecord.Document_Name__c = 'Test document.pdf';
        checkListRecord.Category__c = 'Other Documents';
        checkListRecord.Content_Type__c = 'text/html';
        checkListRecord.Received__c = true;
        insert checkListRecord;
        
        ContentVersion file = new ContentVersion();
        file.Title = 'Test File';
        file.PathOnClient = 'TestFile.txt';
        file.VersionData = Blob.valueOf('Test file contents');
        insert file;
        
        ContentVersion conVersion = [Select ContentDocumentId from ContentVersion where id =: file.Id];
        ContentDocumentLink docLink = new ContentDocumentLink();
        docLink.LinkedEntityId = checkListRecord.Id;
        docLink.ContentDocumentId = conVersion.ContentDocumentId;
        docLink.ShareType = 'V';
        insert docLink;
        
        Test.startTest();
        DocumentViewerController.ResultWrapper pdf = DocumentViewerController.doCallout(checkListRecord.Id)    ;
        Test.stopTest();
        
        // asserting that doc Content which is returned in pdf variable is not null
        System.assertNotEquals(null, pdf);
    }
    
    @IsTest
    public static void testGetDocument() {
        Account accRecord = new Account(Name = 'Test Account');
        insert accRecord;
        
        Document_Checklist__c checkListRecord = new Document_Checklist__c();
        checkListRecord.Account__c = accRecord.Id;
        checkListRecord.Document_Name__c = 'Test document.pdf';
        checkListRecord.Category__c = 'Other Documents';
        checkListRecord.Content_Type__c = 'application/pdf';
        checkListRecord.Received__c = true;
        insert checkListRecord;
        
        ContentVersion file = new ContentVersion();
        file.Title = 'Test File';
        file.PathOnClient = 'TestFile.txt';
        file.VersionData = Blob.valueOf('Test file contents');
        insert file;
        
        ContentVersion conVersion = [Select ContentDocumentId from ContentVersion where id =: file.Id];
        ContentDocumentLink docLink = new ContentDocumentLink();
        docLink.LinkedEntityId = checkListRecord.Id;
        docLink.ContentDocumentId = conVersion.ContentDocumentId;
        docLink.ShareType = 'V';
        insert docLink;
        
        Test.startTest();
        DocumentViewerController.ResultWrapper pdf = DocumentViewerController.getDocument(checkListRecord.Id)    ;
        Test.stopTest();
        
        // asserting that doc Content which is returned in pdf variable is not null
        System.assertNotEquals(null, pdf);
    }
}