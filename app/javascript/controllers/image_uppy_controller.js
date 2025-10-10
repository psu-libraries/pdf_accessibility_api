import { Controller } from 'stimulus'
import Uppy from '@uppy/core';
import Dashboard from '@uppy/dashboard'
import XHRUpload from '@uppy/xhr-upload';

export default class extends Controller {
  connect() {
    this.uppy = this.createUppyInstance()
    this.configureUppyPlugins()
    this.registerUppyEventHandlers()
  }

  createUppyInstance(){
    return new Uppy({
      id: 'uppy_' + (new Date().getTime()),
      allowMultipleUploadBatches: false,
      restrictions: {
        allowedFileTypes: ['.jpg', '.jpeg', '.png'],
        maxNumberOfFiles: 1
      }
    })
  }

  configureUppyPlugins() {
    this.uppy
      .use(XHRUpload, {
          endpoint: '/image_jobs',
          fieldName: 'image',
          formData: true,
          autoProceed: false
      })
      .use(Dashboard, {
        id: 'dashboard',
        target: this.element,
        inline: 'true',
        showProgressDetails: true,
        hideUploadButton: false,
        height: 350
      })
  }

  registerUppyEventHandlers() {
      this.uppy
        .on('complete', (res) => this.handleSuccess(res))
  }

  handleSuccess(res){
    let jobId = res.successful[0].response.body.jobId;
    if (jobId) {
      window.location.href = `/image_jobs/${jobId}`;
    }
  }
}