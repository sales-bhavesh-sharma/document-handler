import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import RelatedListHelper from "./documentChecklistTableHelper";
import {loadStyle} from 'lightning/platformResourceLoader';
import relatedListResource from '@salesforce/resourceUrl/relatedListResource';
import getFieldsAndRecords from '@salesforce/apex/DocumentSplitViewController.getFieldsAndRecords';
export default class RelatedList extends NavigationMixin(LightningElement) {
    @track openUpload = false;
    @track state = {}
    @track columns = [];
    @track fields='';
    @api recordId;
    @api sobjectApiName = 'Document_Checklist__c';
    @api relatedFieldApiName;
    @api filterConditions;
    @api numberOfRecords = 10;
    @api sortedBy='Name';
    @api sortedDirection = "ASC";
    @api rowActionHandler;
    @api fieldSetName = 'Document_Split_View';
    helper = new RelatedListHelper()

    renderedCallback() {
        loadStyle(this, relatedListResource + '/relatedList.css')
    }
    
    connectedCallback(){
       this.getData();
    }

    getData(){
        let firstTimeEntry = false;
        let firstFieldAPI;

        //make an implicit call to fetch records from database
        getFieldsAndRecords({ strObjectApiName: this.sobjectApiName,
                                strfieldSetName: this.fieldSetName})
        .then(data=>{        
            //get the entire map
            let objStr = JSON.parse(data);   
            let listOfFields= JSON.parse(Object.values(objStr)[0]);
            let items = []; //local array to prepare columns
            listOfFields.map(element=>{
                items = [...items ,{label: element.label, 
                fieldName: element.fieldPath}];
                this.fields += element.fieldPath+',';
            });
            this.fields = this.fields.slice(0,-1);
            items.push({
                    label: 'View Document',
                    fieldName: 'previewUrl',
                    type: 'url',
                    typeAttributes: { label: 'Click Here', target: '_blank'} // Changed from _self to _blank RG  UDBTEY 3012
            });
            items.push({
                type: "button", typeAttributes: {  
                    label: 'View',  
                    name: 'view',  
                    title: 'View',  
                    disabled: false,  
                    value: 'view',  
                    iconPosition: 'left'  
                }
            });
            this.columns = [...items]; 
            this.init();
        })
        .catch(error =>{
            console.log('error',error);
        })        

    }

    get hasRecords() {
        return this.state.records != null && this.state.records.length;
    }

    async init() {
        this.state.showRelatedList = this.recordId != null;
        if (! (this.recordId
            && this.sobjectApiName
            && this.relatedFieldApiName
            && this.fields
            && this.columns)) {
            this.state.records = [];
            return;
        }

        this.state.fields = this.fields
        this.state.relatedFieldApiName= this.relatedFieldApiName
        this.state.recordId= this.recordId
        this.state.sobjectApiName= this.sobjectApiName
        this.state.sortedBy= this.sortedBy
        this.state.sortedDirection= this.sortedDirection
        this.state.customActions= this.customActions
        this.state.filterConditions= this.filterConditions
        const data = await this.helper.fetchData(this.state);
        this.state.records = data.records;
        this.state.iconName = data.iconName;
        this.state.sobjectLabel = data.sobjectLabel;
        this.state.sobjectLabelPlural = data.sobjectLabelPlural;
        this.state.title = data.title;
        this.state.parentRelationshipApiName = data.parentRelationshipApiName;
        this.state.columns = this.columns;
        if(data.title.includes("Document Checklist")){
            for(let ittrator = 0; ittrator < this.state.records.length ; ittrator++){
                //this.state.records[ittrator].previewUrl = "/lightning/cmp/c__lwcWrapper?c__recordId="+this.state.records[ittrator].Id+"&c__parentId="+this.recordId+"&c__documentName="+ this.state.records[ittrator].Document_Name__c;
                // Changed from _self to _blank RG  UDBTEY 3012
                this.state.records[ittrator].previewUrl = window.location.host+"/apex/DocumentViewer?recordId="+this.state.records[ittrator].Id;
            }
        }
    }

    handleRowAction(event) {
        console.log('In Action');
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (this.rowActionHandler) {
            this.rowActionHandler.call()
        } else {
            switch (actionName) {
                case "view":
                    this.handleViewDocument(row);
                    break;
                default:
            }
        }
    }

    handleGotoRelatedList() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordRelationshipPage",
            attributes: {
                recordId: this.recordId,
                relationshipApiName: this.state.parentRelationshipApiName,
                actionName: "view",
                objectApiName: this.sobjectApiName
            }
        });
    }

    handleViewDocument(row){
        const selectEvent = new CustomEvent('viewdocument', {
            detail: {
                recordId : row.Id
            }
        });
       this.dispatchEvent(selectEvent);
    }

    handleRefreshData() {
        this.init();
    }
    openFileUpload(){
        this.openUpload = true;
    }
    closeFileUpload(){
        this.openUpload = false;
        this.state = {};
        this.fields = '';
        this.getData();

    }
}