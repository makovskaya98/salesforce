import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import summaryDataOnCustomers from '@salesforce/apex/SummaryDataOnCustomersController.getSummaryDataOnCustomers';
import soldProducts from '@salesforce/apex/SummaryDataOnCustomersController.getSoldProducts';

export default class SummaryDataOnCustomers extends LightningElement {
    @api recordId;
    activeSectionsMessage = '';
    oldAccountToOpportunity;
    accountToOpportunity;
    isModalOpen = false;
    idOpportunity;
    productsInfo;
    searchAccount;
    currentPage = 1;
    pageSize = 5;
    disabledPrevious = true;
    disabledNext = false;

    connectedCallback() {
        summaryDataOnCustomers({
            recordId: this.recordId
        }).then((result) => {
            this.accountToOpportunity = result.slice(0, this.pageSize);
            this.oldAccountToOpportunity = result;
            if (this.pageSize >= this.oldAccountToOpportunity.length) {
                this.disabledNext = true;
            }
        })
    }

    searchData(event) {
        this.searchAccount = event.target.value;
        let foundAccount = [];
        let searchAccount = this.searchAccount;
        this.oldAccountToOpportunity.find(function (keyWord) {
            if (keyWord['accountName'].toUpperCase().includes(searchAccount.toUpperCase())) {
                foundAccount.push(keyWord);
            }
        });
        this.accountToOpportunity = foundAccount;
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    openModal(event) {
        this.isModalOpen = true;
        this.idOpportunity = event.target.dataset.recordId;
        soldProducts({idOpportunity: this.idOpportunity}).then((result) => {
            this.productsInfo = result;
        }).catch(() => {

        })
    }

    closeModal() {
        this.isModalOpen = false;
    }

    submitDetails() {
        this.isModalOpen = false;
    }

    getPrevious() {
        this.currentPage--;
        this.accountToOpportunity = this.oldAccountToOpportunity.slice(
            (this.currentPage - 1) * this.pageSize,
            (this.currentPage - 1) * this.pageSize + this.pageSize
        );
        if (this.accountToOpportunity.slice(0)[0]['accountName'] === this.oldAccountToOpportunity.slice(0)[0]['accountName']) {
            this.currentPage = 1;
            this.disabledPrevious = true;
            this.disabledNext = false;
        }
    }

    getNext() {
        this.currentPage++;
        this.accountToOpportunity = this.oldAccountToOpportunity.slice(
            (this.currentPage - 1) * this.pageSize,
            (this.currentPage - 1) * this.pageSize + this.pageSize
        );
        if (this.currentPage >= 1) {
            this.disabledPrevious = false;
        }
        if (this.accountToOpportunity.slice(-1)[0]['accountName'] === this.oldAccountToOpportunity.slice(-1)[0]['accountName']) {
            this.disabledNext = true;
        }
    }

}