/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @description   :-  Test class for DocumentSplitViewController
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        :-  Bhavesh Sharma <bhavesh.sharma@salesforce.com> 
* @author        :-  Udit Singhal <udit.singhal@salesforce.com> 
* @Company       :-  Salesforce
* @version       :-  1.0.0
* @created       :-  10/11/2024
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public with sharing class DocumentSplitViewControllerTest {
    
    @isTest public static void testInit(){
        Account accRecord = new Account(Name = 'Test Account');
        insert accRecord;
        
        Document_Checklist__c checkListRecord = new Document_Checklist__c();
        checkListRecord.Account__c = accRecord.Id;
        checkListRecord.Document_Name__c = 'Test document.pdf';
        checkListRecord.Category__c = 'Other Documents';
        checkListRecord.Content_Type__c = 'application/pdf';
        checkListRecord.Received__c = true;
        insert checkListRecord;
        
        Map<String, Object> requestMap = new Map<String, Object>(); 
        requestMap.put('showRelatedList', true);
        requestMap.put(DocumentSplitViewController.FIELDS_PARAM, 'Document_Name__c,Category__c,Content_Type__c');
        requestMap.put(DocumentSplitViewController.RELATED_FIELD_API_NAME_PARAM, 'Account__c');
        requestMap.put(DocumentSplitViewController.RECORD_ID_PARAM, accRecord.Id);
        requestMap.put(DocumentSplitViewController.SOBJECT_API_NAME_PARAM, 'Document_Checklist__c');
        requestMap.put(DocumentSplitViewController.SORTED_BY_PARAM, 'Name');
        requestMap.put(DocumentSplitViewController.SORTED_DIRECTION_PARAM, 'ASC');
        
        String jsonData = DocumentSplitViewController.initData(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        List<Object> records = (List<Object>)responseMap.get(DocumentSplitViewController.RECORDS_PARAM);
        System.assert(!records.isEmpty());
        System.debug('Line 22');
        String iconName = (String)responseMap.get(DocumentSplitViewController.ICON_NAME_PARAM);
        System.assert(String.isNotBlank(iconName));
    }
    
    @isTest public static void testGetFieldsAndRecords(){
        
        Test.startTest();        
        String jsonData = DocumentSplitViewController.getFieldsAndRecords('Document_Checklist__c', 'Document_Split_View');
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        String fiedsName = (String)responseMap.get('FIELD_LIST');
        System.assert(String.isNotBlank(fiedsName));
        List<Object> records = (List<Object>)JSON.deserializeUntyped(fiedsName);
        System.assert(!records.isEmpty());
        Test.stopTest();  
    }
}