# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Jobs index', js: true do
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }
  let!(:job_completed) { create(:job, output_object_key: 'file1.pdf',
                                      status: 'completed',
                                      created_at: Time.zone.local(2024, 7, 22, 10, 30),
                                      owner: gui_user) }
  let!(:job_processing) { create(:job, output_object_key: 'file2.pdf',
                                       status: 'processing',
                                       created_at: Time.zone.local(2024, 7, 21, 9, 0),
                                       owner: gui_user) }

  before do
    login_as(gui_user)
  end
  it 'shows jobs and their metadata in the table' do
    visit jobs_path

    within '#jobs-table' do
      expect(page).to have_link('file1.pdf', href: job_path(job_completed))
      expect(page).to have_link('file2.pdf', href: job_path(job_processing))
      expect(page).to have_content('completed')
      expect(page).to have_content('processing')
      expect(page).to have_content('Jul 22, 2024 10:30 AM')
      expect(page).to have_content('Jul 21, 2024 9:00 AM')
    end
  end

  it 'redirects to the job show page when a link is clicked' do
    visit jobs_path

    click_link 'file1.pdf'
    expect(page).to have_current_path(job_path(job_completed))
  end
end
