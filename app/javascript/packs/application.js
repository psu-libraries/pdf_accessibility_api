// import { Application } from "@hotwired/stimulus"
// const application = Application.start()

// import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

// const context = require.context("../controllers", true, /\.js$/)
// application.load(definitionsFromContext(context))

// import "channels"
import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'

const application = Application.start()
const context = require.context('controllers', true, /_controller\.js$/)
application.load(definitionsFromContext(context))