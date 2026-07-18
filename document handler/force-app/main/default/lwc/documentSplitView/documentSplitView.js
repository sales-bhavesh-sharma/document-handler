import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LWC_Close_Button from '@salesforce/label/c.LWC_Close_Button';
import LWC_Modal_Name from '@salesforce/label/c.LWC_Modal_Name';
export default class GetDocument  extends NavigationMixin(LightningElement){

    label = {
        LWC_Close_Button,
        LWC_Modal_Name
    };

    @api filterConditions;
    @api parentRelationShipName;
    @api fieldSetName;
    @track siteURL;
    @api recordId;
    navigateToRecordPage() {
       /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.parentId,
                actionName: 'view'
            }
        });*/
        window.history.back();
	}

    handleViewDocument(event) {
        if(event.detail.recordId){
            this.siteURL = '/apex/DocumentViewer?recordId='+event.detail.recordId+'&applicantId='+this.recordId+'#zoom=fit';
        }
    }
}