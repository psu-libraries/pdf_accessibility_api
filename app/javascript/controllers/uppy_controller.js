import { Controller } from 'stimulus'
import Uppy from '@uppy/core'
import Dashboard from '@uppy/dashboard'
import AwsS3 from '@uppy/aws-s3'

export default class extends Controller {
  connect() {
    this.uppy = this.createUppyInstance()
    this.configureUppyPlugins()
    this.registerUppyEventHandlers()
  }

  createUppyInstance() {
    return new Uppy({
      id: 'uppy_' + (new Date().getTime()),
      allowMultipleUploadBatches: false,
      restrictions: {
        allowedFileTypes: ['.pdf'],
        maxNumberOfFiles: 1
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
          const resp = await fetch('/jobs/sign', {
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
          file.meta.objectKey = data.object_key
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

  async handleComplete(res) {
    if (res.successful == undefined || res.successful.length == 0) {
      return;
    }
    const jobId = res.successful[0].meta.jobId
    if (jobId) {
      await fetch('/jobs/complete', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          job_id: jobId,
          output_url: res.successful[0].uploadURL,
          object_key: res.successful[0].meta.objectKey
        })
      })
      window.location.href = `/jobs/${jobId}`;
    }
  }
}
