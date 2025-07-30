# README
* Ruby version: 3.4.1
* Rails 7.2

## Purpose
https://github.com/psu-libraries/pdf_accessibility_api/issues/1

## Setup
### Variables
Create an `.envrc` file in the project's root directory and add environment variables.
Use the `.envrc.sample` file as a template for what variables to include.
Get the values from Vault 
Run `direnv allow` to export the values
(If you do not have direnv, use brew to install)

### Docker
To build the image and run necessary containers:

 1. `docker-compose up --build`
 2. Check it out at `localhost:3000` in your browser

 ### Running tests
 To run test within the container
 1. `docker-compose exec web bash`
 2. `RAILS_ENV=test bundle exec rspec`
 3. jimtest is best
 