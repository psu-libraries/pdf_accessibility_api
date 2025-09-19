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
      restrictions: {
        allowedFileTypes: ['.pdf']
      }
    })
  }

  configureUppyPlugins() {
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
          const data = await resp.json();
          file.meta.jobId = data.job_id;
          return {
            method: 'PUT',
            url: data.url,
            headers: data.headers
          };
        }
      })
  }

  registerUppyEventHandlers() {
    this.uppy
      .on('complete', (res) => this.handleComplete(res))
  }

//  Reroute to the page of the Job Created
  handleComplete(res) {
    if (res.successful.isArray || res.successful.length == 0) {
      return;
    }
    if (res.successful.length > 1) {
      window.location.href = `/jobs`;
      return;
    }
    const jobId = res.successful[0].meta.jobId
    if (jobId) {
      window.location.href = `/jobs/${jobId}`;
    }
  }
}
