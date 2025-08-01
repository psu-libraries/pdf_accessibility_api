import { Controller } from 'stimulus'
import consumer from '../channels/consumer'

 export default class extends Controller {
   static targets = ['status', 'finishedAt', 'downloadLink', 'processingErrorMessage'];

   connect () {
     const id = this.data.get('id')

     consumer.subscriptions.create(
       { channel: 'JobChannel', id: id },
       {
         connected: () => {
            console.log('Connected to JobChannel with ID:', id) //remove
           this.renderResult()
         },
         received: (data) => {
              console.log('Received data:', data)
           this.updateResult(data)
         }
       }
     )
   }

   updateResult (data) {
    console.log('Updating result with data:', data) //remove
     this.data.set('status', data.status)
     this.data.set('finishedAt', data.finished_at)
     this.data.set('outputUrl', data.output_url)
     this.data.set('outputUrlExpired', data.output_url_expired)
     this.data.set('processingErrorMessage', data.processing_error_message)
     this.renderResult()
   }

   renderResult () {
    console.log('Rendering result with data:', this.data.get('status'), this.data.get('finishedAt')) //remove
     this.statusTarget.textContent = this.data.get('status')
     this.finishedAtTarget.textContent = this.data.get('finishedAt') || ''
     this.renderOutputUrl()
     this.renderErrorMessage()
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