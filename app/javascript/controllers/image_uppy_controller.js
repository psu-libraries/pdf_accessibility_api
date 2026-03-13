import { Controller } from 'stimulus'
import Uppy from '@uppy/core';
import Dashboard from '@uppy/dashboard'
import XHRUpload from '@uppy/xhr-upload';
import Compressor from '@uppy/compressor';
import { checkForForbiddenCharacters } from './shared_uppy'

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
      .use(Compressor, {
        quality: 0.8,
        maxWidth: 1600,
        maxHeight: 1600,
        mimeType: 'image/jpeg',
        convertSize: 0
      })
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
        .on('upload', (_, files) => checkForForbiddenCharacters(files))
        .on('complete', (res) => this.handleSuccess(res))
  }

  handleSuccess(res){
    let jobId = res.successful[0].response.body.jobId;
    if (jobId) {
      window.location.href = `/image_jobs/${jobId}`;
    }
  }
}