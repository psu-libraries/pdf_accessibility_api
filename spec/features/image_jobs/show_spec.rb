# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Image Jobs show', :js do
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }

  before do
    login_as(gui_user)
  end

  it 'shows all job metadata', skip: 'To be implemented in 161' do
    raise 'not implemented'
  end
end
