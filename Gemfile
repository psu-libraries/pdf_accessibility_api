# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.4.1'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0.4'

gem 'shakapacker'
# Use mysql as the database for Active Record
gem 'mysql2'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'
# Use Redis adapter
gem 'redis', '>= 4.0.1'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mswin mswin64 mingw x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'sidekiq'

# Aws S3 SDK for Ruby
gem 'aws-sdk-s3', '~> 1.0'

# Temporary file downloads over HTTP
gem 'down'

# HTTP client
gem 'faraday'

# RSwag for API documentation
gem 'rswag-api'
gem 'rswag-ui'

gem 'image_processing'

# Alt-text generation
gem 'alt_text'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mswin mswin64 mingw x64_mingw], require: 'debug/prelude'

  gem 'niftany'

  gem 'rspec-rails'

  # Use Capybara for feature/system tests
  gem 'capybara'
  gem 'selenium-webdriver'

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem 'rubocop-rails-omakase', require: false

  # RSwag API documentation testing
  gem 'rswag-specs'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Highlight the fine-grained location where an error occurred [https://github.com/ruby/error_highlight]
  gem 'error_highlight', '>= 0.4.0', platforms: [:ruby]
end

group :test do
  gem 'climate_control'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
end

gem 'rails_warden', '~> 0.6.0'

gem 'bugsnag', '~> 6.28'
