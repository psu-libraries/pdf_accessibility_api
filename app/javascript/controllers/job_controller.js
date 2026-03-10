import { Controller } from 'stimulus'
import { DateTime } from 'luxon';
import consumer from '../channels/consumer'

export default class extends Controller {
  static targets = [
    'outputObjectKey',
    'status',
    'finishedAt',
    'altText',
    'downloadLink',
    'processingErrorMessage'
  ];

  connect() {
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

  updateResult(data) {
    if (this.hasOutputObjectKeyTarget) {
      this.data.set('objectKey', data.object_key || '')
    }
    this.data.set('status', data.status || '')
    this.data.set('finishedAt', data.finished_at || '')
    this.data.set('outputUrl', data.output_url || '')
    this.data.set('outputUrlExpired', data.output_url_expired || 'false')
    this.data.set('processingErrorMessage', data.processing_error_message || '')
    this.data.set('altText', data.alt_text || '')
    this.renderResult()
  }

  renderResult() {
    if (this.hasOutputObjectKeyTarget) {
      this.outputObjectKeyTarget.textContent = this.data.get('objectKey')
    }
    if (this.hasAltTextTarget) {
      this.altTextTarget.textContent = this.data.get('altText')
    }
    this.renderStatus()
    this.renderFinishedAt()
    this.renderOutputUrl()
    this.renderErrorMessage()
  }

  renderStatus() {
    let status = this.data.get('status');
    if (status.includes('processing')){
      this.statusTarget.innerHTML = `${status} <i class="fa-solid fa-spinner fa-spin-pulse"></i>`
      return
    }
    this.statusTarget.textContent = status;
  }

  renderFinishedAt() {
    if (this.data.get('finishedAt')) {
    const finishedAt = this.data.get('finishedAt')
    const finishedAtDate = DateTime.fromISO(finishedAt)

    this.finishedAtTarget.textContent = finishedAtDate.toFormat("MMM d, yyyy h:mm a")
    }
    else {
      this.finishedAtTarget.textContent = ''
    }
  }

  renderOutputUrl() {
    if (!this.hasDownloadLinkTarget) {
      return
    }
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
      this.processingErrorMessageTarget.innerHTML = '<li><strong>Errors:<pre>' + processingErrorMessage + '</pre></strong></li>'
    }
  }
}