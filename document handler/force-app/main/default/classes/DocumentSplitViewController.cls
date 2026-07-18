/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* @description   :-  Controller for DocumentSplitView Component
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        :-  Bhavesh Sharma <bhavesh.sharma@salesforce.com> 
* @author        :-  Udit Singhal <udit.singhal@salesforce.com> 
* @Company       :-  Salesforce
* @version       :-  1.0.0
* @created       :-  10/11/2024
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class DocumentSplitViewController {
    public static final String FIELDS_PARAM = 'fields';
    public static final String RECORD_ID_PARAM = 'recordId';
    public static final String SOBJECT_API_NAME_PARAM = 'sobjectApiName';
    public static final String SOBJECT_LABEL_PARAM = 'sobjectLabel';
    public static final String SOBJECT_LABEL_PLURAL_PARAM = 'sobjectLabelPlural';
    public static final String PARENT_RELATIONSHIP_API_NAME_PARAM = 'parentRelationshipApiName';
    public static final String RELATED_FIELD_API_NAME_PARAM = 'relatedFieldApiName';
    public static final String SORTED_DIRECTION_PARAM = 'sortedDirection';
    public static final String SORTED_BY_PARAM = 'sortedBy';
    public static final String RECORDS_PARAM = 'records';
    public static final String ICON_NAME_PARAM = 'iconName';
	public static final String FILTER_CONDITIONS = 'filterConditions';
    /**
    * @description initData
    * @param jsonData
    * @return String
    */
    @AuraEnabled
    public static String initData(String jsonData){
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(RECORDS_PARAM, getRecords(jsonData));
        
        String sobjectApiName = (String)requestMap.get(SOBJECT_API_NAME_PARAM);
        responseMap.put(ICON_NAME_PARAM, 'custom:custom58');
        String recordId = (String)requestMap.get(RECORD_ID_PARAM);
        String relatedFieldApiName = (String)requestMap.get(RELATED_FIELD_API_NAME_PARAM);
        responseMap.put(PARENT_RELATIONSHIP_API_NAME_PARAM, getParentRelationshipName(recordId, sobjectApiName, relatedFieldApiName));

        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectApiName);
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        responseMap.put(SOBJECT_LABEL_PARAM, sobjectDescribe.getLabel());
        responseMap.put(SOBJECT_LABEL_PLURAL_PARAM, sobjectDescribe.getLabelPlural());
        return JSON.serialize(responseMap);
    }
    
    /**
    * @description getRecords
    * @param jsonData
    * @return List<Sobject>
    */
	@AuraEnabled
    public static List<Sobject> getRecords(String jsonData){
		Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        String fields = (String)root.get(FIELDS_PARAM);
        String recordId = (String)root.get(RECORD_ID_PARAM);
		String relatedFieldApiName = (String)root.get(RELATED_FIELD_API_NAME_PARAM);
        String filterConditions = (String)root.get(FILTER_CONDITIONS); 
		String sobjectApiName = (String)root.get(SOBJECT_API_NAME_PARAM);        
		String orderBy = (String)root.get(SORTED_BY_PARAM) + ' ' + (String)root.get(SORTED_DIRECTION_PARAM);   
        String criteriaString = '';
        
        if(String.isNotBlank(filterConditions)){
            criteriaString = relatedFieldApiName+ '= :recordId AND '+ String.escapeSingleQuotes(filterConditions) + ' ORDER BY ';
        }else{
            criteriaString = relatedFieldApiName+ '= :recordId ORDER BY ';
        }
        String query = 'Select '+fields+' From '+sobjectApiName+' WHERE ' + criteriaString + orderBy+' Limit :numberOfRecords ';
        
         String queryTemplate = 'Select {0} '+
            					 'From {1}'+
             						' WHERE  {2} =: recordId AND Received__c = true '+
             							'{3} '+
                               'WITH USER_MODE '+
             				   'ORDER BY {4}';
        System.debug(String.format(queryTemplate,
                                            new List<String> {fields, sobjectApiName, relatedFieldApiName, String.isNotBlank(filterConditions) ? ' AND '+filterConditions: '', orderBy}
                                           ));
        return Database.query(String.format(queryTemplate,
                                            new List<String> {fields, sobjectApiName, relatedFieldApiName, String.isNotBlank(filterConditions) ? ' AND '+filterConditions: '', orderBy}
                                           ));
	}
        
    /**
    * @description getParentRelationshipName
    * @param recordId
    * @param childSobjectApiName
    * @param relatedFieldApiName
    * @return String
    */
    private static String getParentRelationshipName(Id recordId, String childSobjectApiName, String relatedFieldApiName){
        Schema.DescribeSObjectResult descrRes = recordId.getSObjectType().getDescribe();
        String name;
        for (Schema.ChildRelationship cr: descrRes.getChildRelationships()){ 
            if(cr.getChildSObject().getDescribe().getName() == childSobjectApiName
            && cr.getField().getDescribe().getName() == relatedFieldApiName){
          	 	name = cr.getRelationshipName();
                break;
            }
        }     
        return name;
    }      
    
    /**
    * @description getFieldsAndRecords
    * @param strObjectApiName
    * @param strfieldSetName
    * @return String
    */
    @AuraEnabled (cacheable=true)
    public static String getFieldsAndRecords(String strObjectApiName, String strfieldSetName){
        Map<String, String> returnMap = new Map<String,String>();
        if(!String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName)){
            //get fields from FieldSet
            SObject sObj = (SObject)(Type.forName('Schema.'+ strObjectApiName).newInstance());
            List<Schema.FieldSetMember> lstFSMember = 
                sObj.getSObjectType().getDescribe().fieldSets.getMap().get(strfieldSetName).getFields();
             //prepare a map which will hold fieldList and recordList and return it
	     returnMap.put('FIELD_LIST', JSON.serialize(lstFSMember));
	     return JSON.serialize(returnMap);
        }
        return null;
    }
    
}