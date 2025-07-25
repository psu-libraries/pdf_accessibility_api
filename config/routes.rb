# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq_web_constraint'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', :constraints => SidekiqWebConstraint.new
  get '/sidekiq', to: ->(_env) {
    [
      401,
      { 'Content-Type' => 'text/plain' },
      ['Unauthorized']
    ]
  }, constraints: ->(req) { !SidekiqWebConstraint.new.matches?(req) }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  resources :jobs, only: [:index, :show]

  namespace :api do
    namespace :v1 do
      post '/jobs', to: 'jobs#create'
    end
  end
end
