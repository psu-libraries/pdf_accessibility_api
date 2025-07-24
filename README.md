# README

* Ruby version: 3.4.1
* Rails 7.2

## Purpose
https://github.com/psu-libraries/pdf_accessibility_api/issues/1

## External Dependencies:
- MariaDB
- Redis
- MinIO (for automated testing) or [PDF Processing AWS Infrastructure](https://github.com/psu-libraries/PDF_Accessibility)

## Development Setup

### Configuration via environment variables
The Rails application needs to be configured with settings and secrets for the various other services on which it depends. This is all handled by setting the appropriate variables in the environment. In your development environment, you'll be running most of those dependencies locally, so you'll either configure the Rails app to work with your local setup, or you'll run everything with the pre-configured Docker Compose setup. However, we aren't able to run the tool that does the actual PDF remediation work locally. For the test environment, we'll be simulating the remediation tool using a local instance of MinIO, but if you want to be able to run the real remediation workflow end-to-end in your development environment, then you'll need to obtain the settings and secrets needed for remotely integrating with the real tool (which is hosted in AWS). These settings consist of individual IAM Access Key credentials and the name of the S3 bucket where the files going through the remediation workflow are stored.

If you're going to run the web application and/or background worker outside of Docker, you'll need to set multiple configuration variables in your environment. An easy way to manage this is:
1. Create an `.envrc` file in the project's root directory using the `.envrc.sample` file that is checked in with the source code as a template.
2. Fill in the template with the appropriate values for any integrated services that you'll be running locally, and your values for the AWS integration.
3. Run `direnv allow` to export the values (If you do not have direnv, it can be installed with Homebrew on Mac).

If you're going to run the application and its dependencies with Docker Compose, then most of the configuration is already handled in the `docker-compose.yml` file. However, you'll still need to provide your configuration for the AWS integration. This is done by creating a `.env.dev` file in the project root directory using `.env.dev.sample` as a template and filling in the values for your IAM Access Key and the name of the S3 bucket used by the remediation tool.

### Docker

#### Running the application and dependencies
To build the image and run necessary containers:

 1. `docker compose --env-file .env.dev up --build`
 2. If everything starts up correctly, the Rails app will be running at `http://localhost:3000`

 #### Running tests
 To run the tests within the container:
 1. `docker compose exec web bash`
 2. `RAILS_ENV=test bundle exec rspec`
