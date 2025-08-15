import { Controller } from 'stimulus'
import Uppy from '@uppy/core'
import Dashboard from '@uppy/dashboard'
import AwsS3 from '@uppy/aws-s3'
import { generateUploadedFileData, simulateEditAndUpload } from './uppy_utils'

export default class extends Controller {
  connect() {
    console.log('yoo controller is connected')
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
    console.log('creating Uppy instance')
    return new Uppy({
      id: 'uppy_' + (new Date().getTime()),
      autoProceed: false,
      allowMultipleUploads: true,
      onBeforeFileAdded: (currentFile, files) => this.handleBeforeFileAdded(currentFile, files),
      onBeforeUpload: (files) => this.handleBeforeUpload(files)
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
        metaFields: [
          {
            id: 'alt_text',
            name: 'Alt Text',
            placeholder: 'Describe this image for accessibility',
            required: true
          }
        ]
      })
      .use(AwsS3, {
        endpoint: '/'
      })
  }

  registerUppyEventHandlers() {
    console.log('registering event handlers')
    this.uppy
      .on('file-added', (file) => this.handleFileAdded(file))
      .on('complete', (result) => this.onUppyComplete(result))
  }

  handleBeforeFileAdded(currentFile, _files) {
    const filename = currentFile.name
    const isDenylisted = this.denylist.includes(filename)

    if (isDenylisted) {
      this.uppy.info(`Error: ${filename} already exists in this version`, 'error', 10000)
      return false
    }
  }

  handleBeforeUpload(files) {
    // Validate for PDF type?
    // const fileCount = Object.keys(files).length
    // const file = Object.values(files)[fileCount - 1]
    // const missingAltText = file.type?.startsWith('image/') && !file.meta.alt_text?.trim()

    // if (missingAltText) {
    //   this.uppy.info('Please provide alt text for the image.', 'error', 5000)
    //   simulateEditAndUpload()
    //   return false
    // }
  }

  handleFileAdded(file) {
    if (file.type.startsWith('image/')) {
      this.uppy.pauseResume(file.id)
      setTimeout(() => {
        simulateEditAndUpload()
      }, 100)
    } else {
      this.uppy.upload()
    }
  }

  onUppyComplete(result) {
    result.successful.forEach(success => {
      this.parentForm.appendChild(this.createHiddenFileInput(success))
    })
  }

  createHiddenFileInput(success) {
    const inputName = this.data.get('inputName')
    const uploadedFileData = generateUploadedFileData(success)

    const input = document.createElement('input')
    input.setAttribute('type', 'hidden')
    input.setAttribute('name', inputName)
    input.setAttribute('value', uploadedFileData)

    return input
  }
}
