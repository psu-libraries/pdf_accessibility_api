# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Image Jobs show', :js do
  let!(:alt_text) { 'The only winning move is not to play.' }
  let!(:error_message) { "I'm sorry, Dave. I'm afraid I can't do that." }
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }

  before do
    login_as(gui_user)
  end

  it 'shows all job metadata including alt-text' do
    job = create(:image_job, output_object_key: 'test.jpg',
                             status: 'completed',
                             alt_text: alt_text,
                             created_at: Time.new(2024, 7, 22, 10, 30),
                             owner: gui_user)
    visit image_job_path(job)

    expect(page).to have_content('Job Details')
    expect(page).to have_content('test.jpg')
    expect(page).to have_content('Jul 22, 2024 10:30 AM')
    expect(page).to have_content('completed')
    expect(page).to have_content('Errors:')
    expect(page).to have_content('None')
    expect(page).to have_content(alt_text)
    expect(page).to have_link('<< Image Jobs List', href: image_jobs_path)
  end

  it 'shows error message if present' do
    job = create(:image_job, owner: gui_user, processing_error_message: error_message)
    visit image_job_path(job)

    expect(page).to have_content('Errors:')
    expect(page).to have_content(error_message)
  end

  it 'updates status, finished_at, download, and errors in real-time' do
    job = create(:image_job, owner: gui_user)
    visit image_job_path(job)

    expect(page).to have_content('Status: processing')
    expect(page).to have_content('Finished At:')
    expect(page).to have_content('Errors: None')

    job.update!(
      status: 'completed',
      finished_at: Time.new(2024, 7, 22, 11, 0, 0, '-04:00'),
      alt_text: alt_text
    )

    expect(page).to have_content('Status: completed')
    expect(page).to have_content('Jul 22, 2024 11:00 AM')
    expect(page).to have_content(alt_text)
  end
end
