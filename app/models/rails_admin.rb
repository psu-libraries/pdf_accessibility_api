# frozen_string_literal: true

RailsAdmin.config do |config|
  config.included_models = [
    'GuiUser',
    'ApiUser',
    'Job'
  ]
end
