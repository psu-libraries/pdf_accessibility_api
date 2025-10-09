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
      autoProceed: true,
      restrictions: {
        allowedFileTypes: ['.pdf'],
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
          limit: 1,
      })
      .use(Dashboard, {
        id: 'dashboard',
        target: this.element,
        inline: 'true',
        showProgressDetails: true,
        height: 350,
        doneButtonHandler: null,
      })
  }

  registerUppyEventHandlers() {
      this.uppy
        .on('complete', (e) => this.handleSuccess(e))
  }

  handleSuccess(res){
    let jobId = res.successful[0].response.body.jobId;
    if (jobId) {
      window.location.href = `/image_jobs/${jobId}`;
    }
  }
}