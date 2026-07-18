import { LightningElement, api, wire ,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDocumentChecklists from '@salesforce/apex/DocumentUploadController.getCheckists'
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTENT_TYPE_FIELD from '@salesforce/schema/Document_Checklist__c.Content_Type__c';
import DOCUMENT_CHECKLIST_OBJECT from '@salesforce/schema/Document_Checklist__c';
import uploadDocument from '@salesforce/apex/DocumentUploadController.uploadDocument';
import { CloseActionScreenEvent } from 'lightning/actions';
import LWC_Close_Button from '@salesforce/label/c.LWC_Close_Button';
import LWC_Modal_Name from '@salesforce/label/c.LWC_Upload_Document_Modal_Name';
import LWC_Submit from '@salesforce/label/c.LWC_Submit_Button';
import LWC_No_Deffered_Docment from '@salesforce/label/c.LWC_No_Deffered_Docment';
import LWC_Action from '@salesforce/label/c.LWC_Action';


export default class documentUpload extends LightningElement {
    @api recordId;
    fileData
    @track documentChecklists
    isHavingData = false;
    error
    isShowModal = true;
    disableButton = true;
    Status_Label=""
    Document_Name_Label=""
    View_Document_Label=""
    showSpinner = true;
    label = {
        LWC_Close_Button,
        LWC_Modal_Name,
        LWC_Submit,
        LWC_No_Deffered_Docment,
        LWC_Action,
    };
    @wire(getObjectInfo, { objectApiName: DOCUMENT_CHECKLIST_OBJECT })
    oppInfo({ data, error }) {
        if (data){
            this.Status_Label = data.fields.Status__c.label;
            this.Document_Name_Label = data.fields.Document_Name__c.label;
            this.View_Document_Label = data.fields.View_Document__c.label;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$documentChecklistscord.RecordTypeId', fieldApiName: CONTENT_TYPE_FIELD })
    picklistValues;

    @wire(getDocumentChecklists,{"recordId" : "$recordId"})
    checklists({ error, data }) {
        if (data) {
            this.documentChecklists = JSON.parse(JSON.stringify(data));
            for(let ittrator = 0; ittrator < data.length ; ittrator++){
                this.documentChecklists[ittrator].Document_Master_Name = data[ittrator].Document_Name__c;
                this.documentChecklists[ittrator].previewUrl = "/lightning/cmp/c__lwcWrapper?c__recordId="+this.documentChecklists[ittrator].Id+"&c__parentId="+this.recordId+"&c__documentName="+ this.documentChecklists[ittrator].Document_Name__c;
                this.documentChecklists[ittrator].isInitialStage = true;
            }
            if(this.documentChecklists.length > 0){
                this.isHavingData = true;
            }
            this.showSpinner = false;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.documentChecklists = undefined;
        }

    }

    toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
    }

    openfileUpload(event) {
        this.disableButton = false;
        const file = event.target.files[0]
        var index = event.currentTarget.dataset.id;
        var reader = new FileReader()
        reader.onload = () => {
            this.documentChecklists[index].filename = file.name;
            this.documentChecklists[index].base64 = reader.result.split(',')[1];
            this.documentChecklists[index].Content_Type__c = reader.result.split(',')[0].split(":")[1].split(";")[0];

        }
        reader.readAsDataURL(file)
    }
    
    handleClick(){
        this.disableButton = true;
        this.addDocument(this.documentChecklists[0], 0);
    }

    addDocument(documentChecklistRecord, index)
    {
        if(documentChecklistRecord.filename !== undefined && documentChecklistRecord.base64 !== undefined)
        {
            documentChecklistRecord.isInitialStage = false;
            documentChecklistRecord.Document_Name__c = documentChecklistRecord.filename;
            documentChecklistRecord.Received__c = true;
            documentChecklistRecord.Status__c = 'Received';
            var base64 = documentChecklistRecord.base64;
            delete documentChecklistRecord.filename;
            delete documentChecklistRecord.base64s;
            uploadDocument({ base64: base64, recordId: this.recordId, documentChecklistRecord: documentChecklistRecord }).then(result=>{
                this.documentChecklists[index].isCompleted = true;
                this.documentChecklists[index].View_Document__c = "Document Available";
                index++;
                if(this.documentChecklists[index])
                  this.addDocument(this.documentChecklists[index], index);
            }).catch(error => {
                console.log(error);
            });
        }else
        {
            index++;
                if(this.documentChecklists[index])
                  this.addDocument(this.documentChecklists[index], index);
        }
    }

    closeQuickAction() {
        const selectEvent = new CustomEvent('closequickaction');
       this.dispatchEvent(selectEvent);
    }
}