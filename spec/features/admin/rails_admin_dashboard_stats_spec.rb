# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Rails Admin dashboard stats' do
  let!(:admin_user) { create(:gui_user, email: 'test1@psu.edu') }

  before do
    login_as(admin_user)
  end

  it 'shows the custom dashboard stats cards' do
    create(:pdf_job, page_count: 10, status: 'processing')
    create(:pdf_job, page_count: 10, status: 'completed')
    create(:pdf_job, page_count: 10, status: 'completed', created_at: 2.days.ago)
    dead_set = instance_double(Sidekiq::DeadSet, size: 3)
    allow(Sidekiq::DeadSet).to receive(:new).and_return(dead_set)

    visit '/admin'

    within('#dashboard-stats') do
      expect(page).to have_content('Total PDF Pages Processed')
      expect(page).to have_content('PDF Pages Processed Today')
      expect(page).to have_content('PDF Jobs Currently Processing')
      expect(page).to have_content('Sidekiq DeadSet')

      expect(page).to have_content('20')
      expect(page).to have_content('10')
      expect(page).to have_content('1')
      expect(page).to have_content('3')
    end
  end
end
