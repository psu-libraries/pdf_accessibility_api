import { Controller } from 'stimulus'
import Uppy from '@uppy/core'
import Dashboard from '@uppy/dashboard'
import AwsS3 from '@uppy/aws-s3'
import { PDFDocument } from 'pdf-lib'
import { checkForForbiddenCharacters } from './shared_uppy'

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
          const pageCount = await this.getPageCount(file)
          const resp = await fetch('/pdf_jobs/sign', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              filename: file.name,
              content_type: file.type,
              size: file.size,
              page_count: pageCount
            })
          })
          if (!resp.ok) {
            const errorData = await resp.json().catch(() => ({}))
            throw new Error(errorData.message || 'Failed to validate PDF page count before upload')
          }
          const data = await resp.json();
          file.meta.objectKey = data.object_key
          file.meta.pageCount = pageCount
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
      .on('upload', (_, files) => checkForForbiddenCharacters(files))
      .on('complete', (res) => this.handleComplete(res))
  }

  async getPageCount(file) {
    const arrayBuffer = await file.data.arrayBuffer()
    const pdfDoc = await PDFDocument.load(arrayBuffer)
    return pdfDoc.getPageCount()
  }

  handleComplete(res) {
    if (res.successful == undefined || res.successful.length == 0) {
      return;
    }
    fetch('/pdf_jobs/complete', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          output_url: res.successful[0].uploadURL,
          object_key: res.successful[0].meta.objectKey,
          page_count: res.successful[0].meta.pageCount
        })
      })
      .then(r => r.json())
      .then(data => {
        if (data.job_id) {
          window.location.href = `/pdf_jobs/${data.job_id}`;
        }
      })
  }
}
