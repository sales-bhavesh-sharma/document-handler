import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LWC_Close_Button from '@salesforce/label/c.LWC_Close_Button';
import LWC_Modal_Name from '@salesforce/label/c.LWC_Modal_Name';
// import LWC_Cancel_Button from '@salesforce/label/c.LWC_Cancel_Button';
// import LWC_Modal_Name from '@salesforce/label/c.LWC_Modal_Name';
export default class GetDocument  extends NavigationMixin(LightningElement){

    label = {
        LWC_Close_Button,
        LWC_Modal_Name
    };

    siteURL;
    @api recordId;
    @api parentId;
    @api documentName;
		
    connectedCallback(){
        // added zoom=fit for better view of pdf
        this.siteURL = '/apex/DocumentViewer?recordId='+this.recordId+'&applicantId='+this.parentId+'#zoom=fit';
    }
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
}