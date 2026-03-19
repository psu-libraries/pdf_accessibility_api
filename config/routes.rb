# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount ActionCable.server => '/cable'
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq', :constraints => ->(req) { req.session[:admin] == true }
  mount OkComputer::Engine, at: '/healthcheck'

  get '/sidekiq', to: ->(_env) {
    [
      401,
      { 'Content-Type' => 'text/plain' },
      ['Unauthorized']
    ]
  }, constraints: ->(req) { req.session[:admin] != true }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  # Defines the root path route ("/")
  root 'pdf_jobs#new'

  resources :pdf_jobs, only: [:index, :show, :new]
  # Uppy routes
  post '/pdf_jobs/sign', to: 'pdf_jobs#sign'
  post '/pdf_jobs/complete', to: 'pdf_jobs#complete'

  resources :image_jobs, only: [:index, :show, :new, :create]

  get '/help', to: 'application#help', as: :help_page

  namespace :api do
    namespace :v1 do
      post '/jobs', to: 'jobs#create'
    end
  end

  get '/auth/azure_oauth/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  delete '/logout', to: 'sessions#destroy'
  get '/unauthorized', to: 'errors#unauthorized'
end
