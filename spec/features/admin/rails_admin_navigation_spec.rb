# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Rails Admin navigation' do
  let!(:admin_user) { create(:gui_user, email: 'test1@psu.edu') }

  before do
    login_as(admin_user)
  end

  it 'navigates to Sidekiq from the Rails Admin screen' do
    visit '/admin'

    expect(page).to have_link('Sidekiq', href: '/sidekiq')

    click_link 'Sidekiq'

    expect(page).to have_current_path(%r{\A/sidekiq\z})
  end
end
