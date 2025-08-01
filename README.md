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

The PDF Accessibility API acts as an intermediary to send and retrieve those files for clients. It has two major components: the API and the GUI.

## API

Refer to the Swagger documentation for endpoint details and usage. (Add link to API docs here.)

We use an `APIUser` model to store metadata for our API users and their associated clients/systems. A developer with console access must manually add `APIUser` records. Each `APIUser` requires:

- An `api_key` for authentication and authorization.
- The client's `webhook_endpoint`, where the PDF Accessibility API will send its final request when remediation is complete.
- The client's `webhook_key` for authenticating with the client system when the final webhook request is sent.
- An `email` and `name` to help identify the user.

## GUI

The GUI is still a work in progress, but its main components are:

- `/jobs` — a list of your jobs.
- `/jobs/new` — the page for uploading a file to remediate.
- `/jobs/{id}` — detailed information about a job (linked from `/jobs`).
- `/sidekiq` — Sidekiq interface.

### Authentication and Authorization

- The application uses a remote user header (default: `HTTP_X_AUTH_REQUEST_EMAIL`) to determine the current user, typically set by Azure.
- The list of users authorized to access the application is controlled by the `AUTHORIZED_USERS` environment variable (comma-separated emails).
- Access to the Sidekiq web UI is controlled by the `SIDEKIQ_USERS` environment variable.
- You can customize the remote user header and user lists via environment variables or `config/warden.yml`.

## Development Setup

### Configuration via environment variables
The Rails application needs to be configured with settings and secrets for the various other services on which it depends. This is all handled by setting the appropriate variables in the environment. In your development environment, you'll be running most of those dependencies locally, so you'll either configure the Rails app to work with your local setup, or you'll run everything with the pre-configured Docker Compose setup. However, we aren't able to run the tool that does the actual PDF remediation work locally. For the test environment, we'll be simulating the remediation tool using a local instance of MinIO, but if you want to be able to run the real remediation workflow end-to-end in your development environment, then you'll need to obtain the settings and secrets needed for remotely integrating with the real tool (which is hosted in AWS). These settings consist of individual IAM Access Key credentials and the name of the S3 bucket where the files going through the remediation workflow are stored.

If you're going to run the web application and/or background worker outside of Docker, you'll need to set multiple configuration variables in your environment. An easy way to manage this is:
1. Create an `.envrc` file in the project's root directory using the `.envrc.sample` file that is checked in with the source code as a template.
2. Fill in the template with the appropriate values for any integrated services that you'll be running locally, and your values for the AWS integration.
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
