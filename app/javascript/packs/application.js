import 'frontend'
import '@fortawesome/fontawesome-free/css/all.css';

import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'


const application = Application.start()
const context = require.context('controllers', true, /_controller\.js$/)
application.load(definitionsFromContext(context))