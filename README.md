# PDF Accessibility API

* Ruby version: 3.4.1
* Rails version: 7.2

## External Dependencies
- MariaDB
- Redis
- MinIO (for automated testing) or [PDF Processing AWS Infrastructure](https://github.com/psu-libraries/PDF_Accessibility)

## Purpose

The PDF Accessibility API is a Rails application for interfacing with the [PDF_Accessibility](https://github.com/psu-libraries/PDF_Accessibility) application, which provides accessibility remediation for PDFs.

At its core, the PDF Accessibility API is an interface to an S3 bucket with:
- an input directory, where the API places files to be processed by the PDF_Accessibility application
- an output directory, where the PDF_Accessibility application places the processed files to be retrieved

The PDF Accessibility API acts as an intermediary to send and retrieve those files for clients. It has two major components: the API and the GUI. Additionally, there is the option to only generate alt-text for a given image. This option is currently only available through a GUI.

## PDF Remediation – API

Refer to the Swagger documentation for endpoint and webhook details at `/api-docs`.

We use an `APIUser` model to store metadata for our API users and their associated clients/systems. A developer with console access must manually add `APIUser` records. Each `APIUser` requires:

- An `api_key` for authentication and authorization.
- The client's `webhook_endpoint`, where the PDF Accessibility API will send its final request when remediation is complete.
- The client's `webhook_key` for authenticating with the client system when the final webhook request is sent.
- An `email` and `name` to help identify the user.

## PDF Remediation - GUI

The PDF Remediation GUI's main components are:

- `/pdf_jobs` — a list of your jobs.
- `/pdf_jobs/new` — the page for uploading a file to remediate.
- `/pdf_jobs/{id}` — detailed information about a job (linked from `/pdf_jobs`).
- `/sidekiq` — Sidekiq interface.

## Image Alt Text - GUI
There is also a standalone GUI just for images. This is for users who just want to generate alt-text for an image without going through the full - and pricy - PDF remediation process.
- `/image_jobs` — a list of image jobs, their links, and their status.
- `/image_jobs/new` — the upload page for a new image
- `/image_jobs/{id}` — detailed information about an image, including any generated alt-text.

### Authentication and Authorization

- The application uses a remote user header (default: `HTTP_X_AUTH_REQUEST_EMAIL`) to determine the current user, typically set by Azure.
- The list of users authorized to access the application is controlled by the `AUTHORIZED_USERS` environment variable (comma-separated emails).
- Access to the Sidekiq web UI is controlled by the `SIDEKIQ_USERS` environment variable.
- You can customize the remote user header and user lists via environment variables or `config/warden.yml`.

## Development Setup

### Configuration via environment variables
The Rails application needs to be configured with settings and secrets for the various other services on which it depends. This is all handled by setting the appropriate variables in the environment. In your development environment, you'll typically be running all of those dependencies locally, so you'll either configure the Rails app to work with your local setup, or you'll simply run everything using the pre-configured Docker Compose setup (strongly recommended).

We aren't able to run the tool that does the actual PDF remediation work locally. So for the test and development environments, we'll be simulating the remediation tool using a local instance of MinIO and a simple script that mocks out the behavior of the remediation tool. By default, you should configure your environment so that it uses the credentials and settings for the local MinIO instance instead of AWS S3 for your test and development environments. However, if you want to temporarily run the real remediation workflow end-to-end in your development environment for manual testing, then you can do so by obtaining the credentials and settings needed for remotely integrating with the real tool (which is hosted in AWS) and configuring your environment to use these instead. These settings consist of individual IAM Access Key credentials and the name of the S3 bucket where the files going through the remediation workflow are stored. You should do this only when absolutely necessary since using the actual remediation tool is costly.

You'll need to set multiple configuration variables in your environment before running your local setup or Docker Compose setup.  An easy way to manage this is:
1. Create an `.envrc` file in the project's root directory using the `.envrc.sample` file that is checked in with the source code as a template. The sample file contains the values that you'll need to use for connecting the local MinIO instance if you're running with Docker Compose.
2. Fill in the template with the appropriate values for any integrated services that you'll be running locally. If you're running with the default Docker Compose setup, then you shouldn't need to configure anything except the settings for the MinIO (or AWS S3) connection.
3. Run `direnv allow` to export the values (If you do not have direnv, it can be installed with Homebrew on Mac).

### Set Headers

To authenticate locally you will need to mock the remote user header (e.g., `HTTP_X_AUTH_REQUEST_EMAIL`).  
You can do this using a modify-header browser extension such as [ModHeader](https://modheader.com/) or [Requestly](https://requestly.io/):

- Add a request header:  
  `HTTP_X_AUTH_REQUEST_EMAIL: your-email@psu.edu`

### Docker

#### Running the application and dependencies
To build the image and run necessary containers:

 1. `docker compose up --build`
 2. If everything starts up correctly, the Rails app will be running at `http://localhost:3000`

#### Running tests
To run the tests within the container:
1. `docker compose exec web bash`
2. `RAILS_ENV=test bundle exec rspec`


## Swagger Docs

Our API and webhook documentation is generated using RSwag and the RSwag DSL from the spec files in `spec/requests/api/v1/api-docs`.  If you make changes to the RSwag spec files, run `RAILS_ENV=test bundle exec rails rswag` to regenerate the swagger.yaml.


#### Preview deployments 
Preview deployments are triggered off branch-name conventions. To trigger a Preview deployment, create a branch with a `preview/` prefix, and CI will generate a corresponding `Application` object that ArgoCD will deploy

Example: we are fixing a bug in something

`git checkout -b preview/fixbug`

Will deploy application pdfapi-fixbug-uldev, and it will be available via pdfapi-fixbug-uldev.uldev.k8s.libraries.psu.edu

Preview branch names shouldn't contain underscores or special characters (they need to be DNS complient)
