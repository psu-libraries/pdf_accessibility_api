# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.4.1'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.2.2', '>= 7.2.2.1'
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'
# Use mysql as the database for Active Record
gem 'mysql2'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'
# Use Redis adapter
# gem 'redis', '>= 4.0.1'

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

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mswin mswin64 mingw x64_mingw], require: false


  gem 'niftany'

  gem 'rspec-rails'

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem 'rubocop-rails-omakase', require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Highlight the fine-grained location where an error occurred [https://github.com/ruby/error_highlight]
  gem 'error_highlight', '>= 0.4.0', platforms: [:ruby]
end

group :test do
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
end
