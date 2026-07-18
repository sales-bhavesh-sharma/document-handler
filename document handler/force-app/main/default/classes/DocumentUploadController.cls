/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @description   :-  Controller for DocumentUpload component
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        :-  Bhavesh Sharma <bhavesh.sharma@salesforce.com> 
* @author        :-  Udit Singhal <udit.singhal@salesforce.com> 
* @Company       :-  Salesforce
* @version       :-  1.0.0
* @created       :-  10/11/2024
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class DocumentUploadController {

    /**
    * @description method to connect uploaded document to document checklist via contentdocumentlink 
    * In case we need to send the document via initegration we can use this same method to call the api and store document
    * @param  base64 base64 file content
    * @param recordId parent record id
    * @param documentChecklistRecord document checklist record
    */
    @AuraEnabled
    public static void uploadDocument(String base64, Id recordId, Document_Checklist__c documentChecklistRecord) {
        if(documentChecklistRecord != null){
            update documentChecklistRecord;
        }

        ContentVersion conVer = new ContentVersion();
        conVer.PathOnClient = documentChecklistRecord.Document_Name__c + DocumentViewerController.getExtension(documentChecklistRecord.Content_Type__c);
        conVer.Title = documentChecklistRecord.Document_Name__c;
        conVer.VersionData = EncodingUtil.base64Decode(base64);
        insert as system conVer;
        List<ContentVersion> version= [Select Id,ContentDocumentId From ContentVersion Where Id = :conVer.Id ];
        
        ContentDocumentLink link = new ContentDocumentLink(ContentDocumentId = version[0].ContentDocumentId,
                                                          LinkedEntityId = documentChecklistRecord.Id);
        Insert link;
    }
    
    /**
    * @description method to get document checklist records which document not received yet
    * @param  recordId parent recordId
    * @return List<Document_Checklist__c> document checklist records
    */
    @AuraEnabled(Cacheable = true)
    public static List<Document_Checklist__c> getCheckists(Id recordId) {
        return [Select Id,Remarks__c , Document_Name__c , Content_Type__c From Document_Checklist__c Where Received__c = false];
    }

}