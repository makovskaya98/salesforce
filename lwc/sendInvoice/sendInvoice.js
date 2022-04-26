import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import getOpportunityContactRole from '@salesforce/apex/SendInvoiceController.getOpportunityContactRole';
import getEmailBody from '@salesforce/apex/SendInvoiceController.getEmailBody';
import getDocumentId from '@salesforce/apex/SendInvoiceController.getDocumentId';
import sendEmail from '@salesforce/apex/SendInvoiceController.sendEmail';

export default class SendInvoice extends NavigationMixin(LightningElement) {
    @api recordId;
    record;
    error;
    contactName;
    contactEmail;
    invoiceNumber;
    emailBodyText;
    documentId;

    @wire(getOpportunityContactRole, {recordId: '$recordId'})
    wiredOpportunity({error, data}) {
        if (data) {
            this.record = data;
            this.contactName = data[0].Contact.Name;
            this.contactEmail = data[0].Contact.Email;
            this.invoiceNumber = data[0].Opportunity.Invoice_Number__c;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getEmailBody, {recordId: '$recordId'})
    wiredEmailBody({error, data}) {
        if (data) {
            this.emailBodyText = data;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getDocumentId, {recordId: '$recordId'})
    wiredDocumentId({error, data}) {
        if (data) {
            this.documentId = data;
        } else if (error) {
            this.error = error;
        }
    }

    sendEmail() {
        sendEmail({
            invoiceNumber: this.invoiceNumber,
            emailBodyText: this.emailBodyText,
            contactEmail: this.contactEmail,
            documentId: this.documentId
        }).then((result) => {
            const event = new ShowToastEvent({
                title: 'Success!',
                message: 'Email was sent successfully!',
                variant: 'success'
            });
            this.dispatchEvent(event);
        }).catch(() => {
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Sorry, Email was not sent!',
                variant: 'error'
            });
            this.dispatchEvent(event);
        });
    }

    previewFile() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: this.documentId,
                selectedRecordId: this.documentId
            }
        })
        console.log(this.documentId);
    }

    handleChange(event) {
        this.emailBodyText = event.target.value;
    }
}