# PDF Accessibility API

* Ruby version: 3.4.1
* Rails version: 7.2

## Purpose

The PDF Accessibility API is a Rails application for interfacing with the [PDF_Accessibility](https://github.com/psu-libraries/PDF_Accessibility) application, which provides accessibility remediation for PDFs. The `pdf_accessibility_api` has two major components: the API and the GUI.

## API

We use an `APIUser` model to store metadata for our API users and their associated clients/systems. A developer with console access must manually add `APIUser` records. Each `APIUser` requires:

- An `api_key` for authentication and authorization.
- The client's `webhook_endpoint`, where the PDF Accessibility API will send its final request when remediation is complete.
- The client's `webhook_key` for authenticating with the client system when the final webhook request is sent.
- An `email` and `name` to help identify the user.

Refer to the Swagger documentation for endpoint details and usage. (Add link to API docs here.)

## GUI

The GUI is still a work in progress, but its main components are:

- `/jobs` — a list of your jobs.
- `/jobs/new` — the page for uploading a file you want to remediate.
- `/jobs/{id}` — detailed information about a job (linked from `/jobs`).
- `/sidekiq` — Sidekiq interface.

### Authentication and Authorization

- The application uses a remote user header (default: `HTTP_X_AUTH_REQUEST_EMAIL`) to determine the current user, typically set by Azure.
- The list of users authorized to access the application is controlled by the `AUTHORIZED_USERS` environment variable (comma-separated emails).
- Access to the Sidekiq web UI is controlled by the `SIDEKIQ_USERS` environment variable.
- You can customize the remote user header and user lists via environment variables or `config/warden.yml`.

## Setup

### Environment Variables

1. Create an `.envrc` file in the project's root directory and add environment variables.
2. Use the `.envrc.sample` file as a template for which variables to include.
3. Get the values from Vault.
4. Run `direnv allow` to export the values.  
   (If you do not have direnv, use Homebrew to install it: `brew install direnv`.)

### Set Headers

Mock the remote user headers using a modify-header plugin within your browser.

## Docker

To build the image and run the necessary containers:

1. `docker-compose up --build`
2. Visit [http://localhost:3000](http://localhost:3000) in your browser.

## Running Tests

To run tests within the container:

1. `docker-compose exec web bash`
2. `RAILS_ENV=test bundle exec rspec`
