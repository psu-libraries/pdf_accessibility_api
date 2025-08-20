import { Controller } from 'stimulus'
import Uppy from '@uppy/core'
import Dashboard from '@uppy/dashboard'
import AwsS3 from '@uppy/aws-s3'

export default class extends Controller {
  connect() {
    this.uploadSubmit = document.querySelector('.upload-submit')
    this.parentForm = document.getElementById(this.data.get('parentForm'))
    this.denylist = JSON.parse(this.data.get('denylist') || '[]')

    this.initializeUppy()
  }

  initializeUppy() {
    this.uppy = this.createUppyInstance()
    this.configureUppyPlugins()
    this.registerUppyEventHandlers()
  }

  createUppyInstance() {
    return new Uppy({
      id: 'uppy_' + (new Date().getTime()),
      autoProceed: false,
      allowMultipleUploads: true,
    })
  }

  configureUppyPlugins() {
    console.log('configuring plug-ins')
    this.uppy
      .use(Dashboard, {
        id: 'dashboard',
        target: this.element,
        inline: 'true',
        showProgressDetails: true,
        height: 350,
        doneButtonHandler: null,
      })
      .use(AwsS3, {
        allowMultipleUploads: true,
        getUploadParameters: async (file) => {
          const resp = await fetch('/s3/sign', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              filename: file.name,
              content_type: file.type,
              size: file.size
            })
          })
          console.log('waiting for a response: ' + resp.stringify)
          const { url, headers } = await resp.json();
          console.log(url)

          return {
            method: 'PUT',
            url,
            headers
          };
        }
      })
  }

  registerUppyEventHandlers() {
    console.log('registering event handlers')
    this.uppy
      // .on('file-added', (_) => this.handleFileAdded())
      .on('complete', (_) => console.log('Successfully uploaded'))
  }


  handleFileAdded() {
    this.uppy.upload()
  }

}
