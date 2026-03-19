# frozen_string_literal: true

RailsAdmin.config do |config|
  config.authenticate_with do
    unless request.session[:admin] == true
      render plain: 'Forbidden', status: :forbidden
    end
  end

  config.current_user_method do
    @current_gui_user ||= GUIUser.find_by(id: session[:user_id]) if session[:user_id]
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    show
    edit
    show_in_app

    delete do
      visible do
        bindings[:abstract_model].model == Unit
      end
    end

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.navigation_static_label = 'Tools'
  config.navigation_static_links = {
    'Sidekiq' => '/sidekiq'
  }
end

Rails.application.config.to_prepare do
  RailsAdmin::ApplicationController.helper(RailsAdmin::DashboardHelper)
end
