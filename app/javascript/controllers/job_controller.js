import { Controller } from 'stimulus'
import { DateTime } from 'luxon';
import consumer from '../channels/consumer'

 export default class extends Controller {
   static targets = ['status', 'finishedAt', 'downloadLink', 'processingErrorMessage'];

   connect () {
     const id = this.data.get('id')

     consumer.subscriptions.create(
       { channel: 'JobChannel', id: id },
       {
         connected: () => {
           this.renderResult()
         },
         received: (data) => {
           this.updateResult(data)
         }
       }
     )
   }

   updateResult (data) {
     this.data.set('status', data.status || '')
     this.data.set('finishedAt', data.finished_at || '')
     this.data.set('outputUrl', data.output_url || '')
     this.data.set('outputUrlExpired', data.output_url_expired || 'false')
     this.data.set('processingErrorMessage', data.processing_error_message || '')
     this.renderResult()
   }

   renderResult () {
     this.statusTarget.textContent = this.data.get('status')
     this.renderFinishedAt()
     this.renderOutputUrl()
     this.renderErrorMessage()
   }

   renderFinishedAt () {
     const finishedAt = this.data.get('finishedAt')
     const finishedAtDate = DateTime.fromISO(finishedAt)

     this.finishedAtTarget.textContent = finishedAtDate.toFormat("MMM d, yyyy h:mm a")
   }

   renderOutputUrl () {
     const outputUrl = this.data.get('outputUrl')
     const outputUrlExpired = this.data.get('outputUrlExpired')

       if (outputUrl) {
         if (outputUrlExpired === 'true') {
           this.downloadLinkTarget.innerHTML = 'Expired'
         } else {
           this.downloadLinkTarget.innerHTML = '<a href="' + outputUrl + '" target="_blank">Click to download</a>'
         }
       } else {
         this.downloadLinkTarget.innerHTML = 'Not available'
       }
   }

   renderErrorMessage() {
     const processingErrorMessage = this.data.get('processingErrorMessage')

     if (processingErrorMessage) {
       this.processingErrorMessageTarget.innerHTML = '<pre>' + processingErrorMessage + '</pre>'
     } else {
       this.processingErrorMessageTarget.innerHTML = 'None'
     }
   }
 }