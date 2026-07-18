/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @description   :-  Controller for DocumentViewerPage
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        :-  Bhavesh Sharma <bhavesh.sharma@salesforce.com> 
* @author        :-  Udit Singhal <udit.singhal@salesforce.com> 
* @Company       :-  Salesforce
* @version       :-  1.0.0
* @created       :-  10/11/2024
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global with sharing class DocumentViewerController {

    /**
    * @description This variable hold document checklist instance
    */
    static Document_Checklist__c docChecklist;
     
    /**
    * @description This method do callout to get content of the passed document checklist id
    * @param  recordId document checklist id Id
    * @return  result wrapper
    */
     @RemoteAction
     global static ResultWrapper getDocument(String recordId){
         ResultWrapper result = doCallout(recordId);
             try{
              docChecklist = getChecklist(recordId);
             result.contentDocumentId = getContentDocument(docChecklist, result);
         }
         catch(Exception ex){
             result.errorMessage = ex.getMessage();
         }
         return result;
     }
     
     /**
    * @description This method is used to get checklist
    * @param  recordId document checklist id 
    * @return  Document_Checklist__c
    */
     static Document_Checklist__c getChecklist(String recordId){
         if(docChecklist == null){
             docChecklist = [Select Id, Content_Type__c, Name, Document_Name__c
                                               From Document_Checklist__c 
                                               Where Id = :recordId
                                               WITH USER_MODE];
         }
         return docChecklist;
     }
     
     /**
    * @description This method do callout to get content of the passed document checklist id
    * @param  recordId document checklist id Id
    * @return  result wrapper
    */
     @RemoteAction
     global static ResultWrapper doCallout(String recordId){
         ResultWrapper result = new ResultWrapper();
         
         Document_Checklist__c docChecklist = getChecklist(recordId);
         // Making a callout 
         // 
         try{
             result = getDocumentData(recordId);
             result.contentType = docChecklist.Content_Type__c;
             if(result.contentType == 'text/html'){
                 result.content = EncodingUtil.base64Decode(result.base64).toString();
                 result.base64 = null;
             }
         }catch(Exception e){
             result.errorMessage = 'Failed to get document';
             System.debug(result.errorMessage);
         }
         
         result.showToolBar = '0';
         return result;
     }
     
     /**
    * @description This method is used to get the document data from content document. 
    * The same method will be used to call the api if document is comming from third party
    * @param  recordId document checklist id 
    * @return  ResultWrapper
    */
     public static  ResultWrapper getDocumentData(Id recordId){
          ResultWrapper result = new ResultWrapper();
         List<ContentDocumentLink> link = [Select Id,ContentDocumentId,ContentDocument.LatestPublishedVersion.versionData From ContentDocumentLink Where LinkedEntityId =:recordId ];
             if(link.size() > 0){
                 Blob fileABlob = link[0].ContentDocument.LatestPublishedVersion.versionData;
                 result.base64 = EncodingUtil.base64Encode(fileABlob);
             }else{
                 Map<String,Object> errorResponseMapping = (Map<String, Object>)JSON.deserializeUntyped('No Document Found');
                 result.errorMessage = (String)errorResponseMapping.get('message').toString();
             }
         return result;
     }
      
     
     /**
    * @description This method is used to get file extension using content type
    * @param  contentType  
    * @return  extension
    */
     public static string getExtension(String contentType){
         string extension = '';
         
         if(contentType == 'image/jpeg'){
             extension = '.jpeg';
         }else if(contentType == 'image/png'){
             extension = '.png';
         }else if(contentType == 'application/pdf'){
             extension = '.pdf';
         }
         return extension;
     }
     
     /**
    * @description This method is used to get content document.
    * @param  docChecklist  
    * @param  result  
    * @return  content document id
    */
     private static Id getContentDocument(Document_Checklist__c docChecklist, ResultWrapper result){
          Id contDocId;
         List<ContentVersion> contentVersionList = [SELECT ContentDocumentId 
                                                     FROM ContentVersion 
                                                     WHERE FirstPublishLocationId =: docChecklist.Id
                                                     AND Title =: docChecklist.Document_Name__c
                                                     WITH SYSTEM_MODE];
             ContentVersion conVer = new ContentVersion();
             conVer.PathOnClient = docChecklist.Document_Name__c + getExtension(docChecklist.Content_Type__c);
             conVer.Title = docChecklist.Document_Name__c;
             
             conVer.VersionData = EncodingUtil.base64Decode(result.base64);
             
             if(contentVersionList.size() > 0){
                 conVer.ContentDocumentId = contentVersionList[0].ContentDocumentId;
                 insert as system conVer;
                 contDocId = conVer.ContentDocumentId;
                 
             }
             else{
                 conVer.FirstPublishLocationId = docChecklist.Id;
                 insert as system conVer;
                 List<ContentVersion> contentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id  WITH SYSTEM_MODE];
                 contDocId = contentVersion[0].ContentDocumentId;
             }
         return contDocId;
     }
     
     
     // Wrapper class to map response to view document
     global class ResultWrapper {
         public String content{get;set;}
         public String base64{get;set;}
         public String contentType{get;set;}
         public String showToolBar{get;set;}    
         public String errorMessage{get;set;}
         public String contentDocumentId{get;set;}
         
     }  
 }